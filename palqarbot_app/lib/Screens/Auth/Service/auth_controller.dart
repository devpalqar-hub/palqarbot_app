import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:palqarbot_app/Screens/Inbox/service/inbox_controller.dart';
import 'package:palqarbot_app/Screens/Settings/service/profile_setting_controller.dart';
import 'package:palqarbot_app/Screens/bot/service/bot_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:palqarbot_app/Core/Constants/api_constants.dart';
import 'package:palqarbot_app/Core/Constants/storage_keys.dart';
import 'package:palqarbot_app/Core/Network/api_client.dart';
import 'package:palqarbot_app/Screens/Auth/login_screen.dart';

class AuthController extends GetxController {
  late final ApiClient _apiClient;

  bool isLoading = false;
  bool _isLoggingOut = false;

  Timer? _tokenExpiryTimer;

  AuthController() {
    _apiClient = ApiClient(onUnauthorized: _handleUnauthorized);
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    update();

    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: {'email': email, 'password': password},
      );

      if (!response.success || response.data is! Map) {
        debugPrint('LOGIN FAILED: ${response.message}');
        return false;
      }

      final data = Map<String, dynamic>.from(response.data as Map);

      final saved = await _saveAuthData(data);

      if (!saved) {
        debugPrint('LOGIN FAILED: Access token not found');
        return false;
      }

      await _startTokenExpiryTimer();

      debugPrint('LOGIN SUCCESS');
      return true;
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

      if (!response.success || response.data is! Map) {
        debugPrint('REGISTER FAILED: ${response.message}');
        return false;
      }

      final data = Map<String, dynamic>.from(response.data as Map);

      final saved = await _saveAuthData(data);

      if (!saved) {
        debugPrint('REGISTER FAILED: Access token not found');
        return false;
      }

      await _startTokenExpiryTimer();

      debugPrint('REGISTER SUCCESS');
      debugPrint('ACCESS TOKEN SAVED');

      return true;
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

  Future<bool> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = data['accessToken'];

    if (accessToken == null || accessToken.toString().trim().isEmpty) {
      debugPrint('ACCESS TOKEN NOT FOUND IN RESPONSE');
      return false;
    }

    await prefs.setString(StorageKeys.accessToken, accessToken.toString());

    final refreshToken = data['refreshToken'];

    if (refreshToken != null && refreshToken.toString().isNotEmpty) {
      await prefs.setString(StorageKeys.refreshToken, refreshToken.toString());
    }

    final user = data['user'];

    if (user is Map) {
      final userData = Map<String, dynamic>.from(user);

      final userFields = <String, String>{
        'id': StorageKeys.userId,
        'email': StorageKeys.userEmail,
        'role': StorageKeys.userRole,
        'firstName': StorageKeys.firstName,
        'lastName': StorageKeys.lastName,
      };

      for (final entry in userFields.entries) {
        final value = userData[entry.key];

        if (value != null) {
          await prefs.setString(entry.value, value.toString());
        }
      }
    }

    final savedToken = prefs.getString(StorageKeys.accessToken);

    if (savedToken == null || savedToken.isEmpty) {
      debugPrint('ERROR: ACCESS TOKEN WAS NOT SAVED');
      return false;
    }

    debugPrint('AUTH DATA SAVED SUCCESSFULLY');
    return true;
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();

    if (token == null || token.isEmpty) {
      debugPrint('IS LOGGED IN: NO TOKEN');
      return false;
    }

    if (_isTokenExpired(token)) {
      debugPrint('IS LOGGED IN: TOKEN EXPIRED');

      await logout(navigateToLogin: false);
      return false;
    }

    debugPrint('IS LOGGED IN: TOKEN VALID');

    await _startTokenExpiryTimer();
    return true;
  }

  // ============================================================
  // TOKEN EXPIRY
  // ============================================================

  Map<String, dynamic>? _decodeTokenPayload(String token) {
    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        return null;
      }

      final normalized = base64Url.normalize(parts[1]);

      final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));

      if (decoded is! Map) {
        return null;
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      debugPrint('TOKEN DECODE ERROR: $e');
      return null;
    }
  }

  bool _isTokenExpired(String token) {
    final payload = _decodeTokenPayload(token);

    // Do not reject opaque/non-JWT tokens based on decoding alone.
    // The backend remains responsible for validating these tokens.
    if (payload == null) {
      return false;
    }

    final exp = payload['exp'];

    if (exp == null) {
      return false;
    }

    if (exp is! num) {
      return true;
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);

    return !expiryTime.isAfter(DateTime.now());
  }

  DateTime? _getTokenExpiryDate(String token) {
    final payload = _decodeTokenPayload(token);
    final exp = payload?['exp'];

    if (exp is! num) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
  }

  // ============================================================
  // START EXPIRY TIMER
  // ============================================================

  Future<void> _startTokenExpiryTimer() async {
    _tokenExpiryTimer?.cancel();
    _tokenExpiryTimer = null;

    final token = await getAccessToken();

    if (token == null || token.isEmpty) {
      return;
    }

    final expiryDate = _getTokenExpiryDate(token);

    if (expiryDate == null) {
      debugPrint('TOKEN EXPIRY: No expiry claim found');
      return;
    }

    final duration = expiryDate.difference(DateTime.now());

    if (duration <= Duration.zero) {
      await logout();
      return;
    }

    debugPrint('TOKEN EXPIRY TIMER STARTED: $expiryDate');

    _tokenExpiryTimer = Timer(duration, () async {
      debugPrint('TOKEN EXPIRED - AUTOMATIC LOGOUT');
      await logout();
    });
  }

  // ============================================================
  // GET ACCESS TOKEN
  // ============================================================

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(StorageKeys.accessToken);
  }

  // ============================================================
  // UNAUTHORIZED HANDLER
  // ============================================================

  Future<void> _handleUnauthorized() async {
    debugPrint('AUTH CONTROLLER: 401 RECEIVED');

    await logout(showMessage: true);
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout({
    bool navigateToLogin = true,
    bool showMessage = false,
  }) async {
    if (_isLoggingOut) return;

    _isLoggingOut = true;

    try {
      debugPrint('AUTH: Logging out');

      _tokenExpiryTimer?.cancel();
      _tokenExpiryTimer = null;

      final prefs = await SharedPreferences.getInstance();

      // Clear authentication credentials.
      await prefs.remove(StorageKeys.accessToken);
      await prefs.remove(StorageKeys.refreshToken);
      await prefs.remove(StorageKeys.userId);
      await prefs.remove(StorageKeys.userEmail);
      await prefs.remove(StorageKeys.userRole);
      await prefs.remove(StorageKeys.firstName);
      await prefs.remove(StorageKeys.lastName);

      // Clear old profile, bot and inbox controllers.
      await _clearUserScopedControllers();

      debugPrint('AUTH: Logout completed; cached state cleared');

      if (showMessage) {
        await Fluttertoast.showToast(
          msg: 'Session expired. Please sign in again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }

      if (navigateToLogin) {
        Get.offAll(() => const LoginScreen());
      }
    } catch (e, stackTrace) {
      debugPrint('AUTH LOGOUT ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
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

  // ============================================================
  // CLEAR USER-SPECIFIC STATE
  // ============================================================

  Future<void> _clearUserScopedControllers() async {
    debugPrint('AUTH: Clearing previous user state');

    // Stop old polling and socket connections.
    if (Get.isRegistered<InboxController>()) {
      await Get.delete<InboxController>(force: true);
      debugPrint('AUTH: InboxController disposed');
    }

    // Remove cached bot state.
    if (Get.isRegistered<BotController>()) {
      await Get.delete<BotController>(force: true);
      debugPrint('AUTH: BotController disposed');
    }

    // Remove the old profile and settings cache.
    if (Get.isRegistered<ProfileSettingsController>()) {
      await Get.delete<ProfileSettingsController>(force: true);
      debugPrint('AUTH: ProfileSettingsController disposed');
    }

    // Remove any persisted onboarding request from the previous session.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_onboarding_request_id');

    debugPrint('AUTH: Previous user state cleared');
  }
}
