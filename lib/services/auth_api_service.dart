import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage_service.dart';
import 'api_config.dart';

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthResult {
  const AuthResult({
    required this.username,
    required this.accessToken,
    required this.refreshToken,
  });

  final String username;
  final String accessToken;
  final String refreshToken;
}

class SessionUser {
  const SessionUser({
    required this.username,
  });

  final String username;
}

class AuthApiService {
  AuthApiService({
    http.Client? client,
    String? baseUrl,
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<bool> isBackendConnected() async {
    try {
      final healthUrl = '$baseUrl/api/health/';
      final response = await _client
          .get(Uri.parse(healthUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return false;
      }

      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> && decoded['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    return _post('/api/auth/login/', {
      'username': username,
      'password': password,
    });
  }

  Future<AuthResult> createAccount({
    required String email,
    required String username,
    required String password,
  }) async {
    return _post('/api/auth/create-account/', {
      'email': email,
      'username': username,
      'password': password,
    });
  }

  Future<SessionUser?> validateSavedSession() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/auth/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final user = decoded['user'] as Map<String, dynamic>;
        final username = user['username'] as String? ?? await _tokenStorage.getUsername();

        if (username == null || username.isEmpty) {
          await _tokenStorage.clearTokens();
          return null;
        }

        return SessionUser(username: username);
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _tokenStorage.clearTokens();
        return null;
      }

      final username = await _tokenStorage.getUsername();
      if (username != null && username.isNotEmpty) {
        return SessionUser(username: username);
      }
      return null;
    } catch (_) {
      final username = await _tokenStorage.getUsername();
      if (username != null && username.isNotEmpty) {
        return SessionUser(username: username);
      }
      return null;
    }
  }

  Future<void> clearSavedSession() async {
    await _tokenStorage.clearTokens();
  }

  Future<AuthResult> _post(String path, Map<String, String> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_errorMessage(decoded));
    }

    final data = decoded as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    final accessToken =
        (data['access'] ?? data['access_token'] ?? data['token']) as String?;
    final refreshToken =
        (data['refresh'] ?? data['refresh_token']) as String? ?? '';

    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthApiException(
        'Login succeeded but no access token was returned.',
      );
    }

    final result = AuthResult(
      username: user['username'] as String,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    // Save tokens to local storage after successful login
    await _tokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      username: result.username,
    );

    return result;
  }

  String _errorMessage(Object? decoded) {
    if (decoded is Map<String, dynamic>) {
      final nonFieldErrors = decoded['non_field_errors'];
      if (nonFieldErrors is List && nonFieldErrors.isNotEmpty) {
        return nonFieldErrors.first.toString();
      }

      for (final value in decoded.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return 'Something went wrong. Please try again.';
  }

  // Logout method
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _tokenStorage.isLoggedIn();
  }

  // Get current username
  Future<String?> getCurrentUsername() async {
    return await _tokenStorage.getUsername();
  }
}
