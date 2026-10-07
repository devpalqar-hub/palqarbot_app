import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Constants/api_constants.dart';
import 'package:palqarbot_app/Core/Network/api_client.dart';
import 'package:palqarbot_app/Screens/Settings/Model/profile_setting_model.dart';

class ProfileSettingsController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // ===========================================================================
  // LOADING STATES
  // ===========================================================================

  bool isLoading = false;
  bool isSaving = false;
  bool isDeleting = false;

  // ===========================================================================
  // MODELS
  // ===========================================================================

  /// Data returned from GET /auth/me
  ProfileSettingsModel? profileSettings;

  /// Data returned from GET /profiles/{profileId}
  ProfileModel? selectedProfile;

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  /// Profile ID is obtained from:
  ///
  /// /auth/me
  ///   -> userProfiles[0]
  ///      -> profile
  ///         -> id
  ///
  /// This ID is then used for:
  ///
  /// GET /profiles/{profileId}
  String get profileId {
    if (profileSettings == null) {
      return '';
    }

    if (profileSettings!.userProfiles.isEmpty) {
      return '';
    }

    return profileSettings!
        .userProfiles
        .first
        .profile
        .id;
  }

  ProfileModel? get profile {
    return selectedProfile;
  }

  // ===========================================================================
  // USER INFORMATION
  // ===========================================================================

  String get fullName {
    if (profileSettings == null) {
      return '';
    }

    return '${profileSettings!.firstName} '
        '${profileSettings!.lastName}'.trim();
  }

  String get email {
    return profileSettings?.email ?? '';
  }

  String get role {
    return profileSettings?.role ?? '';
  }

  // ===========================================================================
  // PROFILE INFORMATION
  // ===========================================================================

  String get profileName {
    return selectedProfile?.name ?? '';
  }

  String get profileSlug {
    return selectedProfile?.slug ?? '';
  }

  String get systemPrompt {
    return selectedProfile?.systemPrompt ?? '';
  }

  bool get autoReplyEnabled {
    return selectedProfile?.autoReplyEnabled ?? false;
  }

  // ===========================================================================
  // WHATSAPP
  // ===========================================================================

  WhatsAppConfigModel? get whatsappConfig {
    return selectedProfile?.whatsappConfig;
  }

  bool get whatsappEnabled {
    return whatsappConfig?.enabled ?? false;
  }

  bool get hasWhatsappConfig {
    return whatsappConfig != null;
  }

  String get whatsappPhoneNumberId {
    return whatsappConfig?.phoneNumberId ?? '';
  }

  String get whatsappBusinessAccountId {
    return whatsappConfig?.businessAccountId ?? '';
  }

  // ===========================================================================
  // INSTAGRAM
  // ===========================================================================

  InstagramConfigModel? get instagramConfig {
    return selectedProfile?.instagramConfig;
  }

  bool get instagramIsEnabled {
    return instagramConfig?.enabled ?? false;
  }

  bool get hasInstagramConfig {
    return instagramConfig != null;
  }

  String get instagramAccountId {
    return instagramConfig?.accountId ?? '';
  }

  // ===========================================================================
  // DEBUG REQUEST
  // ===========================================================================

  void _debugRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('==================================================');
    debugPrint('API REQUEST');
    debugPrint('==================================================');
    debugPrint('METHOD   : $method');
    debugPrint('ENDPOINT : $endpoint');

    if (body != null) {
      debugPrint('BODY     : $body');
    }

    debugPrint('==================================================');
    debugPrint('');
  }

  // ===========================================================================
  // DEBUG RESPONSE
  // ===========================================================================

  void _debugResponse({
    required String method,
    required String endpoint,
    required dynamic response,
  }) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('==================================================');
    debugPrint('API RESPONSE');
    debugPrint('==================================================');
    debugPrint('METHOD   : $method');
    debugPrint('ENDPOINT : $endpoint');
    debugPrint('SUCCESS  : ${response.success}');
    debugPrint('DATA     : ${response.data}');
    debugPrint('MESSAGE  : ${response.message}');
    debugPrint('==================================================');
    debugPrint('');
  }

  // ===========================================================================
  // GET USER INFORMATION
  // ===========================================================================
  //
  // GET /auth/me
  //
  // This API is ONLY used to get the user information and profile ID.
  //
  // Profile ID comes from:
  //
  // userProfiles[0].profile.id
  //
  // ===========================================================================

  Future<bool> getUserProfile() async {
    isLoading = true;
    update();

    const endpoint = ApiConstants.me;

    _debugRequest(
      method: 'GET',
      endpoint: endpoint,
    );

    try {
      final response = await _apiClient.get(endpoint);

      _debugResponse(
        method: 'GET',
        endpoint: endpoint,
        response: response,
      );

      if (!response.success ||
          response.data == null ||
          response.data is! Map) {
        debugPrint(
          'AUTH/ME FAILED: Invalid response',
        );

        isLoading = false;
        update();

        return false;
      }

      final data = Map<String, dynamic>.from(
        response.data as Map,
      );

      // -----------------------------------------------------------------------
      // Convert API response to model
      // -----------------------------------------------------------------------

      profileSettings =
          ProfileSettingsModel.fromJson(data);

      // -----------------------------------------------------------------------
      // Validate userProfiles
      // -----------------------------------------------------------------------

      if (profileSettings!.userProfiles.isEmpty) {
        debugPrint(
          'AUTH/ME: No user profiles found',
        );

        isLoading = false;
        update();

        return false;
      }

      // -----------------------------------------------------------------------
      // Profile ID
      // -----------------------------------------------------------------------

      debugPrint('');
      debugPrint('========== AUTH/ME PARSED ==========');
      debugPrint(
        'USER ID    : ${profileSettings!.id}',
      );
      debugPrint(
        'EMAIL      : ${profileSettings!.email}',
      );
      debugPrint(
        'ROLE       : ${profileSettings!.role}',
      );
      debugPrint(
        'FULL NAME  : $fullName',
      );
      debugPrint(
        'PROFILE ID : $profileId',
      );
      debugPrint('====================================');
      debugPrint('');

      isLoading = false;
      update();

      return profileId.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint(
        'AUTH/ME EXCEPTION: $e',
      );
      debugPrint(
        '$stackTrace',
      );

      isLoading = false;
      update();

      return false;
    }
  }

  // ===========================================================================
  // GET SINGLE PROFILE
  // ===========================================================================
  //
  // GET /profiles/{profileId}
  //
  // ===========================================================================

  Future<bool> getProfile(String id) async {
    if (id.isEmpty) {
      debugPrint(
        'GET PROFILE: Profile ID is empty',
      );
      return false;
    }

    isLoading = true;
    update();

    final endpoint = ApiConstants.profile(id);

    _debugRequest(
      method: 'GET',
      endpoint: endpoint,
    );

    try {
      final response = await _apiClient.get(endpoint);

      _debugResponse(
        method: 'GET',
        endpoint: endpoint,
        response: response,
      );

      if (!response.success ||
          response.data == null ||
          response.data is! Map) {
        debugPrint(
          'GET PROFILE FAILED',
        );

        isLoading = false;
        update();

        return false;
      }

      final data = Map<String, dynamic>.from(
        response.data as Map,
      );

      // -----------------------------------------------------------------------
      // Convert API response to ProfileModel
      // -----------------------------------------------------------------------

      selectedProfile = ProfileModel.fromJson(data);

      debugPrint('');
      debugPrint('========== PROFILE PARSED ==========');
      debugPrint(
        'ID         : ${selectedProfile!.id}',
      );
      debugPrint(
        'NAME       : ${selectedProfile!.name}',
      );
      debugPrint(
        'SLUG       : ${selectedProfile!.slug}',
      );
      debugPrint(
        'AUTO REPLY : ${selectedProfile!.autoReplyEnabled}',
      );
      debugPrint(
        'WHATSAPP   : ${selectedProfile!.whatsappConfig != null}',
      );
      debugPrint(
        'INSTAGRAM  : ${selectedProfile!.instagramConfig != null}',
      );
      debugPrint('====================================');
      debugPrint('');

      isLoading = false;
      update();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'GET PROFILE EXCEPTION: $e',
      );
      debugPrint(
        '$stackTrace',
      );

      isLoading = false;
      update();

      return false;
    }
  }

  // ===========================================================================
  // LOAD SETTINGS
  // ===========================================================================
  //
  // STEP 1:
  // GET /auth/me
  //
  // STEP 2:
  // Extract profile ID from:
  // userProfiles[0].profile.id
  //
  // STEP 3:
  // GET /profiles/{profileId}
  //
  // ===========================================================================

  Future<bool> loadSettings() async {
    debugPrint('');
    debugPrint('##########################################');
    debugPrint('LOADING SETTINGS');
    debugPrint('##########################################');

    // -------------------------------------------------------------------------
    // STEP 1 - GET /auth/me
    // -------------------------------------------------------------------------

    final userSuccess = await getUserProfile();

    if (!userSuccess) {
      debugPrint(
        'SETTINGS: Failed to get user/profile ID',
      );

      return false;
    }

    // -------------------------------------------------------------------------
    // STEP 2 - Get profile ID
    // -------------------------------------------------------------------------

    final id = profileId;

    debugPrint(
      'SETTINGS: PROFILE ID = $id',
    );

    if (id.isEmpty) {
      debugPrint(
        'SETTINGS: Profile ID is empty',
      );

      return false;
    }

    // -------------------------------------------------------------------------
    // STEP 3 - GET /profiles/{profileId}
    // -------------------------------------------------------------------------

    final profileSuccess = await getProfile(id);

    if (!profileSuccess) {
      debugPrint(
        'SETTINGS: Failed to load profile',
      );

      return false;
    }

    debugPrint(
      'SETTINGS: Profile loaded successfully',
    );

    return true;
  }

  // ===========================================================================
  // SELECT PROFILE
  // ===========================================================================

  void selectProfile(ProfileModel profile) {
    selectedProfile = profile;
    update();
  }

  // ===========================================================================
  // ADD PROFILE
  // ===========================================================================
  //
  // POST /profiles
  //
  // ===========================================================================

  Future<bool> addProfile({
    required String name,
    required String slug,
    required String systemPrompt,
    required bool autoReplyEnabled,
  }) async {
    isSaving = true;
    update();

    final endpoint = ApiConstants.addprofiles;

    final body = {
      'name': name,
      'slug': slug,
      'systemPrompt': systemPrompt,
      'autoReplyEnabled': autoReplyEnabled,
    };

    _debugRequest(
      method: 'POST',
      endpoint: endpoint,
      body: body,
    );

    try {
      final response = await _apiClient.post(
        endpoint,
        body: body,
      );

      _debugResponse(
        method: 'POST',
        endpoint: endpoint,
        response: response,
      );

      if (!response.success) {
        isSaving = false;
        update();

        return false;
      }

      // -----------------------------------------------------------------------
      // Parse created profile if API returns it
      // -----------------------------------------------------------------------

      if (response.data != null &&
          response.data is Map) {
        final data = Map<String, dynamic>.from(
          response.data as Map,
        );

        try {
          selectedProfile =
              ProfileModel.fromJson(data);

          debugPrint(
            'CREATED PROFILE ID: ${selectedProfile!.id}',
          );
        } catch (e) {
          debugPrint(
            'CREATE PROFILE PARSE ERROR: $e',
          );
        }
      }

      isSaving = false;
      update();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'ADD PROFILE EXCEPTION: $e',
      );
      debugPrint(
        '$stackTrace',
      );

      isSaving = false;
      update();

      return false;
    }
  }

  // ===========================================================================
  // UPDATE PROFILE
  // ===========================================================================
  //
  // PATCH /profiles/{profileId}
  //
  // ===========================================================================

  Future<bool> updateProfile({
    required String id,
    required String name,
    required String systemPrompt,
    required bool autoReplyEnabled,
  }) async {
    if (id.isEmpty) {
      debugPrint(
        'UPDATE PROFILE: Profile ID is empty',
      );
      return false;
    }

    isSaving = true;
    update();

    final endpoint = ApiConstants.profile(id);

    final body = {
      'name': name,
      'systemPrompt': systemPrompt,
      'autoReplyEnabled': autoReplyEnabled,
    };

    _debugRequest(
      method: 'PATCH',
      endpoint: endpoint,
      body: body,
    );

    try {
      final response = await _apiClient.patch(
        endpoint,
        body: body,
      );

      _debugResponse(
        method: 'PATCH',
        endpoint: endpoint,
        response: response,
      );

      if (!response.success) {
        isSaving = false;
        update();

        return false;
      }

      // -----------------------------------------------------------------------
      // Refresh profile after update
      // -----------------------------------------------------------------------

      debugPrint(
        'Refreshing profile after update...',
      );

      await getProfile(id);

      isSaving = false;
      update();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'UPDATE PROFILE EXCEPTION: $e',
      );
      debugPrint(
        '$stackTrace',
      );

      isSaving = false;
      update();

      return false;
    }
  }

  // ===========================================================================
  // DELETE PROFILE
  // ===========================================================================
  //
  // DELETE /profiles/{profileId}
  //
  // ===========================================================================

  Future<bool> deleteProfile(String id) async {
    if (id.isEmpty) {
      debugPrint(
        'DELETE PROFILE: Profile ID is empty',
      );
      return false;
    }

    isDeleting = true;
    update();

    final endpoint = ApiConstants.profile(id);

    _debugRequest(
      method: 'DELETE',
      endpoint: endpoint,
    );

    try {
      final response = await _apiClient.delete(
        endpoint,
      );

      _debugResponse(
        method: 'DELETE',
        endpoint: endpoint,
        response: response,
      );

      if (!response.success) {
        isDeleting = false;
        update();

        return false;
      }

      if (selectedProfile?.id == id) {
        selectedProfile = null;
      }

      isDeleting = false;
      update();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'DELETE PROFILE EXCEPTION: $e',
      );
      debugPrint(
        '$stackTrace',
      );

      isDeleting = false;
      update();

      return false;
    }
  }

  // ===========================================================================
  // SAVE WHATSAPP CONFIG
  // ===========================================================================
  //
  // POST /profiles/{profileId}/whatsapp
  //
  // ===========================================================================

  Future<bool> saveWhatsappConfig({
    required String profileId,
    required String phoneNumberId,
    required String businessAccountId,
    required String accessToken,
    required String appSecret,
    required String verifyToken,
    required bool enabled,
  }) async {
    if (profileId.isEmpty) {
      debugPrint(
        'WHATSAPP: Profile ID is empty',
      );
      return false;
    }

    isSaving = true;
    update();

    final endpoint =
        ApiConstants.whatsapp(profileId);

    final body = {
      'phoneNumberId': phoneNumberId,
      'businessAccountId': businessAccountId,
      'accessToken': accessToken,
      'appSecret': appSecret,
      'verifyToken': verifyToken,
      'enabled': enabled,
    };

    _debugRequest(
      method: 'POST',
      endpoint: endpoint,
      body: body,
    );

    try {
      final response = await _apiClient.post(
        endpoint,
        body: body,
      );

      _debugResponse(
        method: 'POST',
        endpoint: endpoint,
        response: response,
      );

      if (!response.success) {
        isSaving = false;
        update();

        return false;
      }

      // Refresh profile
      await getProfile(profileId);

      isSaving = false;
      update();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'WHATSAPP EXCEPTION: $e',
      );
      debugPrint(
        '$stackTrace',
      );

      isSaving = false;
      update();

      return false;
    }
  }

  // ===========================================================================
  // SAVE INSTAGRAM CONFIG
  // ===========================================================================
  //
  // POST /profiles/{profileId}/instagram
  //
  // ===========================================================================

  Future<bool> saveInstagramConfig({
    required String profileId,
    required String accountId,
    required String accessToken,
    required String appSecret,
    required String verifyToken,
    required bool enabled,
  }) async {
    if (profileId.isEmpty) {
      debugPrint(
        'INSTAGRAM: Profile ID is empty',
      );
      return false;
    }

    isSaving = true;
    update();

    final endpoint =
        ApiConstants.instagram(profileId);

    final body = {
      'accountId': accountId,
      'accessToken': accessToken,
      'appSecret': appSecret,
      'verifyToken': verifyToken,
      'enabled': enabled,
    };

    _debugRequest(
      method: 'POST',
      endpoint: endpoint,
      body: body,
    );

    try {
      final response = await _apiClient.post(
        endpoint,
        body: body,
      );

      _debugResponse(
        method: 'POST',
        endpoint: endpoint,
        response: response,
      );

      if (!response.success) {
        isSaving = false;
        update();

        return false;
      }

      // Refresh profile
      await getProfile(profileId);

      isSaving = false;
      update();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'INSTAGRAM EXCEPTION: $e',
      );
      debugPrint(
        '$stackTrace',
      );

      isSaving = false;
      update();

      return false;
    }
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void onClose() {
    _apiClient.dispose();
    super.onClose();
  }
}