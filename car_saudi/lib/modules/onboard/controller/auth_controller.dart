import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:country_pickers/utils/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:villas_qatar/Core/constants/social_auth_config.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/services/push_notification_service.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/modules/dealer_dashboard/views/dealer_analytics_screen.dart';
import 'package:villas_qatar/modules/mainscreen/mainscreen.dart';
import 'package:villas_qatar/modules/onboard/views/welcome_screen.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class AuthController extends GetxController {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // Dealer portal login (email/username + password) — separate
  // controllers from the buyer/renter [emailController] above since
  // that one belongs to Complete Profile, not sign-in.
  final dealerIdentifierController = TextEditingController();
  final dealerPasswordController = TextEditingController();

  bool isLoading = false;
  bool isNewUser = false;
  String selectedCountry = "QA";
  String selectedCountryCode = "+974";
  String phoneNumber = "";
  String? accessToken;
  Map<String, dynamic>? profile;

  // Inline validation / server error state — surfaced under the
  // relevant field in the UI in addition to the toast, so the error
  // is visible even where a toast alone gets missed.
  String? phoneError;
  String? otpError;
  String? nameError;
  String? emailError;
  String? dealerIdentifierError;
  String? dealerPasswordError;

  @override
  void onInit() {
  super.onInit();

  accessToken = StorageService.getToken();
  profile = StorageService.getProfile();

  phoneController.addListener(() {
    phoneNumber =
        "$selectedCountryCode${phoneController.text.trim()}";
  });


}
 

  @override
  void reset() {
    selectedCountry = "QA";
selectedCountryCode = "+974";
    phoneController.clear();
    otpController.clear();
    nameController.clear();
    emailController.clear();
    dealerIdentifierController.clear();
    dealerPasswordController.clear();

    isLoading = false;
    isNewUser = false;
    selectedCountryCode = "+974";
    phoneNumber = "";
    accessToken = null;
    profile = null;

    phoneError = null;
    otpError = null;
    nameError = null;
    emailError = null;
    dealerIdentifierError = null;
    dealerPasswordError = null;

    update();
  }

  /// Splash Navigation
  /// (Kept in sync with [SplashScreen]'s own navigation logic, which is
  /// what actually runs on launch - this is unused internally but left
  /// correct in case anything starts calling it.)
  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));

    final token = StorageService.getToken();

    if (token != null && token.isNotEmpty) {
      final role = profile?['role']?.toString().toUpperCase();

      if (role == "DEALER") {
        Get.to(() => const DealerAnalyticsScreen());
      } else {
        Get.to(MainScreen());
      }
    } else {
      Get.to(WelcomeScreen());
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    update();
  }

  /// Strips the "Exception: " prefix ApiHandler wraps server errors in
  /// (e.g. duplicate email / phone conflicts) so the real backend
  /// message reaches the user instead of a generic fallback.
  String _extractErrorMessage(Object e, String fallback) {
    final text = e.toString();
    if (text.isEmpty) return fallback;
    return text.startsWith("Exception: ") ? text.substring(11) : text;
  }

  /// ---------------- SEND OTP ----------------
  Future<bool> sendOtp() async {
  if (!validatePhone()) return false;

  try {
    _setLoading(true);

    await ApiHandler.post(
      ApiEndpoints.sendOtp,
      body: {
        "phone": phoneNumber,
      },
    );

    return true;
  } catch (e) {
    debugPrint("Send OTP Error: $e");

    phoneError = _extractErrorMessage(e, "Failed to send OTP".tr);

    AppToast.show(msg: phoneError!);

    update();

    return false;
  } finally {
    _setLoading(false);
  }
}

  /// ---------------- VERIFY OTP ----------------
  Future<bool> verifyOtp() async {
  if (!validatePhone()) return false;
  if (!validateOtp()) return false;

  try {
    _setLoading(true);

    final response = await ApiHandler.post(
      ApiEndpoints.verifyOtp,
      body: {
        "phone": phoneNumber,
        "otp": otpController.text.trim(),
      },
    );

    await _saveUserSession(response);

    return true;
  } catch (e) {
    debugPrint("Verify OTP Error: $e");

    otpError = _extractErrorMessage(e, "Invalid OTP. Please try again.".tr);

    AppToast.show(msg: otpError!);

    update();

    return false;
  } finally {
    _setLoading(false);
  }
}

  /// ---------------- DEALER LOGIN (email/password) ----------------
  bool _validateDealerLogin() {
    dealerIdentifierError = null;
    dealerPasswordError = null;

    if (dealerIdentifierController.text.trim().isEmpty) {
      dealerIdentifierError = "Please enter your email or phone".tr;
    }

    if (dealerPasswordController.text.isEmpty) {
      dealerPasswordError = "Please enter your password".tr;
    }

    if (dealerIdentifierError != null || dealerPasswordError != null) {
      AppToast.show(
        msg: dealerIdentifierError ?? dealerPasswordError!,
      );
      update();
      return false;
    }

    return true;
  }

  Future<bool> dealerLogin() async {
    if (!_validateDealerLogin()) return false;

    try {
      _setLoading(true);

      final response = await ApiHandler.post(
        ApiEndpoints.login,
        body: {
          "identifier": dealerIdentifierController.text.trim(),
          "password": dealerPasswordController.text,
        },
      );

      await _saveUserSession(response);

      return true;
    } catch (e) {
      debugPrint("Dealer Login Error: $e");

      dealerPasswordError = _extractErrorMessage(
        e,
        "Invalid email/phone or password.".tr,
      );

      AppToast.show(msg: dealerPasswordError!);

      update();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// ---------------- GOOGLE LOGIN ----------------
  /// Federated auth per
  /// https://firebase.google.com/docs/auth/flutter/federated-auth:
  /// sign in to FirebaseAuth with a GoogleAuthProvider credential built
  /// from the native Google Sign-In SDK tokens, then take the resulting
  /// *Firebase* ID token (not the raw Google SDK token) and send that to
  /// our backend (POST /api/auth/google), which is equivalent to
  /// POST /auth/firebase restricted to the Google provider.
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);

      final GoogleSignInAccount? account = await GoogleSignIn().signIn();
      if (account == null) {
        // User cancelled the picker.
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await account.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final String? firebaseIdToken =
          await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception("Failed to get Firebase ID token");
      }

      final response = await ApiHandler.post(
        ApiEndpoints.googleAuth,
        body: {"idToken": firebaseIdToken},
      );

      await _saveUserSession(response);

      return true;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");

      AppToast.show(
        msg: "Google sign-in failed".tr,
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// ---------------- APPLE LOGIN ----------------
  /// Federated auth per
  /// https://firebase.google.com/docs/auth/flutter/federated-auth:
  /// sign in to FirebaseAuth with an OAuthProvider('apple.com')
  /// credential built from the native Sign in with Apple SDK's identity
  /// token + a nonce, then take the resulting *Firebase* ID token (not
  /// the raw Apple SDK token) and send that to our backend
  /// (POST /api/auth/apple), which is equivalent to POST /auth/firebase
  /// restricted to the Apple provider.
  ///
  /// Apple only hands back the user's name and email on the very first
  /// authorization for this app - every sign-in after that returns null
  /// for them, so whatever the native SDK gives us here is forwarded
  /// as-is to the backend on this call only.
  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);

      // A raw nonce is required to link the Apple identity token to this
      // specific Firebase sign-in attempt and prevent replay attacks.
      // Apple gets the SHA-256 hash of it; Firebase gets the raw value.
      final String rawNonce = _generateNonce();
      final String hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
        // Apple has no native SDK on Android - the plugin falls back to
        // a web OAuth flow there, which needs the Services ID/return
        // URL registered in the Apple Developer portal. See
        // SocialAuthConfig for setup steps. Ignored on iOS.
        webAuthenticationOptions: Platform.isAndroid
            ? WebAuthenticationOptions(
                clientId: SocialAuthConfig.appleServiceId,
                redirectUri: Uri.parse(SocialAuthConfig.appleRedirectUri),
              )
            : null,
      );

      final String? identityToken = credential.identityToken;

      if (identityToken == null) {
        throw Exception("Failed to get Apple identity token");
      }

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      final String? firebaseIdToken =
          await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception("Failed to get Firebase ID token");
      }

      final body = <String, dynamic>{"idToken": firebaseIdToken};

      if (credential.givenName != null) body["firstName"] = credential.givenName;
      if (credential.familyName != null) body["lastName"] = credential.familyName;
      if (credential.email != null) body["email"] = credential.email;

      final response = await ApiHandler.post(
        ApiEndpoints.appleAuth,
        body: body,
      );

      await _saveUserSession(response);

      return true;
    } catch (e) {
      debugPrint("Apple Sign-In Error: $e");

      AppToast.show(
        msg: "Apple sign-in failed".tr,
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Generates a cryptographically random nonce for the Apple Sign-In /
  /// FirebaseAuth replay-protection handshake.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  //----------Comlete profile -------------

  /// Client-side validation for the complete-profile form. Sets
  /// [nameError] / [emailError] so the UI can show an inline message
  /// under each field, in addition to a toast, and returns false
  /// without hitting the network when anything required is blank or
  /// malformed.
  bool validateProfile() {
    nameError = null;
    emailError = null;

    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty) {
      nameError = "Please enter your full name".tr;
    }

    if (email.isEmpty) {
      emailError = "Please enter your email address".tr;
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      emailError = "Please enter a valid email address".tr;
    }

    if (nameError != null || emailError != null) {
      AppToast.show(msg: nameError ?? emailError!);
      update();
      return false;
    }

    return true;
  }

  /// ---------------- COMPLETE PROFILE ----------------
  Future<bool> completeProfile() async {
    if (!validateProfile()) return false;

    try {
      _setLoading(true);

      final body = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneNumber,
      };

      debugPrint("========== COMPLETE PROFILE ==========");
      debugPrint("URL: ${ApiHandler.baseUrl}${ApiEndpoints.completeProfile}");
      debugPrint("METHOD: POST");
      debugPrint("HEADERS:");
      debugPrint({"Authorization": "Bearer $accessToken"}.toString());
      debugPrint("BODY:");
      debugPrint(body.toString());

      final response = await ApiHandler.post(
        ApiEndpoints.completeProfile,
        headers: {"Authorization": "Bearer $accessToken"},
        body: body,
      );

      debugPrint("========== RESPONSE ==========");
      debugPrint(response.toString());

      if (response["profile"] != null) {
        profile = Map<String, dynamic>.from(response["profile"]);
        await StorageService.saveProfile(profile!);
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint("========== COMPLETE PROFILE ERROR ==========");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      // Surface the real backend message (e.g. "Email already in use")
      // instead of failing silently — previously this just returned
      // false with no feedback to the user at all.
      final message = _extractErrorMessage(
        e,
        "Failed to complete profile. Please try again.".tr,
      );

      emailError = message.toLowerCase().contains("email") ? message : null;

      AppToast.show(msg: message);

      update();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveUserSession(Map<String, dynamic> response) async {
    isNewUser = response["isNew"] ?? false;
    accessToken = response["access_token"];

    if (response["profile"] != null) {
      profile = Map<String, dynamic>.from(response["profile"]);
    }

    if (accessToken != null && accessToken!.isNotEmpty) {
      await StorageService.saveToken(accessToken!);
      await StorageService.setLoggedIn(true);
    }

    // Social logins (Google/Apple) for a brand-new user return only
    // { isNew: true, access_token } - no "profile" - even though the
    // backend has already pre-filled name/email from the provider.
    // Fetch it now so the name/email show up immediately instead of
    // staying blank ("Guest"/"No Email") until something else happens
    // to call /auth/me later.
    if (profile == null && accessToken != null && accessToken!.isNotEmpty) {
      await _fetchAndCacheProfile();
    }

    if (profile != null) {
      await StorageService.saveProfile(profile!);
    }

    // Register this device's FCM token now that we have an access
    // token - the endpoint requires auth and re-assigns the token to
    // whichever account registers it, so this must run right after
    // login, not before.
    unawaited(PushNotificationService.registerCurrentToken());

    update();
  }

  /// Fetches the authenticated user's profile from `/auth/me` and stores
  /// it on [profile]. Used right after a social login response that
  /// didn't include a "profile" (new-user case) so the name/email are
  /// available immediately instead of only after some other screen
  /// happens to call this endpoint.
  Future<void> _fetchAndCacheProfile() async {
    try {
      final response = await ApiHandler.get(ApiEndpoints.authMe);

      if (response is Map<String, dynamic>) {
        profile = response;
      }
    } catch (e) {
      debugPrint("Fetch Profile Error: $e");
    }
  }

  Future<void> logout() async {
    await StorageService.logout();

    // Sign out of the native Google session too - otherwise the device
    // keeps the account cached and the next "Sign in with Google" tap
    // silently reuses it instead of showing the account picker.
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint("Google Sign-Out Error: $e");
    }

    // Also sign out of FirebaseAuth - it's only used as a pass-through to
    // mint the ID token we send our backend, but leaving it signed in
    // would let a later Firebase sign-in silently succeed without the
    // provider prompt.
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("Firebase Sign-Out Error: $e");
    }

    phoneController.clear();
    otpController.clear();
    nameController.clear();
    emailController.clear();

    accessToken = null;
    profile = null;
    isNewUser = false;
    phoneNumber = "";
     selectedCountry = "QA";
     selectedCountryCode = "+974";
    isLoading = false;

    update();

    Get.offAll(() => WelcomeScreen());
  }


  void changeCountry(String isoCode) {
  selectedCountry = isoCode;

  final country = CountryPickerUtils.getCountryByIsoCode(isoCode);
  selectedCountryCode = "+${country.phoneCode}";

  phoneNumber =
      "$selectedCountryCode${phoneController.text.trim()}";

  update();
}


bool validatePhone() {
  final phone = phoneController.text.trim();

  if (phone.isEmpty) {
    phoneError = "Please enter your WhatsApp number".tr;
    AppToast.show(msg: phoneError!);
    update();
    return false;
  }

  if (!RegExp(r'^[0-9]{6,15}$').hasMatch(phone)) {
    phoneError = "Please enter a valid phone number".tr;
    AppToast.show(msg: phoneError!);
    update();
    return false;
  }

  phoneError = null;
  phoneNumber = "$selectedCountryCode$phone";
  return true;
}



bool validateOtp() {
  final otp = otpController.text.trim();

  if (otp.isEmpty) {
    otpError = "Please enter the OTP".tr;
    AppToast.show(msg: otpError!);
    update();
    return false;
  }

  if (otp.length != 6) {
    otpError = "OTP must be 6 digits".tr;
    AppToast.show(msg: otpError!);
    update();
    return false;
  }

  otpError = null;
  return true;
}
}
