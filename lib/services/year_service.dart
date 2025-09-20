import 'package:avd_decoration_application/utils/constants.dart';

import '../models/year_model.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class YearService {
  final ApiService api;

  YearService(this.api);

  Future<List<YearModel>> fetchYears({int? templateId}) async {
    String apiUrl;
    Map<String, dynamic> requestBody = {};

    if (templateId != null) {
      // Use template-specific endpoint when templateId is provided
      apiUrl = '${apiBaseUrl}/api/years/getByTemplate';
      requestBody['event_template_id'] = templateId;
    } else {
      // Use general endpoint when no templateId is provided
      apiUrl = '${apiBaseUrl}/api/years/getAll';
    }

    try {
      print('Fetching years from API: $apiUrl');
      print('Template ID: $templateId');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final List<dynamic> responseData = json.decode(response.body);
          print('Successfully parsed ${responseData.length} years');

          final years =
              responseData.map((json) => YearModel.fromJson(json)).toList();

          // Log each year for debugging
          for (var year in years) {
            print('Year: ${year.yearName} (ID: ${year.id})');
          }

          return years;
        } catch (e) {
          print('Error parsing years response: $e');
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Network error fetching years: $e');
      return [];
    }
  }

  Future<YearModel> createYear(YearModel year) async {
    const String apiUrl = '${apiBaseUrl}/api/years/create';

    try {
      print('Creating year: ${year.yearName}');
      print('API URL: $apiUrl');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'year_name': year.yearName,
          'event_template_id': year.templateId,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          print('Successfully created year: $responseData');
          return YearModel.fromJson(responseData);
        } catch (e) {
          throw Exception('Invalid JSON response: ${e.toString()}');
        }
      } else {
        // Handle HTTP error
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ??
              errorData['message'] ??
              'HTTP Error: ${response.statusCode}');
        } catch (e) {
          throw Exception(
              'HTTP Error: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('Network error creating year: $e');
      rethrow;
    }
  }

  Future<void> deleteYear(int id) async {
    const String apiUrl = '${apiBaseUrl}/api/years/delete';

    try {
      print('Deleting year with ID: $id');
      print('API URL: $apiUrl');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'id': id,
        }),
      );

      print('Delete response status code: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          print('Successfully deleted year: $responseData');
          return;
        } catch (e) {
          throw Exception('Invalid JSON response: ${e.toString()}');
        }
      } else {
        // Handle HTTP error
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ??
              errorData['message'] ??
              'HTTP Error: ${response.statusCode}');
        } catch (e) {
          throw Exception(
              'HTTP Error: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('Network error deleting year: $e');
      rethrow;
    }
  }
}
