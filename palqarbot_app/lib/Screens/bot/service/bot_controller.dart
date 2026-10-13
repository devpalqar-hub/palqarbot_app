import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Screens/Settings/service/profile_setting_controller.dart';

class BotController extends GetxController {
  // ===========================================================================
  // CONTROLLER
  // ===========================================================================

  ProfileSettingsController get profileSettingsController {
    if (!Get.isRegistered<ProfileSettingsController>()) {
      Get.put(ProfileSettingsController());
    }

    return Get.find<ProfileSettingsController>();
  }

  // ===========================================================================
  // STATES
  // ===========================================================================

  bool isSaving = false;
  bool isLoading = false;

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  String get profileId {
    return profileSettingsController.profileId;
  }

  String get systemPrompt {
    return profileSettingsController.systemPrompt;
  }

  // ===========================================================================
  // LOAD SYSTEM PROMPT
  // ===========================================================================

  Future<bool> loadSystemPrompt() async {
    isLoading = true;
    update();

    try {
      final settingsController = profileSettingsController;

      // ---------------------------------------------------------------
      // If profile is already loaded, no need to call API again
      // ---------------------------------------------------------------

      if (settingsController.selectedProfile != null) {
        isLoading = false;
        update();

        return true;
      }

      // ---------------------------------------------------------------
      // Load user + selected profile
      // ---------------------------------------------------------------

      final success = await settingsController.loadSettings();

      isLoading = false;
      update();

      if (!success) {
        debugPrint('BOT: Failed to load profile settings');

        return false;
      }

      debugPrint('BOT: System prompt loaded successfully');

      return true;
    } catch (e, stackTrace) {
      debugPrint('BOT: Load system prompt exception: $e');

      debugPrint('$stackTrace');

      isLoading = false;
      update();

      return false;
    }
  }

  // ===========================================================================
  // UPDATE SYSTEM PROMPT
  // ===========================================================================

  Future<bool> updateSystemPrompt(String prompt) async {
    final settingsController = profileSettingsController;

    final id =
        settingsController.selectedProfile?.id ?? settingsController.profileId;

    if (id.isEmpty) {
      debugPrint('BOT: Profile ID is empty');

      return false;
    }

    isSaving = true;
    update();

    final currentProfile = settingsController.selectedProfile;

    if (currentProfile == null) {
      isSaving = false;
      update();

      debugPrint('BOT: Selected profile is null');

      return false;
    }

    try {
      final success = await settingsController.updateProfile(
        id: id,
        name: currentProfile.name,
        systemPrompt: prompt,
        autoReplyEnabled: currentProfile.autoReplyEnabled,
      );

      if (success) {
        debugPrint('BOT: System prompt updated successfully');
      } else {
        debugPrint('BOT: Failed to update system prompt');
      }

      return success;
    } catch (e, stackTrace) {
      debugPrint('BOT: Update system prompt exception: $e');

      debugPrint('$stackTrace');

      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void onClose() {
    super.onClose();
  }
}
