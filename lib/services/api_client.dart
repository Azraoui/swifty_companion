import 'dart:convert';
import 'package:http/http.dart' as http;
import 'oauth_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class UserNotFoundException extends ApiException {
  UserNotFoundException(String login)
    : super('User "$login" not found', statusCode: 404);
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class ApiClient {
  static const String _baseUrl = 'https://api.intra.42.fr/v2';

  final OAuthService _oauthService;

  ApiClient({OAuthService? oauthService})
    : _oauthService = oauthService ?? OAuthService();

  /// Make an authenticated GET request to the 42 API
  Future<dynamic> get(String endpoint) async {
    try {
      final token = await _oauthService.getAccessToken();

      if (token == null) {
        throw ApiException('Failed to obtain access token');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    }
  }

  /// Handle API response and errors
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body);
      case 401:
        throw ApiException(
          'Unauthorized - token may be invalid',
          statusCode: 401,
        );
      case 404:
        throw ApiException('Resource not found', statusCode: 404);
      case 429:
        throw ApiException('Rate limited - too many requests', statusCode: 429);
      default:
        throw ApiException(
          'API error: ${response.body}',
          statusCode: response.statusCode,
        );
    }
  }

  /// Fetch user by login
  Future<Map<String, dynamic>> getUserByLogin(String login) async {
    try {
      final result = await get('/users/$login');
      return result as Map<String, dynamic>;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        throw UserNotFoundException(login);
      }
      rethrow;
    }
  }

  /// Fetch user's projects
  Future<List<dynamic>> getUserProjects(int userId) async {
    final result = await get('/users/$userId/projects_users');
    return result as List<dynamic>;
  }

  /// Fetch user's skills for a specific cursus
  Future<List<dynamic>> getUserSkills(int userId, int cursusId) async {
    final user = await get('/users/$userId');
    final cursusUsers = user['cursus_users'] as List<dynamic>?;

    if (cursusUsers == null) return [];

    for (final cursus in cursusUsers) {
      if (cursus['cursus_id'] == cursusId) {
        return cursus['skills'] as List<dynamic>? ?? [];
      }
    }
    return [];
  }
}
