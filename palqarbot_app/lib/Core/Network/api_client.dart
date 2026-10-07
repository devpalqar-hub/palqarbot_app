
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:palqarbot_app/Core/Constants/api_constants.dart';
import 'package:palqarbot_app/Core/Constants/storage_keys.dart';
import 'package:palqarbot_app/Core/Network/api_exception.dart';
import 'package:palqarbot_app/Core/Network/api_response.dart';

class ApiClient {
  final http.Client _client;

  /// Called automatically when an authenticated API returns 401.
  final Future<void> Function()? onUnauthorized;

  ApiClient({
    http.Client? client,
    this.onUnauthorized,
  }) : _client = client ?? http.Client();

  
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    T Function(dynamic data)? fromJson,
  }) async {
    final uri = _buildUri(
      endpoint,
      queryParameters: queryParameters,
    );

    try {
      final headers = await _headers();

      _printRequest(
        method: 'GET',
        uri: uri,
        headers: headers,
      );

      final response = await _client.get(
        uri,
        headers: headers,
      );

      _printResponse(
        method: 'GET',
        uri: uri,
        response: response,
      );

      return _handleResponse<T>(
        response,
        fromJson: fromJson,
        hasAuthorization: headers.containsKey('Authorization'),
      );
    } catch (e, stackTrace) {
      _printException(
        method: 'GET',
        uri: uri,
        error: e,
        stackTrace: stackTrace,
      );

      return _handleRequestError<T>(e);
    }
  }


  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic data)? fromJson,
  }) async {
    final uri = _buildUri(endpoint);

    try {
      final headers = await _headers();

      _printRequest(
        method: 'POST',
        uri: uri,
        headers: headers,
        body: body,
      );

      final response = await _client.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      _printResponse(
        method: 'POST',
        uri: uri,
        response: response,
      );

      return _handleResponse<T>(
        response,
        fromJson: fromJson,
        hasAuthorization: headers.containsKey('Authorization'),
      );
    } catch (e, stackTrace) {
      _printException(
        method: 'POST',
        uri: uri,
        error: e,
        stackTrace: stackTrace,
      );

      return _handleRequestError<T>(e);
    }
  }

  // ============================================================
  // PUT
  // ============================================================

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic data)? fromJson,
  }) async {
    final uri = _buildUri(endpoint);

    try {
      final headers = await _headers();

      _printRequest(
        method: 'PUT',
        uri: uri,
        headers: headers,
        body: body,
      );

      final response = await _client.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      _printResponse(
        method: 'PUT',
        uri: uri,
        response: response,
      );

      return _handleResponse<T>(
        response,
        fromJson: fromJson,
        hasAuthorization: headers.containsKey('Authorization'),
      );
    } catch (e, stackTrace) {
      _printException(
        method: 'PUT',
        uri: uri,
        error: e,
        stackTrace: stackTrace,
      );

      return _handleRequestError<T>(e);
    }
  }

  // ============================================================
  // PATCH
  // ============================================================

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic data)? fromJson,
  }) async {
    final uri = _buildUri(endpoint);

    try {
      final headers = await _headers();

      _printRequest(
        method: 'PATCH',
        uri: uri,
        headers: headers,
        body: body,
      );

      final response = await _client.patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      _printResponse(
        method: 'PATCH',
        uri: uri,
        response: response,
      );

      return _handleResponse<T>(
        response,
        fromJson: fromJson,
        hasAuthorization: headers.containsKey('Authorization'),
      );
    } catch (e, stackTrace) {
      _printException(
        method: 'PATCH',
        uri: uri,
        error: e,
        stackTrace: stackTrace,
      );

      return _handleRequestError<T>(e);
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic data)? fromJson,
  }) async {
    final uri = _buildUri(endpoint);

    try {
      final headers = await _headers();

      _printRequest(
        method: 'DELETE',
        uri: uri,
        headers: headers,
        body: body,
      );

      final response = await _client.delete(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      _printResponse(
        method: 'DELETE',
        uri: uri,
        response: response,
      );

      return _handleResponse<T>(
        response,
        fromJson: fromJson,
        hasAuthorization: headers.containsKey('Authorization'),
      );
    } catch (e, stackTrace) {
      _printException(
        method: 'DELETE',
        uri: uri,
        error: e,
        stackTrace: stackTrace,
      );

      return _handleRequestError<T>(e);
    }
  }


  Uri _buildUri(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) {
    final Uri uri;

    if (endpoint.startsWith('http://') ||
        endpoint.startsWith('https://')) {
      uri = Uri.parse(endpoint);
    } else {
      uri = Uri.parse(
        '${ApiConstants.baseUrl}$endpoint',
      );
    }

    if (queryParameters == null ||
        queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParameters,
      },
    );
  }

  // ============================================================
  // HEADERS
  // ============================================================

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString(
      StorageKeys.accessToken,
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }

  

  ApiResponse<T> _handleResponse<T>(
    http.Response response, {
    T Function(dynamic data)? fromJson,
    bool hasAuthorization = false,
  }) {
    dynamic decodedData;

    if (response.body.isNotEmpty) {
      try {
        decodedData = jsonDecode(response.body);
      } catch (_) {
        decodedData = response.body;
      }
    }

    final message = _extractMessage(decodedData);

    final isSuccess =
        response.statusCode >= 200 &&
        response.statusCode < 300;

    // ==========================================================
    // 401 UNAUTHORIZED
    // ==========================================================

    if (response.statusCode == 401 && hasAuthorization) {
      debugPrint('');
      debugPrint('**************** 401 UNAUTHORIZED ***************');
      debugPrint('SESSION EXPIRED');
      debugPrint('***********************************************');
      debugPrint('');

      unawaited(
        onUnauthorized?.call(),
      );

      return ApiResponse<T>(
        success: false,
        statusCode: 401,
        data: null,
        message: message ?? 'Session expired',
      );
    }

    // ==========================================================
    // SUCCESS
    // ==========================================================

    if (isSuccess) {
      T? data;

      if (fromJson != null && decodedData != null) {
        data = fromJson(decodedData);
      } else if (decodedData is T) {
        data = decodedData;
      } else {
        data = decodedData as T?;
      }

      debugPrint('');
      debugPrint('**************** API SUCCESS ****************');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('DATA: $decodedData');
      debugPrint('**********************************************');
      debugPrint('');

      return ApiResponse<T>(
        success: true,
        statusCode: response.statusCode,
        data: data,
        message: message,
      );
    }

    // ==========================================================
    // FAILED
    // ==========================================================

    debugPrint('');
    debugPrint('**************** API FAILED *****************');
    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('MESSAGE: ${message ?? 'No message'}');
    debugPrint('DATA: $decodedData');
    debugPrint('**********************************************');
    debugPrint('');

    _showErrorToast(
      message ?? 'Something went wrong',
    );

    return ApiResponse<T>(
      success: false,
      statusCode: response.statusCode,
      data: null,
      message: message ?? 'Something went wrong',
    );
  }

  // ============================================================
  // REQUEST ERROR
  // ============================================================

  ApiResponse<T> _handleRequestError<T>(
    Object error,
  ) {
    debugPrint('');
    

    final exception = _handleException(error);

    _showErrorToast(exception.message);

    return ApiResponse<T>(
      success: false,
      statusCode: exception.statusCode ?? 0,
      data: null,
      message: exception.message,
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          data['error']?.toString();
    }

    return null;
  }

  // ============================================================
  // DEBUG REQUEST
  // ============================================================

  void _printRequest({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    dynamic body,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('');
    debugPrint('==================================================');
    debugPrint('                    API REQUEST');
    debugPrint('==================================================');
    debugPrint('METHOD : $method');
    debugPrint('URL    : $uri');

    if (headers.isNotEmpty) {
      debugPrint('HEADERS: ${_sanitizeHeaders(headers)}');
    }

    if (body != null) {
      debugPrint(
        'BODY   : ${_sanitizeBody(body)}',
      );
    }

    debugPrint('==================================================');
    debugPrint('');
  }

  // ============================================================
  // DEBUG RESPONSE
  // ============================================================

  void _printResponse({
    required String method,
    required Uri uri,
    required http.Response response,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('');
    debugPrint('==================================================');
    debugPrint('                   API RESPONSE');
    debugPrint('==================================================');
    debugPrint('METHOD       : $method');
    debugPrint('URL          : $uri');
    debugPrint('STATUS CODE  : ${response.statusCode}');
    debugPrint('REASON       : ${response.reasonPhrase}');
    debugPrint('BODY         : ${response.body}');
    debugPrint('==================================================');
    debugPrint('');
  }

  // ============================================================
  // DEBUG EXCEPTION
  // ============================================================

  void _printException({
    required String method,
    required Uri uri,
    required Object error,
    required StackTrace stackTrace,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('');
    debugPrint('==================================================');
    debugPrint('                  API EXCEPTION');
    debugPrint('==================================================');
    debugPrint('METHOD : $method');
    debugPrint('URL    : $uri');
    debugPrint('ERROR  : $error');
    debugPrint('STACK  : $stackTrace');
    debugPrint('==================================================');
    debugPrint('');
  }

  // ============================================================
  // SANITIZE HEADERS
  // ============================================================

  Map<String, String> _sanitizeHeaders(
    Map<String, String> headers,
  ) {
    final result = Map<String, String>.from(headers);

    if (result.containsKey('Authorization')) {
      result['Authorization'] = 'Bearer ***HIDDEN***';
    }

    return result;
  }

  // ============================================================
  // SANITIZE BODY
  // ============================================================

  dynamic _sanitizeBody(dynamic body) {
    if (body is! Map) {
      return body;
    }

    final result = Map<String, dynamic>.from(body);

    const sensitiveKeys = {
      'password',
      'accessToken',
      'appSecret',
      'verifyToken',
      'token',
      'refreshToken',
    };

    for (final key in sensitiveKeys) {
      if (result.containsKey(key)) {
        result[key] = '***HIDDEN***';
      }
    }

    return result;
  }

  // ============================================================
  // TOAST
  // ============================================================

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  // ============================================================
  // EXCEPTION
  // ============================================================

  ApiException _handleException(Object error) {
    if (error is ApiException) {
      return error;
    }

    if (error is http.ClientException) {
      return ApiException(
        message: error.message,
      );
    }

    return ApiException(
      message: error.toString(),
    );
  }

  // ============================================================
  // CLOSE
  // ============================================================

  void dispose() {
    _client.close();
  }
}
