// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.get(url, headers: _headers());

    print(
        'Response body (first 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint,
      {required Map<String, dynamic> body}) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final response =
        await http.post(url, headers: _headers(), body: jsonEncode(body));

    return _processResponse(response);
  }

  Future<dynamic> put(String endpoint,
      {required Map<String, dynamic> body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response =
        await http.put(url, headers: _headers(), body: jsonEncode(body));
    return _processResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(url, headers: _headers());
    return _processResponse(response);
  }

  Future<dynamic> postFormData(
    String endpoint, {
    required Map<String, dynamic> fields,
    required Map<String, File> files,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    var request = http.MultipartRequest('POST', url);

    // Add fields
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add files
    files.forEach((key, file) {
      request.files.add(http.MultipartFile(
        key,
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: file.path.split('/').last,
      ));
    });

    // Add headers (don't set Content-Type for form-data)
    request.headers.addAll(_formDataHeaders());

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _processResponse(response);
  }

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        // Add Authorization header if needed
      };

  Map<String, String> _formDataHeaders() => {
        // Don't set Content-Type for form-data, let http package handle it
        // Add Authorization header if needed
      };

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        throw Exception(
            'Server returned HTML instead of JSON. This might indicate a wrong endpoint or server configuration issue. Response: ${response.body.substring(0, 200)}...');
      }

      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception(
            'Failed to parse JSON response: $e. Response body: ${response.body.substring(0, 200)}...');
      }
    } else {
      throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
    }
  }
}
