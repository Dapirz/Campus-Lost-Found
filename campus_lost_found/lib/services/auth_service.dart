import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  /// POST /auth/login
  /// Return Map: { 'success': bool, 'token': String?, 'user': UserModel?, 'message': String }
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/login'),
            headers: ApiConfig.headers(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'token': data['data']['token'],
          'user': UserModel.fromJson(data['data']['user']),
          'message': data['message'] ?? 'Login successful',
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'token': null,
          'user': null,
          'message': data['message'] ?? 'Your account has been deactivated.',
        };
      } else {
        return {
          'success': false,
          'token': null,
          'user': null,
          'message': 'Invalid email or password',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'token': null,
        'user': null,
        'message':
            'Connection timeout. Please make sure the server is running.',
      };
    } catch (e) {
      return {
        'success': false,
        'token': null,
        'user': null,
        'message':
            'Failed to connect to server. Please check your internet connection.',
      };
    }
  }

  /// POST /auth/register
  /// Return Map: { 'success': bool, 'message': String, 'errors': Map? }
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/register'),
            headers: ApiConfig.headers(),
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
          'errors': null,
        };
      } else if (response.statusCode == 422) {
        // Validation errors dari Laravel
        return {
          'success': false,
          'message': data['message'] ?? 'Validation failed',
          'errors': data['errors'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
          'errors': null,
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Connection timeout. Please make sure the server is running.',
        'errors': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Failed to connect to server. Please check your internet connection.',
        'errors': null,
      };
    }
  }

  /// POST /auth/logout
  /// Return bool
  Future<bool> logout(String token) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(ApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// GET /auth/me
  /// Return UserModel atau null
  Future<UserModel?> getMe(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/auth/me'),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return UserModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// PUT /user/profile
  /// Update name and optionally password.
  Future<Map<String, dynamic>> updateProfile(
    String token, {
    String? name,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/user/profile'),
            headers: ApiConfig.headers(token: token),
            body: jsonEncode({
              'name': ?name,
              'current_password': ?currentPassword,
              'password': ?password,
              'password_confirmation': ?passwordConfirmation,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profile updated successfully',
          'errors': null,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update profile',
        'errors': data['errors'],
      };
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Connection timeout. Please make sure the server is running.',
        'errors': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Failed to connect to server. Please check your internet connection.',
        'errors': null,
      };
    }
  }
}
