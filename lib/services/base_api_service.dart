import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage_service.dart';
import 'api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class BaseApiService {
  BaseApiService({
    http.Client? client,
    String? baseUrl,
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final TokenStorageService _tokenStorage = TokenStorageService();

  // Get authorization header with JWT token
  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (requireAuth) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Generic GET request with automatic token handling
  Future<T> get<T>(
    String path, {
    bool requireAuth = true,
    Duration? timeout,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await _client
          .get(
            Uri.parse('$baseUrl$path'),
            headers: headers,
          )
          .timeout(timeout ?? const Duration(seconds: 30));

      return _handleResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      await _clearTokenIfUnauthorized(e);
      throw _handleError(e);
    }
  }

  // Generic POST request with automatic token handling
  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
    Duration? timeout,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await _client
          .post(
            Uri.parse('$baseUrl$path'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout ?? const Duration(seconds: 30));

      return _handleResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      await _clearTokenIfUnauthorized(e);
      throw _handleError(e);
    }
  }

  // Generic PUT request with automatic token handling
  Future<T> put<T>(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
    Duration? timeout,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await _client
          .put(
            Uri.parse('$baseUrl$path'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout ?? const Duration(seconds: 30));

      return _handleResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      await _clearTokenIfUnauthorized(e);
      throw _handleError(e);
    }
  }

  // Generic DELETE request with automatic token handling
  Future<T> delete<T>(
    String path, {
    bool requireAuth = true,
    Duration? timeout,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await _client
          .delete(
            Uri.parse('$baseUrl$path'),
            headers: headers,
          )
          .timeout(timeout ?? const Duration(seconds: 30));

      return _handleResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      await _clearTokenIfUnauthorized(e);
      throw _handleError(e);
    }
  }

  // Handle HTTP response
  T _handleResponse<T>(
    http.Response response, {
    T Function(dynamic)? fromJson,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (fromJson != null) {
        final decoded = jsonDecode(response.body);
        return fromJson(decoded);
      }
      return response.body as T;
    }

    // Handle specific status codes
    if (response.statusCode == 401) {
      throw ApiException(
        'Authentication required. Please login again.',
        statusCode: 401,
      );
    } else if (response.statusCode == 403) {
      throw ApiException(
        'Access forbidden. You don\'t have permission.',
        statusCode: 403,
      );
    } else if (response.statusCode == 404) {
      throw ApiException(
        'Resource not found.',
        statusCode: 404,
      );
    } else if (response.statusCode >= 500) {
      throw ApiException(
        'Server error. Please try again later.',
        statusCode: response.statusCode,
      );
    }

    throw ApiException(
      'Request failed with status ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  // Handle errors
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    
    if (error is http.ClientException) {
      return ApiException(
        'Network error: ${error.message}',
        statusCode: null,
      );
    }

    return ApiException(
      'An unexpected error occurred: $error',
      statusCode: null,
    );
  }

  Future<void> _clearTokenIfUnauthorized(dynamic error) async {
    if (error is ApiException && error.statusCode == 401) {
      await _tokenStorage.clearTokens();
    }
  }
}
