
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:palqarbot_app/Core/Constants/api_constants.dart';
import 'package:palqarbot_app/Core/Constants/storage_keys.dart';
import 'package:palqarbot_app/Core/Network/api_client.dart';

import 'package:palqarbot_app/Screens/Auth/login_screen.dart';

class AuthController extends GetxController {
  late final ApiClient _apiClient;

  bool isLoading = false;

  Timer? _tokenExpiryTimer;

  bool _isLoggingOut = false;

  AuthController() {
    _apiClient = ApiClient(
      onUnauthorized: _handleUnauthorized,
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    update();

    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.success &&
          response.data != null &&
          response.data is Map) {
        final data = Map<String, dynamic>.from(
          response.data as Map,
        );

        final saved = await _saveAuthData(data);

        if (!saved) {
          debugPrint(
            'LOGIN FAILED: Access token was not found',
          );

          return false;
        }

        await _startTokenExpiryTimer();

        debugPrint('LOGIN SUCCESS');
        debugPrint('ACCESS TOKEN SAVED');

        return true;
      }

      debugPrint('LOGIN FAILED');
      debugPrint('MESSAGE: ${response.message}');

      return false;
    } catch (e, stackTrace) {
      debugPrint('LOGIN EXCEPTION: $e');
      debugPrint('$stackTrace');

      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    isLoading = true;
    update();

    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        body: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

      if (response.success &&
          response.data != null &&
          response.data is Map) {
        final data = Map<String, dynamic>.from(
          response.data as Map,
        );

        final saved = await _saveAuthData(data);

        if (!saved) {
          debugPrint(
            'REGISTER FAILED: Access token was not found',
          );

          return false;
        }

        await _startTokenExpiryTimer();

        debugPrint('REGISTER SUCCESS');
        debugPrint('ACCESS TOKEN SAVED');

        return true;
      }

      debugPrint('REGISTER FAILED');
      debugPrint('MESSAGE: ${response.message}');

      return false;
    } catch (e, stackTrace) {
      debugPrint('REGISTER EXCEPTION: $e');
      debugPrint('$stackTrace');

      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // ============================================================
  // SAVE AUTH DATA
  // ============================================================

  Future<bool> _saveAuthData(
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // ============================================================
    // ACCESS TOKEN
    // ============================================================

    final accessToken = data['accessToken'];

    if (accessToken == null ||
        accessToken.toString().isEmpty) {
      debugPrint(
        'ACCESS TOKEN NOT FOUND IN RESPONSE',
      );

      return false;
    }

    await prefs.setString(
      StorageKeys.accessToken,
      accessToken.toString(),
    );

    debugPrint(
      'ACCESS TOKEN SAVED (${accessToken.toString().length} chars)',
    );

    // ============================================================
    // REFRESH TOKEN
    // ============================================================

    final refreshToken = data['refreshToken'];

    if (refreshToken != null &&
        refreshToken.toString().isNotEmpty) {
      await prefs.setString(
        StorageKeys.refreshToken,
        refreshToken.toString(),
      );
    }

    // ============================================================
    // USER DATA
    // ============================================================

    final user = data['user'];

    if (user is Map) {
      final userData = Map<String, dynamic>.from(user);

      if (userData['id'] != null) {
        await prefs.setString(
          StorageKeys.userId,
          userData['id'].toString(),
        );
      }

      if (userData['email'] != null) {
        await prefs.setString(
          StorageKeys.userEmail,
          userData['email'].toString(),
        );
      }

      if (userData['role'] != null) {
        await prefs.setString(
          StorageKeys.userRole,
          userData['role'].toString(),
        );
      }

      if (userData['firstName'] != null) {
        await prefs.setString(
          StorageKeys.firstName,
          userData['firstName'].toString(),
        );
      }

      if (userData['lastName'] != null) {
        await prefs.setString(
          StorageKeys.lastName,
          userData['lastName'].toString(),
        );
      }
    }

    // ============================================================
    // VERIFY
    // ============================================================

    final savedToken = prefs.getString(
      StorageKeys.accessToken,
    );

    if (savedToken == null ||
        savedToken.isEmpty) {
      debugPrint(
        'ERROR: ACCESS TOKEN WAS NOT SAVED',
      );

      return false;
    }

    debugPrint(
      'AUTH DATA SAVED SUCCESSFULLY',
    );

    return true;
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(
      StorageKeys.accessToken,
    );

    if (token == null || token.isEmpty) {
      debugPrint('IS LOGGED IN: NO TOKEN');

      return false;
    }

    if (_isTokenExpired(token)) {
      debugPrint('IS LOGGED IN: TOKEN EXPIRED');

      await logout(
        navigateToLogin: false,
      );

      return false;
    }

    debugPrint('IS LOGGED IN: TOKEN VALID');

    await _startTokenExpiryTimer();

    return true;
  }

  // ============================================================
  // TOKEN EXPIRY
  // ============================================================

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        return true;
      }

      final payload = parts[1];

      final normalized = base64Url.normalize(
        payload,
      );

      final payloadMap = jsonDecode(
        utf8.decode(
          base64Url.decode(normalized),
        ),
      );

      if (payloadMap is! Map) {
        return true;
      }

      final exp = payloadMap['exp'];

      // No expiry claim.
      if (exp == null) {
        return false;
      }

      final expiryTime =
          DateTime.fromMillisecondsSinceEpoch(
        (exp as num).toInt() * 1000,
      );

      return DateTime.now().isAfter(
        expiryTime,
      );
    } catch (e) {
      debugPrint(
        'TOKEN CHECK ERROR: $e',
      );

      return true;
    }
  }

  // ============================================================
  // START EXPIRY TIMER
  // ============================================================

  Future<void> _startTokenExpiryTimer() async {
    _tokenExpiryTimer?.cancel();

    final token = await getAccessToken();

    if (token == null || token.isEmpty) {
      return;
    }

    final expiryDate = _getTokenExpiryDate(token);

    if (expiryDate == null) {
      debugPrint(
        'TOKEN EXPIRY: No expiry found',
      );

      return;
    }

    final duration = expiryDate.difference(
      DateTime.now(),
    );

    if (duration.isNegative ||
        duration == Duration.zero) {
      await logout();

      return;
    }

    debugPrint(
      'TOKEN EXPIRY TIMER STARTED: $expiryDate',
    );

    _tokenExpiryTimer = Timer(
      duration,
      () async {
        debugPrint(
          'TOKEN EXPIRED - AUTOMATIC LOGOUT',
        );

        await logout();
      },
    );
  }

  // ============================================================
  // GET TOKEN EXPIRY
  // ============================================================

  DateTime? _getTokenExpiryDate(
    String token,
  ) {
    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];

      final normalized = base64Url.normalize(
        payload,
      );

      final payloadMap = jsonDecode(
        utf8.decode(
          base64Url.decode(normalized),
        ),
      );

      if (payloadMap is! Map) {
        return null;
      }

      final exp = payloadMap['exp'];

      if (exp == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(
        (exp as num).toInt() * 1000,
      );
    } catch (e) {
      debugPrint(
        'GET TOKEN EXPIRY ERROR: $e',
      );

      return null;
    }
  }

  // ============================================================
  // GET SAVED ACCESS TOKEN
  // ============================================================

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(
      StorageKeys.accessToken,
    );
  }

  // ============================================================
  // 401 HANDLER
  // ============================================================

  Future<void> _handleUnauthorized() async {
    debugPrint(
      'AUTH CONTROLLER: 401 RECEIVED',
    );

    await logout(
      showMessage: true,
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout({
    bool navigateToLogin = true,
    bool showMessage = false,
  }) async {
    // Prevent multiple simultaneous logout calls.
    if (_isLoggingOut) {
      return;
    }

    _isLoggingOut = true;

    try {
      _tokenExpiryTimer?.cancel();
      _tokenExpiryTimer = null;

      final prefs =
          await SharedPreferences.getInstance();

      // ========================================================
      // CLEAR ALL AUTH DATA
      // ========================================================

      await prefs.remove(
        StorageKeys.accessToken,
      );

      await prefs.remove(
        StorageKeys.refreshToken,
      );

      await prefs.remove(
        StorageKeys.userId,
      );

      await prefs.remove(
        StorageKeys.userEmail,
      );

      await prefs.remove(
        StorageKeys.userRole,
      );

      await prefs.remove(
        StorageKeys.firstName,
      );

      await prefs.remove(
        StorageKeys.lastName,
      );

      debugPrint(
        'USER LOGGED OUT',
      );

      if (showMessage) {
        Fluttertoast.showToast(
          msg: 'Session expired. Please sign in again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }

      // ========================================================
      // NAVIGATE TO LOGIN
      // ========================================================

      if (navigateToLogin) {
        Get.offAll(
          () => const LoginScreen(),
        );
      }
    } finally {
      _isLoggingOut = false;
    }
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    _tokenExpiryTimer?.cancel();
    _tokenExpiryTimer = null;

    _apiClient.dispose();

    super.onClose();
  }
}

