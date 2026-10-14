import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static SharedPreferences? _prefs;

  /// Initialize in main()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String isLoggedInKey = 'is_logged_in';
  static const String profileKey = 'profile';
  static const String languageKey = 'language';
  static const String locationKey = 'saved_location';

  /// ================= TOKEN =================

  static Future<bool> saveToken(String token) async {
    return await _prefs!.setString(accessTokenKey, token);
  }

  static String? getToken() {
    return _prefs!.getString(accessTokenKey);
  }

  static Future<bool> removeToken() async {
    return await _prefs!.remove(accessTokenKey);
  }

  /// ================= REFRESH TOKEN =================

  static Future<bool> saveRefreshToken(String token) async {
    return await _prefs!.setString(refreshTokenKey, token);
  }

  static String? getRefreshToken() {
    return _prefs!.getString(refreshTokenKey);
  }

  /// ================= LOGIN STATUS =================

  static Future<bool> setLoggedIn(bool value) async {
    return await _prefs!.setBool(isLoggedInKey, value);
  }

  static bool isLoggedIn() {
    return _prefs!.getBool(isLoggedInKey) ?? false;
  }

  /// ================= PROFILE =================

  static Future<bool> saveProfile(Map<String, dynamic> profile) async {
    return await _prefs!.setString(
      profileKey,
      jsonEncode(profile),
    );
  }

  static Map<String, dynamic>? getProfile() {
    final data = _prefs!.getString(profileKey);

    if (data == null) return null;

    return jsonDecode(data);
  }

  static Future<bool> removeProfile() async {
    return await _prefs!.remove(profileKey);
  }

  static String getUserId() {
  final Map<String, dynamic>? profile =
      getProfile();

  return profile?['id']
          ?.toString()
          .trim() ??
      '';
}

  /// ================= LANGUAGE =================

  static Future<bool> saveLanguage(String language) async {
    return await _prefs!.setString(languageKey, language);
  }

  static String getLanguage() {
    return _prefs!.getString(languageKey) ?? "en";
  }

  /// Unlike [getLanguage], returns null when the user has never
  /// explicitly picked a language - lets the caller fall back to
  /// device-locale auto-detection instead of forcing "en".
  static String? getSavedLanguageOrNull() {
    return _prefs!.getString(languageKey);
  }

  /// ================= LOCATION =================

  static Future<bool> saveLocation(Map<String, dynamic> location) async {
    return await _prefs!.setString(locationKey, jsonEncode(location));
  }

  static Map<String, dynamic>? getLocation() {
    final data = _prefs!.getString(locationKey);

    if (data == null) return null;

    return jsonDecode(data);
  }

  static Future<bool> removeLocation() async {
    return await _prefs!.remove(locationKey);
  }

  /// ================= LOGOUT =================

  static Future<void> logout() async {
    await _prefs!.remove(accessTokenKey);
    await _prefs!.remove(refreshTokenKey);
    await _prefs!.remove(profileKey);
    await _prefs!.setBool(isLoggedInKey, false);
  }

  /// ================= CLEAR =================

  static Future<void> clear() async {
    await _prefs!.clear();
  }
}