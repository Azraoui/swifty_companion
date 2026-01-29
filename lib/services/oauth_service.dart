import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class OAuthService {
  static const String _tokenUrl = 'https://api.intra.42.fr/oauth/token';
  static const String _tokenKey = 'access_token';
  static const String _expiryKey = 'token_expiry';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _cachedToken;
  DateTime? _tokenExpiry;

  /// Get a valid access token, refreshing if necessary
  Future<String?> getAccessToken() async {
    // Check if we have a valid cached token in memory
    if (_cachedToken != null && _tokenExpiry != null) {
      if (DateTime.now().isBefore(
        _tokenExpiry!.subtract(const Duration(minutes: 1)),
      )) {
        return _cachedToken;
      }
    }

    // Try to load from secure storage
    final storedToken = await _secureStorage.read(key: _tokenKey);
    final storedExpiry = await _secureStorage.read(key: _expiryKey);

    if (storedToken != null && storedExpiry != null) {
      final expiry = DateTime.tryParse(storedExpiry);
      if (expiry != null &&
          DateTime.now().isBefore(
            expiry.subtract(const Duration(minutes: 1)),
          )) {
        _cachedToken = storedToken;
        _tokenExpiry = expiry;
        return _cachedToken;
      }
    }

    // Token expired or doesn't exist, get a new one
    return await _fetchNewToken();
  }

  /// Fetch a new access token using client credentials
  Future<String?> _fetchNewToken() async {
    try {
      final clientId = dotenv.env['CLIENT_ID'];
      final clientSecret = dotenv.env['CLIENT_SECRET'];

      if (clientId == null || clientSecret == null) {
        throw Exception('CLIENT_ID or CLIENT_SECRET not found in .env');
      }

      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'] as String;
        final expiresIn = data['expires_in'] as int;

        // Calculate expiry time
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
        _cachedToken = accessToken;

        // Store in secure storage
        await _secureStorage.write(key: _tokenKey, value: accessToken);
        await _secureStorage.write(
          key: _expiryKey,
          value: _tokenExpiry!.toIso8601String(),
        );

        return accessToken;
      } else {
        throw Exception(
          'Failed to get access token: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Clear stored tokens (for logout)
  Future<void> clearTokens() async {
    _cachedToken = null;
    _tokenExpiry = null;
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _expiryKey);
  }

  /// Check if we have a valid token
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null;
  }
}
