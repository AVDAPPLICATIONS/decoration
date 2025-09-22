// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('Making GET request to: $url');
      final response = await http.get(url, headers: _headers()).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your network connection.');
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print(
          'Response body (first 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      return _processResponse(response);
    } on SocketException {
      throw Exception('No internet connection. Please check your network and try again.');
    } on HttpException {
      throw Exception('Could not reach the server. Please check if the server is running.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      if (e.toString().contains('HandshakeException') || e.toString().contains('WRONG_VERSION_NUMBER')) {
        throw Exception('SSL/TLS connection error. Please check if the server is running on the correct protocol (HTTP/HTTPS).');
      }
      if (e.toString().contains('Connection timed out')) {
        throw Exception('Connection timed out. Please check your network connection and try again.');
      }
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint,
      {required Map<String, dynamic> body}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('Making POST request to: $url');
      print('Request body: ${jsonEncode(body)}');
      print('Request headers: ${_headers()}');

      final response = await http.post(url, headers: _headers(), body: jsonEncode(body)).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your network connection.');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      return _processResponse(response);
    } on SocketException {
      throw Exception('No internet connection. Please check your network and try again.');
    } on HttpException {
      throw Exception('Could not reach the server. Please check if the server is running.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      if (e.toString().contains('HandshakeException') || e.toString().contains('WRONG_VERSION_NUMBER')) {
        throw Exception('SSL/TLS connection error. Please check if the server is running on the correct protocol (HTTP/HTTPS).');
      }
      if (e.toString().contains('Connection timed out')) {
        throw Exception('Connection timed out. Please check your network connection and try again.');
      }
      rethrow;
    }
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
    print('Making POST form-data request to: $url');
    print('Fields: $fields');
    print('Files: ${files.keys}');

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

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

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
