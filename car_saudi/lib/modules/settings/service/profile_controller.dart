import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/modules/settings/model/profile_model.dart';
import 'package:villas_qatar/Core/utils/app_toast.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  ProfileModel? profile;

  bool isLoading = false;
  bool isSaving = false;

  /// Strips the `Exception: ` prefix `ApiHandler` wraps error bodies in,
  /// so the backend's actual message (e.g. "Please provide a valid phone
  /// number with country code") reaches the user as-is.
  String _extractErrorMessage(Object e, String fallback) {
    final text = e.toString();
    if (text.isEmpty) return fallback;
    return text.startsWith("Exception: ") ? text.substring(11) : text;
  }

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    if (!StorageService.isLoggedIn()) {
      return;
    }

    try {
      isLoading = true;
      update();

      final response = await ApiHandler.get(ApiEndpoints.authMe);

      profile = ProfileModel.fromJson(response);

      nameController.text = profile!.name;
      emailController.text = profile!.email;
      phoneController.text = profile!.phone;

      await StorageService.saveProfile(response);
    } catch (e) {
      debugPrint("Fetch Profile Error: $e");

      // /auth/me failed (network hiccup, expired token mid-flow, etc.) -
      // fall back to whatever was cached from login rather than leaving
      // the screen stuck on "Guest"/"No Email" with no explanation.
      final cached = StorageService.getProfile();
      if (cached != null) {
        try {
          profile = ProfileModel.fromJson(cached);
          nameController.text = profile!.name;
          emailController.text = profile!.email;
          phoneController.text = profile!.phone;
        } catch (e) {
          debugPrint("Cached Profile Parse Error: $e");
        }
      }
    } finally {
      isLoading = false;
      update();
    }
  }
Future<bool> updateProfile() async {
  try {
    isSaving = true;
    update();

    final body = <String, dynamic>{
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
    };

    if (passwordController.text.trim().isNotEmpty) {
      body["password"] = passwordController.text.trim();
    }

    final response = await ApiHandler.patch(
      ApiEndpoints.myProfile,
      body: body,
    );

    profile = ProfileModel.fromJson(response);

    await StorageService.saveProfile(response);

    return true;
  } catch (e) {
    debugPrint("UPDATE PROFILE ERROR: $e");

    AppToast.show(
      msg: _extractErrorMessage(e, "Failed to update profile".tr),
    );

    return false;
  } finally {
    isSaving = false;
    update();
  }
}
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
