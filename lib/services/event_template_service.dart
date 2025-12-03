import '../models/event_template_model.dart';
import 'api_service.dart';

class EventTemplateService {
  final ApiService api;

  EventTemplateService(this.api);

  Future<List<EventTemplateModel>> fetchTemplates() async {
    try {
      // Try POST request first (as per user specification)
      dynamic response;
      try {
        response = await api.post('/api/event-templates/getAll', body: {});
      } catch (e) {
        // If POST fails, try GET request as fallback

        response = await api.get('/api/event-templates/getAll');
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
        return [];
      }

      final templates = templatesList
          .map((json) => EventTemplateModel.fromJson(json))
          .toList();

      return templates;
    } catch (e) {
      rethrow;
    }
  }

  Future<EventTemplateModel> addTemplate(EventTemplateModel template) async {
    final response =
        await api.post('/api/event-templates/create', body: template.toJson());
    return EventTemplateModel.fromJson(response);
  }

  Future<Map<String, dynamic>> createTemplate(String name) async {
    final response = await api.post('/api/event-templates/create', body: {
      'name': name,
    });

    return response;
  }

  Future<EventTemplateModel> updateTemplate(
      int id, EventTemplateModel template) async {
    final response = await api.post('/api/event-templates/update', body: {
      'id': id,
      'name': template.name,
    });

    return EventTemplateModel.fromJson(response);
  }

  Future<void> deleteTemplate(int id) async {
    final response = await api.post('/api/event-templates/delete', body: {
      'id': id,
    });
  }
}
