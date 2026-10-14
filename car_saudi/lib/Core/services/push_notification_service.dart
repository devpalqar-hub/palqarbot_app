import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';

/// ================================================================
/// BACKGROUND MESSAGE HANDLER
/// ================================================================
///
/// Must be a top-level (or static) function - Firebase runs it in a
/// separate isolate when a push arrives while the app is backgrounded
/// or terminated. Nothing to do here yet beyond letting the OS show
/// the notification; add custom handling (e.g. local DB writes)
/// later if needed.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("FCM BACKGROUND MESSAGE: ${message.messageId}");
}

/// ================================================================
/// PUSH NOTIFICATION SERVICE
/// ================================================================
///
/// Registers this device's FCM token with the backend
/// (POST /api/users/fcm-token):
///   - once, right after login (see AuthController._saveUserSession)
///   - again on cold start for an already-logged-in user, in case the
///     token changed while the app wasn't running
///   - and every time Firebase issues a refreshed token, via
///     [FirebaseMessaging.onTokenRefresh]
///
/// Tokens are unique on the backend - registering a token already
/// tied to another account re-assigns it to the current user, so we
/// only ever call the endpoint while the user is actually logged in.
class PushNotificationService {
  PushNotificationService._();

  static bool _tokenRefreshListenerAttached = false;

  /// Call once at app startup, after Firebase.initializeApp().
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // iOS: without this, a token can come back null until the user
    // has granted permission and APNs has handed back a device token.
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    if (!_tokenRefreshListenerAttached) {
      _tokenRefreshListenerAttached = true;

      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        debugPrint("FCM TOKEN REFRESHED: $token");
        _registerToken(token);
      });
    }
  }

  /// Call right after a successful login, and on cold start for a
  /// user who's already logged in - fetches the current token and
  /// (re)registers it. No-ops quietly if the user isn't logged in
  /// (the endpoint requires auth) or the token isn't available yet.
  static Future<void> registerCurrentToken() async {
    if (!StorageService.isLoggedIn()) {
      return;
    }

    try {
      final String? token = await FirebaseMessaging.instance.getToken();

      if (token == null || token.isEmpty) {
        debugPrint("FCM TOKEN: not available yet");
        return;
      }

      await _registerToken(token);
    } catch (e) {
      // Never let a push-registration failure block login/app start.
      debugPrint("FCM GET TOKEN ERROR: $e");
    }
  }

  static Future<void> _registerToken(String token) async {
    if (!StorageService.isLoggedIn()) {
      return;
    }

    try {
      debugPrint("REGISTER FCM TOKEN: $token");

      final response = await ApiHandler.post(
        ApiEndpoints.fcmToken,
        body: {
          "token": token,
          "platform": Platform.isIOS ? "IOS" : "ANDROID",
        },
      );

      debugPrint("REGISTER FCM TOKEN RESPONSE: $response");
    } catch (e) {
      debugPrint("REGISTER FCM TOKEN ERROR: $e");
    }
  }
}
