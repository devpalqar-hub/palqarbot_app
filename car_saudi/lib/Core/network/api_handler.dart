import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/Core/utils/message_localizer.dart';
import 'package:villas_qatar/modules/onboard/controller/auth_controller.dart';
import 'package:villas_qatar/modules/onboard/views/welcome_screen.dart';

class ApiHandler {
  ApiHandler._();

  static const String baseUrl = "https://apivillas.palqar.cloud";

  static const Duration _timeoutDuration = Duration(seconds: 20);

  static Never _onTimeout() {
    throw Exception(
      "Request timed out. Please check your internet connection and try again."
          .tr,
    );
  }

  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final String url = "$baseUrl$endpoint";

      final requestHeaders = _headers(headers);

      requestHeaders.forEach((key, value) {});

      final response = await http
          .get(Uri.parse(url), headers: requestHeaders)
          .timeout(_timeoutDuration, onTimeout: _onTimeout);

      return await _handleResponse(response);
    } on SocketException {
      debugPrint("========== GET ERROR ==========");
      debugPrint("No Internet Connection");
      debugPrint("================================");
      throw Exception("No Internet Connection".tr);
    }
  }

  // ============================================================
  // POST
  // ============================================================
  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final String url = "$baseUrl$endpoint";

      final requestHeaders = _headers(headers);

      // ========================= REQUEST =========================
      debugPrint("========== POST REQUEST ==========");
      debugPrint("URL: $url");

      debugPrint("HEADERS:");
      requestHeaders.forEach((key, value) {
        debugPrint("$key : $value");
      });

      if (body != null) {
        debugPrint("BODY:");
        debugPrint(const JsonEncoder.withIndent("  ").convert(body));
      }

      debugPrint("==================================");

      final response = await http
          .post(
            Uri.parse(url),
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeoutDuration, onTimeout: _onTimeout);

      // ========================= RESPONSE =========================
      debugPrint("========== POST RESPONSE ==========");
      debugPrint("URL: $url");
      debugPrint("STATUS CODE: ${response.statusCode}");

      try {
        final json = jsonDecode(response.body);
        debugPrint("BODY:");
        debugPrint(const JsonEncoder.withIndent("  ").convert(json));
      } catch (_) {
        debugPrint("BODY:");
        debugPrint(response.body);
      }

      debugPrint("===================================");

      return await _handleResponse(response);
    } on SocketException {
      debugPrint("========== POST ERROR ==========");
      debugPrint("No Internet Connection");
      debugPrint("================================");
      throw Exception("No Internet Connection".tr);
    } catch (e, stackTrace) {
      debugPrint("========== POST ERROR ==========");
      debugPrint("URL: $baseUrl$endpoint");
      debugPrint("ERROR: $e");
      debugPrint(stackTrace.toString());
      debugPrint("================================");
      rethrow;
    }
  }

  // ============================================================
  // PUT
  // ============================================================

  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final String url = "$baseUrl$endpoint";

      final requestHeaders = _headers(headers);

      _printRequest(
        method: "PUT",
        url: url,
        headers: requestHeaders,
        body: body,
      );

      final response = await http
          .put(
            Uri.parse(url),
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeoutDuration, onTimeout: _onTimeout);

      _printResponse(response);

      return await _handleResponse(response);
    } on SocketException {
      throw Exception("No Internet Connection".tr);
    }
  }

  // ============================================================
  // PATCH
  // ============================================================

  static Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final String url = "$baseUrl$endpoint";

      final requestHeaders = _headers(headers);

      _printRequest(
        method: "PATCH",
        url: url,
        headers: requestHeaders,
        body: body,
      );

      final response = await http
          .patch(
            Uri.parse(url),
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeoutDuration, onTimeout: _onTimeout);

      _printResponse(response);

      return await _handleResponse(response);
    } on SocketException {
      throw Exception("No Internet Connection".tr);
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  static Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final String url = "$baseUrl$endpoint";

      final requestHeaders = _headers(headers);

      _printRequest(method: "DELETE", url: url, headers: requestHeaders);

      final response = await http
          .delete(Uri.parse(url), headers: requestHeaders)
          .timeout(_timeoutDuration, onTimeout: _onTimeout);

      _printResponse(response);

      return await _handleResponse(response);
    } on SocketException {
      throw Exception("No Internet Connection".tr);
    }
  }

  // ============================================================
  // HEADERS
  // ============================================================

  static Map<String, String> _headers(Map<String, String>? headers) {
    final String? token = StorageService.getToken();

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",

      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",

      ...?headers,
    };
  }

  // ============================================================
  // RESPONSE HANDLER
  // ============================================================

  static Future<dynamic> _handleResponse(http.Response response) async {
    dynamic data;

    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = response.body;
      }
    }

    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
        return data;

      case 204:
        return null;

      case 400:
        throw Exception(_getErrorMessage(data, "Bad Request".tr));

      case 401:
        // Token expired/invalid (dealer or buyer session alike) - clear
        // storage and drop the user back to WelcomeScreen automatically.
        // AuthController is registered permanently in main(), so it's
        // reset in place rather than deleted: deleting it here would
        // leave every Get.find<AuthController>() call downstream (login
        // screens, WelcomeScreen, Settings/dealer logout) crashing with
        // "AuthController not found" until the app is fully restarted.
        final token = StorageService.getToken();
        if (token != null && token.isNotEmpty) {
          await StorageService.logout();
          if (Get.isRegistered<AuthController>()) {
            Get.find<AuthController>().reset();
          }
          Get.offAll(() => WelcomeScreen());
        }

        throw Exception(_getErrorMessage(data, "Unauthorized".tr));

      case 403:
        throw Exception(_getErrorMessage(data, "Forbidden".tr));

      case 404:
        throw Exception(_getErrorMessage(data, "Not Found".tr));

      case 409:
        throw Exception(_getErrorMessage(data, "Conflict".tr));

      case 422:
        throw Exception(_getErrorMessage(data, "Invalid Data".tr));

      case 500:
      case 502:
      case 503:
        throw Exception(_getErrorMessage(data, "Server Error".tr));

      default:
        throw Exception(_getErrorMessage(data, "Error ${response.statusCode}"));
    }
  }

  static String _getErrorMessage(dynamic data, String fallback) {
    if (data is Map) {
      final dynamic message = data["message"];

      if (message is String && message.isNotEmpty) {
        return message.trMsg;
      }

      if (message is List) {
        return message.map((e) => e.toString().trMsg).join(", ");
      }

      final dynamic error = data["error"];

      if (error is String && error.isNotEmpty) {
        return error.trMsg;
      }
    }

    if (data is String && data.isNotEmpty) {
      return data.trMsg;
    }

    return fallback;
  }

  // ============================================================
  // REQUEST LOG
  // ============================================================

  static void _printRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    // print(
    //   "========================================",
    // );

    // print("$method REQUEST");

    // print("URL: $url");

    // print(
    //   "HEADERS: ${headers ?? {}}",
    // );

    if (body != null) {
      // print("BODY:");

      try {
        // print(
        //   const JsonEncoder.withIndent(
        //     "  ",
        //   ).convert(body),
        // );
      } catch (_) {
        // print(body);
      }
    }

    // print(
    //   "========================================",
    // );
  }

  // ============================================================
  // RESPONSE LOG
  // ============================================================

  static void _printResponse(http.Response response) {
    // print(
    //   "========================================",
    // );

    // print(
    //   "STATUS CODE: ${response.statusCode}",
    // );

    if (response.body.isNotEmpty) {
      try {
        final dynamic json = jsonDecode(response.body);

        // print("RESPONSE:");

        // print(
        //   const JsonEncoder.withIndent(
        //     "  ",
        //   ).convert(json),
        // );
      } catch (_) {
        // print("RESPONSE:");

        // print(response.body);
      }
    }

    // print(
    //   "========================================",
    // );
  }
}
