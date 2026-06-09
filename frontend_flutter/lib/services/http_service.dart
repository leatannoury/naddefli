// =============================================================================
// NADDEFLI — http_service.dart
// Layer: Flutter — Service
// Purpose: Dio HTTP client wrapper. AuthInterceptor auto-adds Bearer JWT to every request.
// Connects to: All API calls go through this; reads token from StorageService
// =============================================================================

import 'package:dio/dio.dart';
import '../utils/storage_service.dart';

/// HTTP Interceptor for adding auth token
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = StorageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await StorageService.clearAll();
    }
    super.onError(err, handler);
  }
}

/// HTTP Client Service
class HttpService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) {
        return status! < 500;
      },
    ),
  )..interceptors.add(AuthInterceptor());

  /// Get method
  static Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  /// Post method
  static Future<Response> post(
    String url, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  /// Put method
  static Future<Response> put(
    String url, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put(url, data: data);
      return response;
    } on DioException {
      rethrow;
    }
  }

  /// Delete method
  static Future<Response> delete(String url) async {
    try {
      final response = await _dio.delete(url);
      return response;
    } on DioException {
      rethrow;
    }
  }
}
