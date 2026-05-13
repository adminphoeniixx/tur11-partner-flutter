import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_constants.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? details;

  const ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() {
    if (statusCode == null) return message;
    return '$message (status: $statusCode)';
  }
}

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  static Future<Response<dynamic>> post(String url, {dynamic data}) async {
    final headers = await _authHeaders();

    _logRequest(
      method: 'POST',
      url: url,
      headers: headers,
      data: data,
    );

    try {
      final response = await dio.post(
        url,
        data: data,
        options: Options(headers: headers),
      );
      _logResponse(method: 'POST', url: url, response: response);
      return response;
    } on DioException catch (e) {
      await _handleUnauthorized(e);
      _logDioError(method: 'POST', url: url, error: e);
      throw _toApiException(e);
    }
  }

  static Future<Response<dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final headers = await _authHeaders();

    _logRequest(
      method: 'GET',
      url: url,
      headers: headers,
      queryParameters: queryParameters,
    );

    try {
      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      _logResponse(method: 'GET', url: url, response: response);
      return response;
    } on DioException catch (e) {
      await _handleUnauthorized(e);
      _logDioError(method: 'GET', url: url, error: e);
      throw _toApiException(e);
    }
  }

  static Future<Response<dynamic>> put(String url, {dynamic data}) async {
    final headers = await _authHeaders();

    _logRequest(
      method: 'PUT',
      url: url,
      headers: headers,
      data: data,
    );

    try {
      final response = await dio.put(
        url,
        data: data,
        options: Options(headers: headers),
      );
      _logResponse(method: 'PUT', url: url, response: response);
      return response;
    } on DioException catch (e) {
      await _handleUnauthorized(e);
      _logDioError(method: 'PUT', url: url, error: e);
      throw _toApiException(e);
    }
  }

  static Future<Response<dynamic>> delete(String url, {dynamic data}) async {
    final headers = await _authHeaders();

    _logRequest(
      method: 'DELETE',
      url: url,
      headers: headers,
      data: data,
    );

    try {
      final response = await dio.delete(
        url,
        data: data,
        options: Options(headers: headers),
      );
      _logResponse(method: 'DELETE', url: url, response: response);
      return response;
    } on DioException catch (e) {
      await _handleUnauthorized(e);
      _logDioError(method: 'DELETE', url: url, error: e);
      throw _toApiException(e);
    }
  }

  static Future<Map<String, dynamic>> _authHeaders() async {
    final token = await StorageService.getToken();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<void> _handleUnauthorized(DioException error) async {
    if (error.response?.statusCode == 401) {
      await StorageService.clear();
      debugPrint('[ApiClient] Cleared local session after 401 Unauthorized');
    }
  }

  static void _logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) {
    debugPrint('========== API REQUEST ==========');
    debugPrint('Method: $method');
    debugPrint('URL: ${dio.options.baseUrl}$url');
    if (headers != null && headers.isNotEmpty) {
      debugPrint('Headers: ${_pretty(headers)}');
    }
    if (queryParameters != null && queryParameters.isNotEmpty) {
      debugPrint('Query: ${_pretty(queryParameters)}');
    }
    if (data != null) {
      debugPrint('Body: ${_pretty(data)}');
    }
    debugPrint('=================================');
  }

  static void _logResponse({
    required String method,
    required String url,
    required Response<dynamic> response,
  }) {
    debugPrint('========== API RESPONSE =========');
    debugPrint('Method: $method');
    debugPrint('URL: ${dio.options.baseUrl}$url');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Response: ${_pretty(response.data)}');
    debugPrint('=================================');
  }

  static void _logDioError({
    required String method,
    required String url,
    required DioException error,
  }) {
    debugPrint('=========== API ERROR ===========');
    debugPrint('Method: $method');
    debugPrint('URL: ${dio.options.baseUrl}$url');
    debugPrint('Status: ${error.response?.statusCode ?? 'NO_STATUS'}');
    debugPrint('Message: ${error.message}');
    if (error.response?.data != null) {
      debugPrint('Error Response: ${_pretty(error.response?.data)}');
    }
    debugPrint('=================================');
  }

  static String _pretty(dynamic value) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      if (value is Map || value is List) {
        return encoder.convert(value);
      }
      return value.toString();
    } catch (_) {
      return value.toString();
    }
  }

  static ApiException _toApiException(DioException error) {
    return ApiException(
      _formatError(error),
      statusCode: error.response?.statusCode,
      details: error.response?.data ?? error.message,
    );
  }

  static String _formatError(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final nestedErrors = data['errors'];
      if (nestedErrors is Map<String, dynamic> && nestedErrors.isNotEmpty) {
        final firstError = nestedErrors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }

      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return error.message ?? 'Something went wrong while calling the API.';
  }
}
