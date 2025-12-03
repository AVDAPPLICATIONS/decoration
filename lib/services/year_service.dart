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
      apiUrl = '$apiBaseUrl/api/years/getByTemplate';
      requestBody['event_template_id'] = templateId;
    } else {
      // Use general endpoint when no templateId is provided
      apiUrl = '$apiBaseUrl/api/years/getAll';
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final List<dynamic> responseData = json.decode(response.body);

          final years =
              responseData.map((json) => YearModel.fromJson(json)).toList();

          // Log each year for debugging
          for (var year in years) {}

          return years;
        } catch (e) {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<YearModel> createYear(YearModel year) async {
    const String apiUrl = '$apiBaseUrl/api/years/create';

    try {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);

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
      rethrow;
    }
  }

  Future<void> deleteYear(int id) async {
    const String apiUrl = '$apiBaseUrl/api/years/delete';

    try {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);

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
      rethrow;
    }
  }
}
