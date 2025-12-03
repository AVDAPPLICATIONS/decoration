import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CostService {
  final String baseUrl;

  CostService(this.baseUrl);

  Future<Map<String, dynamic>> createEventCostItem({
    required int eventId,
    required String description,
    required double amount,
    File? document,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/costs/eventCostItems/create');
      final request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields['event_id'] = eventId.toString();
      request.fields['description'] = description;
      request.fields['amount'] = amount.toString();

      // Add file if provided
      if (document != null) {
        final fileStream = http.ByteStream(document.openRead());
        final fileLength = await document.length();
        final multipartFile = http.MultipartFile(
          'document',
          fileStream,
          fileLength,
          filename: document.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse JSON response
        final responseData = response.body;

        // Return success response
        return {
          'success': true,
          'message': 'Cost item created successfully',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create cost item: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating cost item: $e',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getEventCosts(int eventId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/costs/eventCostItems/getByEvent');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'event_id': eventId,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.body,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch costs: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching costs: $e',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateEventCostItem({
    required int costId,
    required String description,
    required double amount,
    File? document,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/costs/eventCostItems/updateWithFile');
      final request = http.MultipartRequest('POST', uri);

      // Add form fields as per API specification
      request.fields['id'] = costId.toString();
      request.fields['description'] = description;
      request.fields['amount'] = amount.toString();

      // Add file if provided
      if (document != null) {
        final fileStream = http.ByteStream(document.openRead());
        final fileLength = await document.length();
        final multipartFile = http.MultipartFile(
          'document',
          fileStream,
          fileLength,
          filename: document.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the JSON response
        final responseData = jsonDecode(response.body);
        return {
          'success': responseData['success'] ?? true,
          'message':
              responseData['message'] ?? 'Cost item updated successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update cost item: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating cost item: $e',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteEventCostItem(int costId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/costs/eventCostItems/delete');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': costId,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final responseData = jsonDecode(response.body);
        return {
          'success': responseData['success'] ?? true,
          'message':
              responseData['message'] ?? 'Cost item deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete cost item: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting cost item: $e',
        'error': e.toString(),
      };
    }
  }
}
