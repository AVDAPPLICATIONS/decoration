import '../models/event_model.dart';
import 'api_service.dart';
import 'dart:io';

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

  Future<void> deleteEvent(int id) async {
    await api.delete('/api/events/$id');
  }

  Future<Map<String, dynamic>> getEventDetails({
    required int templateId,
    required int yearId,
  }) async {
    print('Getting event details for templateId: $templateId, yearId: $yearId');
    try {
      final response = await api.post('/api/events/getDetails', body: {
        'template_id': templateId,
        'year_id': yearId,
      });
      print('Event details response: $response');
      return response;
    } catch (e) {
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
      // Re-throw other errors
      rethrow;
    }
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
