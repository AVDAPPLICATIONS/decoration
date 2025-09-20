import '../models/event_template_model.dart';
import 'api_service.dart';

class EventTemplateService {
  final ApiService api;

  EventTemplateService(this.api);

  Future<List<EventTemplateModel>> fetchTemplates() async {
    try {
      print('Making API call to fetch templates...');

      // Try POST request first (as per user specification)
      dynamic response;
      try {
        response = await api.post('/api/event-templates/getAll', body: {});
        print('POST API response received: $response');
      } catch (e) {
        print('POST request failed: $e');
        // If POST fails, try GET request as fallback
        print('Trying GET request as fallback...');
        response = await api.get('/api/event-templates/getAll');
        print('GET API response received: $response');
      }

      // Handle different response formats
      List<dynamic> templatesList;
      if (response is List) {
        templatesList = response;
      } else if (response is Map<String, dynamic>) {
        // Check if the response has a 'data' field or similar
        if (response.containsKey('data') && response['data'] is List) {
          templatesList = response['data'];
        } else if (response.containsKey('templates') &&
            response['templates'] is List) {
          templatesList = response['templates'];
        } else if (response.containsKey('results') &&
            response['results'] is List) {
          templatesList = response['results'];
        } else {
          // If it's a single template object, wrap it in a list
          templatesList = [response];
        }
      } else {
        print('Unexpected response format: ${response.runtimeType}');
        return [];
      }

      final templates = templatesList
          .map((json) => EventTemplateModel.fromJson(json))
          .toList();
      print('Successfully parsed ${templates.length} templates');
      return templates;
    } catch (e) {
      print('Error in fetchTemplates: $e');
      rethrow;
    }
  }

  Future<EventTemplateModel> addTemplate(EventTemplateModel template) async {
    final response =
        await api.post('/api/event-templates/create', body: template.toJson());
    return EventTemplateModel.fromJson(response);
  }

  Future<Map<String, dynamic>> createTemplate(String name) async {
    print('Creating event template with name: $name');
    final response = await api.post('/api/event-templates/create', body: {
      'name': name,
    });
    print('Event template creation response: $response');
    return response;
  }

  Future<EventTemplateModel> updateTemplate(
      int id, EventTemplateModel template) async {
    print('Updating event template with ID: $id, name: ${template.name}');
    final response = await api.post('/api/event-templates/update', body: {
      'id': id,
      'name': template.name,
    });
    print('Event template update response: $response');
    return EventTemplateModel.fromJson(response);
  }

  Future<void> deleteTemplate(int id) async {
    print('Deleting event template with ID: $id');
    final response = await api.post('/api/event-templates/delete', body: {
      'id': id,
    });
    print('Event template delete response: $response');
  }
}
