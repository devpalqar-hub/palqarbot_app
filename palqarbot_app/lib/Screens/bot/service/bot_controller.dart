
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Constants/api_constants.dart';
import 'package:palqarbot_app/Core/Network/api_client.dart';
import 'package:palqarbot_app/Screens/Settings/service/profile_setting_controller.dart';

class BotController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  bool isSaving = false;

  // Get the existing ProfileSettingsController
  ProfileSettingsController get profileSettingsController {
    if (!Get.isRegistered<ProfileSettingsController>()) {
      Get.put(ProfileSettingsController());
    }

    return Get.find<ProfileSettingsController>();
  }

  // ============================================================
  // UPDATE SYSTEM PROMPT
  // ============================================================

  Future<bool> updateSystemPrompt(String prompt) async {
    final profileId = profileSettingsController.profileId;

    if (profileId.isEmpty) {
      debugPrint(
        'BOT: Profile ID is empty',
      );

      return false;
    }

    isSaving = true;
    update();


    final endpoint = ApiConstants.systemPrompt(profileId);

    debugPrint('');
    debugPrint('==========================================');
    debugPrint('BOT - UPDATE SYSTEM PROMPT');
    debugPrint('==========================================');
    debugPrint('PROFILE ID: $profileId');
    debugPrint('ENDPOINT  : $endpoint');
    debugPrint('==========================================');
    debugPrint('');

    try {
      final response = await _apiClient.patch(
        endpoint,
        body: {
          'systemPrompt': prompt,
        },
      );

      if (response.success) {
        debugPrint(
          'BOT: System prompt updated successfully',
        );

        return true;
      }

      debugPrint(
        'BOT: Failed to update system prompt',
      );

      debugPrint(
        'MESSAGE: ${response.message}',
      );

      return false;
    } catch (e, stackTrace) {
      debugPrint(
        'BOT: Update system prompt exception: $e',
      );

      debugPrint('$stackTrace');

      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  @override
  void onClose() {
    _apiClient.dispose();
    super.onClose();
  }
}
