// services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  final String baseUrl;

  AuthService(this.baseUrl);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/users/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Login failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } on SocketException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    } on HttpException {
      throw Exception(
          'Could not reach the server. Please check if the server is running.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      if (e.toString().contains('Connection timed out')) {
        throw Exception(
            'Connection timed out. Please check your network connection and try again.');
      } else if (e.toString().contains('HandshakeException') ||
          e.toString().contains('WRONG_VERSION_NUMBER') ||
          e.toString().contains('TlsException')) {
        throw Exception(
            'SSL/TLS connection error. Please check if the server is running on the correct protocol (HTTP/HTTPS) and try again.');
      }
      rethrow;
    }
  }

  Future<UserModel> register(UserModel user) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/users/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(user.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Registration failed');
      }
    } on SocketException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    } on HttpException {
      throw Exception(
          'Could not reach the server. Please check if the server is running.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      if (e.toString().contains('Connection timed out')) {
        throw Exception(
            'Connection timed out. Please check your network connection and try again.');
      } else if (e.toString().contains('HandshakeException') ||
          e.toString().contains('WRONG_VERSION_NUMBER') ||
          e.toString().contains('TlsException')) {
        throw Exception(
            'SSL/TLS connection error. Please check if the server is running on the correct protocol (HTTP/HTTPS) and try again.');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    // Add token clearance logic
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/users/me'),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch user');
      }
    } on SocketException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    } on HttpException {
      throw Exception(
          'Could not reach the server. Please check if the server is running.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      if (e.toString().contains('Connection timed out')) {
        throw Exception(
            'Connection timed out. Please check your network connection and try again.');
      } else if (e.toString().contains('HandshakeException') ||
          e.toString().contains('WRONG_VERSION_NUMBER') ||
          e.toString().contains('TlsException')) {
        throw Exception(
            'SSL/TLS connection error. Please check if the server is running on the correct protocol (HTTP/HTTPS) and try again.');
      }
      rethrow;
    }
  }
}
