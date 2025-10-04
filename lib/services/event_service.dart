import '../models/event_model.dart';
import 'api_service.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventService {
  final ApiService api;

  EventService(this.api);

  Future<List<EventModel>> fetchEvents() async {
    final response = await api.post('/api/events/getAll', body: {});

    // Handle different response formats
    List<dynamic> eventsList;
    if (response is List) {
      eventsList = response;
    } else if (response is Map<String, dynamic>) {
      // Check if the response has a 'data' field or similar
      if (response.containsKey('data') && response['data'] is List) {
        eventsList = response['data'];
      } else if (response.containsKey('events') && response['events'] is List) {
        eventsList = response['events'];
      } else if (response.containsKey('results') &&
          response['results'] is List) {
        eventsList = response['results'];
      } else {
        // If it's a single event object, wrap it in a list
        eventsList = [response];
      }
    } else {
      throw Exception('Unexpected response format: ${response.runtimeType}');
    }

    return eventsList.map((json) => EventModel.fromJson(json)).toList();
  }

  Future<List<EventModel>> getAllEvents() async {
    final response = await api.post('/api/events/getAll', body: {});

    // Handle different response formats
    List<dynamic> eventsList;
    if (response is List) {
      eventsList = response;
    } else if (response is Map<String, dynamic>) {
      // Check if the response has a 'data' field or similar
      if (response.containsKey('data') && response['data'] is List) {
        eventsList = response['data'];
      } else if (response.containsKey('events') && response['events'] is List) {
        eventsList = response['events'];
      } else if (response.containsKey('results') &&
          response['results'] is List) {
        eventsList = response['results'];
      } else {
        // If it's a single event object, wrap it in a list
        eventsList = [response];
      }
    } else {
      throw Exception('Unexpected response format: ${response.runtimeType}');
    }

    return eventsList.map((json) => EventModel.fromJson(json)).toList();
  }

  Future<List<EventModel>> fetchEventsByYear(int yearId) async {
    final response =
        await api.post('/api/events/getByYear', body: {'year_id': yearId});

    // Handle different response formats
    List<dynamic> eventsList;
    if (response is List) {
      eventsList = response;
    } else if (response is Map<String, dynamic>) {
      // Check if the response has a 'data' field or similar
      if (response.containsKey('data') && response['data'] is List) {
        eventsList = response['data'];
      } else if (response.containsKey('events') && response['events'] is List) {
        eventsList = response['events'];
      } else if (response.containsKey('results') &&
          response['results'] is List) {
        eventsList = response['results'];
      } else {
        // If it's a single event object, wrap it in a list
        eventsList = [response];
      }
    } else {
      throw Exception('Unexpected response format: ${response.runtimeType}');
    }

    return eventsList.map((json) => EventModel.fromJson(json)).toList();
  }

  Future<EventModel> createEvent(EventModel event) async {
    print('Creating event with data: ${event.toJson()}');
    final response = await api.post('/api/events/create', body: event.toJson());
    print('Event creation response: $response');
    return EventModel.fromJson(response);
  }

  Future<Map<String, dynamic>> createEventFromData(
      Map<String, dynamic> eventData) async {
    print('Creating event with data: $eventData');
    final response = await api.post('/api/events/create', body: eventData);
    print('Event creation response: $response');
    return response;
  }

  Future<Map<String, dynamic>> createEventWithFormData({
    required Map<String, dynamic> eventData,
    File? coverImage,
  }) async {
    print('Creating event with form-data: $eventData');
    print('Cover image: ${coverImage?.path}');

    final response = await api.postFormData(
      '/api/events/create',
      fields: eventData,
      files: coverImage != null ? {'cover_image': coverImage} : {},
    );

    print('Event creation response: $response');
    return response;
  }

  Future<EventModel> updateEvent(int id, EventModel event) async {
    final response = await api.put('/api/events/$id', body: event.toJson());
    return EventModel.fromJson(response);
  }

  Future<Map<String, dynamic>> updateEventDetails({
    required int eventId,
    required String eventName,
    required String location,
    required String date,
    required int templateId,
    required int yearId,
    File? coverImage,
    String? existingImageUrl,
  }) async {
    try {
      print('Updating event $eventId with name: $eventName, location: $location, date: $date, templateId: $templateId, yearId: $yearId');
      
      if (coverImage != null) {
        // Use multipart request for file upload
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${api.baseUrl}/api/events/update'),
        );
        
        // Add the image file
        request.files.add(await http.MultipartFile.fromPath(
          'cover_image',
          coverImage.path,
        ));
        
        // Add form fields
        request.fields['id'] = eventId.toString();
        request.fields['description'] = eventName;
        request.fields['location'] = location;
        request.fields['date'] = date;
        request.fields['template_id'] = templateId.toString();
        request.fields['year_id'] = yearId.toString();
        
        print('Sending multipart request with image');
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        
        print('Event update response: $data');
        return data;
      } else {
        // No image, use regular POST request
        final response = await api.post('/api/events/update', body: {
          'id': eventId,
          'description': eventName,
          'location': location,
          'date': date,
          'template_id': templateId,
          'year_id': yearId,
          'cover_image': existingImageUrl, // Preserve existing image
        });
        
        print('Event update response: $response');
        return response;
      }
    } catch (e) {
      print('Error updating event: $e');
      return {
        'success': false,
        'message': 'Failed to update event: $e',
      };
    }
  }

  Future<void> deleteEvent(int id) async {
    await api.delete('/api/events/$id');
  }

  Future<Map<String, dynamic>> getEventDetails({
    required int templateId,
    required int yearId,
    int maxRetries = 2,
  }) async {
    print('Getting event details for templateId: $templateId, yearId: $yearId');

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await api.post('/api/events/getDetails', body: {
          'template_id': templateId,
          'year_id': yearId,
        });
        print('Event details response: $response');
        return response;
      } catch (e) {
        // If this is the last attempt, handle the error
        if (attempt == maxRetries) {
          // Check if it's a 404 error (Event not found)
          if (e.toString().contains('404') ||
              e.toString().contains('Event not found')) {
            print('Event not found, returning success: false response');
            return {
              'success': false,
              'message': 'Event not found',
              'details': [
                {
                  'field': 'template_id, year_id',
                  'message':
                      'Event with template_id $templateId and year_id $yearId does not exist'
                }
              ]
            };
          }

          // Check if it's a 500 server error (database issues)
          if (e.toString().contains('500') ||
              e.toString().contains('column') ||
              e.toString().contains('does not exist')) {
            print(
                'Server database error after $maxRetries retries, returning error response');
            return {
              'success': false,
              'message':
                  'Server database error. Please contact the administrator.',
              'details': [
                {
                  'field': 'server_error',
                  'message':
                      'The server encountered a database error while fetching event details. This is a server-side issue that needs to be fixed by the administrator.'
                }
              ]
            };
          }

          // Re-throw other errors
          rethrow;
        } else {
          // Wait before retrying (exponential backoff)
          final delay = Duration(milliseconds: 500 * (attempt + 1));
          print(
              'Retrying in ${delay.inMilliseconds}ms (attempt ${attempt + 1}/${maxRetries + 1})');
          await Future.delayed(delay);
        }
      }
    }

    // This should never be reached, but just in case
    throw Exception('Unexpected error in getEventDetails');
  }

  Future<Map<String, dynamic>> createYear({
    required String year,
    required String eventName,
    required int templateId,
  }) async {
    print(
        'Creating year: $year for event: $eventName with template ID: $templateId');
    final response = await api.post('/api/years/create', body: {
      'year_name': year,
      'event_name': eventName,
      'template_id': templateId,
    });
    print('Year creation response: $response');
    return response;
  }
}
