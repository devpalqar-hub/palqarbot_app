import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Constants/api_constants.dart';
import 'package:palqarbot_app/Core/Network/api_client.dart';
import 'package:palqarbot_app/Screens/Settings/Model/profile_setting_model.dart';

class ProfileSettingsController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // ============================================================
  // GENERAL STATE
  // ============================================================

  bool isLoading = false;
  bool isSaving = false;
  bool isDeleting = false;

  ProfileSettingsModel? profileSettings;
  ProfileModel? selectedProfile;

  // ============================================================
  // OPEN WHATSAPP STATE
  // ============================================================

  String openWaQrCode = '';
  String openWaPairingCode = '';
  String openWaPhoneNumber = '';
  String openWaSessionStatus = '';
  String openWaConnectedNumber = '';

  bool isOpenWaConnecting = false;
  bool isOpenWaActivating = false;
  bool isOpenWaPolling = false;
  bool isOpenWaConnected = false;

  // ============================================================
  // PROFILE GETTERS
  // ============================================================

  String get profileId {
    final profiles = profileSettings?.userProfiles ?? [];

    if (profiles.isEmpty) return '';

    return profiles.first.profile.id;
  }

  ProfileModel? get profile => selectedProfile;

  String get fullName {
    if (profileSettings == null) return '';

    return '${profileSettings!.firstName} '
            '${profileSettings!.lastName}'
        .trim();
  }

  String get email => profileSettings?.email ?? '';

  String get role => profileSettings?.role ?? '';

  String get profileName => selectedProfile?.name ?? '';

  String get profileSlug => selectedProfile?.slug ?? '';

  String get systemPrompt => selectedProfile?.systemPrompt ?? '';

  bool get autoReplyEnabled => selectedProfile?.autoReplyEnabled ?? false;

  // ============================================================
  // WHATSAPP CLOUD API GETTERS
  // ============================================================

  WhatsAppConfigModel? get whatsappConfig => selectedProfile?.whatsappConfig;

  bool get whatsappEnabled => whatsappConfig?.enabled ?? false;

  bool get hasWhatsappConfig => whatsappConfig != null;

  String get whatsappPhoneNumberId => whatsappConfig?.phoneNumberId ?? '';

  String get whatsappBusinessAccountId =>
      whatsappConfig?.businessAccountId ?? '';

  // ============================================================
  // INSTAGRAM GETTERS
  // ============================================================

  InstagramConfigModel? get instagramConfig => selectedProfile?.instagramConfig;

  bool get instagramIsEnabled => instagramConfig?.enabled ?? false;

  bool get hasInstagramConfig => instagramConfig != null;

  String get instagramAccountId => instagramConfig?.accountId ?? '';

  // ============================================================
  // OPEN WHATSAPP STATUS
  // ============================================================

  String get openWaStatusLabel {
    if (isOpenWaConnected) return 'Connected';

    switch (openWaSessionStatus.toUpperCase()) {
      case 'QR_PENDING':
        return 'Waiting for QR scan';
      case 'CONNECTING':
        return 'Connecting...';
      case 'READY':
        return 'Ready to pair';
      case 'AUTHENTICATED':
        return 'Authenticated';
      case 'CONNECTED':
        return 'Connected';
      case 'DISCONNECTED':
        return 'Disconnected';
      default:
        return openWaSessionStatus.isEmpty
            ? 'Not connected'
            : openWaSessionStatus.replaceAll('_', ' ');
    }
  }

  // ============================================================
  // DEBUG HELPERS
  // ============================================================

  void _debugRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) {
    if (!kDebugMode) return;

    debugPrint('[$method] $endpoint');

    if (body != null) {
      // Avoid logging access tokens and secrets.
      final safeBody = Map<String, dynamic>.from(body);

      for (final key in ['accessToken', 'appSecret', 'verifyToken']) {
        if (safeBody.containsKey(key)) {
          safeBody[key] = '***';
        }
      }

      debugPrint('Request body: $safeBody');
    }
  }

  void _debugResponse({
    required String method,
    required String endpoint,
    required dynamic response,
  }) {
    if (!kDebugMode) return;

    debugPrint('[$method] Response received: $endpoint');
    debugPrint('Response: $response');
  }

  // ============================================================
  // RESPONSE PARSER
  // ============================================================

  Map<String, dynamic> _openWaPayload(dynamic data) {
    if (data is! Map) {
      return <String, dynamic>{};
    }

    final result = Map<String, dynamic>.from(data);

    // Supports APIs returning { data: {...} }.
    if (result['data'] is Map) {
      return Map<String, dynamic>.from(result['data'] as Map);
    }

    return result;
  }

  // ============================================================
  // CONNECT WHATSAPP USING QR
  //
  // POST /profiles/{profileId}/connect
  // Body: { "provider": "OPEN_WA" }
  // ============================================================

  Future<bool> connectOpenWa() async {
    final id = profileId;

    if (id.isEmpty) {
      Get.snackbar(
        'Profile unavailable',
        'Please load your business profile and try again.',
      );
      return false;
    }

    isOpenWaConnecting = true;
    openWaQrCode = '';
    openWaPairingCode = '';
    openWaPhoneNumber = '';
    openWaSessionStatus = '';
    openWaConnectedNumber = '';
    isOpenWaConnected = false;
    update();

    final endpoint = ApiConstants.openWaConnect(id);

    try {
      _debugRequest(
        method: 'POST',
        endpoint: endpoint,
        body: {'provider': 'OPEN_WA'},
      );

      final response = await _apiClient.post(
        endpoint,
        body: {'provider': 'OPEN_WA'},
      );

      _debugResponse(
        method: 'POST',
        endpoint: endpoint,
        response: response.data,
      );

      if (!response.success || response.data == null) {
        Get.snackbar(
          'Connection failed',
          'Unable to start the WhatsApp QR connection.',
        );
        return false;
      }

      final data = _openWaPayload(response.data);

      openWaQrCode = data['qrCode']?.toString() ?? '';
      openWaPairingCode = data['pairingCode']?.toString() ?? '';
      openWaSessionStatus =
          data['sessionStatus']?.toString() ?? data['status']?.toString() ?? '';

      openWaConnectedNumber = data['connectedNumber']?.toString() ?? '';

      isOpenWaConnected =
          openWaSessionStatus.toUpperCase() == 'CONNECTED' ||
          data['connected'] == true;

      update();
      return true;
    } catch (e, stackTrace) {
      debugPrint('OPEN WA QR CONNECT ERROR: $e');
      debugPrint('$stackTrace');

      Get.snackbar(
        'Connection failed',
        'Something went wrong while starting WhatsApp.',
      );

      return false;
    } finally {
      isOpenWaConnecting = false;
      update();
    }
  }

  // ============================================================
  // CONNECT WHATSAPP USING PHONE NUMBER
  //
  // POST /openwa/connect/phone
  // Body:
  // {
  //   "profileId": "...",
  //   "phoneNumber": "919895728129"
  // }
  // ============================================================

  Future<bool> connectOpenWaWithPhone(String phoneNumber) async {
    final id = profileId;

    if (id.isEmpty) {
      Get.snackbar(
        'Profile unavailable',
        'Please load your business profile and try again.',
      );
      return false;
    }

    // Accepts numbers with spaces, +, and hyphens.
    final phone = phoneNumber.replaceAll(RegExp(r'[\s()+-]'), '');

    if (!RegExp(r'^\d{10,15}$').hasMatch(phone)) {
      Get.snackbar(
        'Invalid phone number',
        'Enter a valid phone number with country code.',
      );
      return false;
    }

    isOpenWaConnecting = true;
    openWaPhoneNumber = phone;
    openWaPairingCode = '';
    openWaQrCode = '';
    openWaConnectedNumber = '';
    openWaSessionStatus = 'CONNECTING';
    isOpenWaConnected = false;
    update();

    try {
      final endpoint = ApiConstants.openWaConnectPhone;

      final body = <String, dynamic>{'profileId': id, 'phoneNumber': phone};

      _debugRequest(method: 'POST', endpoint: endpoint, body: body);

      final response = await _apiClient.post(endpoint, body: body);

      _debugResponse(
        method: 'POST',
        endpoint: endpoint,
        response: response.data,
      );

      if (!response.success || response.data == null) {
        Get.snackbar(
          'Connection failed',
          'Unable to start phone-number pairing.',
        );
        return false;
      }

      final data = _openWaPayload(response.data);

      openWaPairingCode = data['pairingCode']?.toString() ?? '';

      openWaSessionStatus =
          data['sessionStatus']?.toString() ??
          data['status']?.toString() ??
          'CONNECTING';

      openWaConnectedNumber = data['connectedNumber']?.toString() ?? '';

      isOpenWaConnected =
          openWaSessionStatus.toUpperCase() == 'CONNECTED' ||
          data['connected'] == true;

      update();
      return true;
    } catch (e, stackTrace) {
      debugPrint('OPEN WA PHONE CONNECT ERROR: $e');
      debugPrint('$stackTrace');

      Get.snackbar(
        'Connection failed',
        'Something went wrong while starting phone pairing.',
      );

      return false;
    } finally {
      isOpenWaConnecting = false;
      update();
    }
  }

  // ============================================================
  // ACTIVATE WHATSAPP SESSION AND POLL STATUS
  //
  // POST /profiles/{profileId}/openwa/activate
  // GET  /profiles/{profileId}/openwa/status
  // ============================================================

  Future<bool> activateOpenWa() async {
    final id = profileId;

    if (id.isEmpty) {
      Get.snackbar(
        'Profile unavailable',
        'Unable to find your business profile.',
      );
      return false;
    }

    if (isOpenWaActivating || isOpenWaPolling) {
      return false;
    }

    isOpenWaActivating = true;
    update();

    try {
      final endpoint = ApiConstants.openWaActivate(id);

      final response = await _apiClient.post(
        endpoint,
        body: <String, dynamic>{},
      );

      if (!response.success) {
        Get.snackbar(
          'Activation failed',
          'Could not activate the WhatsApp session.',
        );
        return false;
      }

      isOpenWaPolling = true;
      update();

      // Check immediately, then poll every 3 seconds.
      for (var attempt = 0; attempt < 120 && isOpenWaPolling; attempt++) {
        if (attempt > 0) {
          await Future.delayed(const Duration(seconds: 3));
        }

        if (!isOpenWaPolling) break;

        final connected = await fetchOpenWaStatus();

        if (connected) {
          isOpenWaPolling = false;
          update();

          Get.snackbar(
            'WhatsApp connected',
            'Your WhatsApp account is now connected.',
          );

          return true;
        }
      }

      if (!isOpenWaConnected) {
        Get.snackbar(
          'Still waiting',
          'WhatsApp is not connected yet. Refresh the status or try again.',
        );
      }

      return isOpenWaConnected;
    } catch (e, stackTrace) {
      debugPrint('OPEN WA ACTIVATE ERROR: $e');
      debugPrint('$stackTrace');

      Get.snackbar(
        'Activation failed',
        'Could not activate the WhatsApp session.',
      );

      return false;
    } finally {
      isOpenWaActivating = false;
      isOpenWaPolling = false;
      update();
    }
  }

  // ============================================================
  // FETCH WHATSAPP STATUS
  //
  // GET /profiles/{profileId}/openwa/status
  // ============================================================

  Future<bool> fetchOpenWaStatus() async {
    final id = profileId;

    if (id.isEmpty) return false;

    try {
      final endpoint = ApiConstants.openWaStatus(id);
      final response = await _apiClient.get(endpoint);

      if (!response.success || response.data == null) {
        return false;
      }

      final data = _openWaPayload(response.data);

      openWaSessionStatus =
          data['sessionStatus']?.toString() ??
          data['status']?.toString() ??
          openWaSessionStatus;

      final qr = data['qrCode']?.toString() ?? '';

      if (qr.isNotEmpty) {
        openWaQrCode = qr;
      }

      final pairingCode = data['pairingCode']?.toString() ?? '';

      if (pairingCode.isNotEmpty) {
        openWaPairingCode = pairingCode;
      }

      final number = data['connectedNumber']?.toString() ?? '';

      if (number.isNotEmpty) {
        openWaConnectedNumber = number;
      }

      isOpenWaConnected =
          openWaSessionStatus.toUpperCase() == 'CONNECTED' ||
          data['connected'] == true;

      if (isOpenWaConnected) {
        isOpenWaPolling = false;
      }

      update();
      return isOpenWaConnected;
    } catch (e) {
      debugPrint('OPEN WA STATUS ERROR: $e');
      return false;
    }
  }

  // ============================================================
  // DEACTIVATE WHATSAPP SESSION
  //
  // POST /profiles/{profileId}/openwa/deactivate
  // ============================================================

  Future<bool> deactivateOpenWa() async {
    final id = profileId;

    if (id.isEmpty) {
      Get.snackbar(
        'Profile unavailable',
        'Unable to find your business profile.',
      );
      return false;
    }

    isOpenWaPolling = false;
    update();

    try {
      final endpoint = ApiConstants.openWaDeactivate(id);

      final response = await _apiClient.post(
        endpoint,
        body: <String, dynamic>{},
      );

      if (!response.success) {
        Get.snackbar(
          'Disconnect failed',
          'Could not disconnect WhatsApp. Please try again.',
        );
        return false;
      }

      isOpenWaConnected = false;
      openWaQrCode = '';
      openWaPairingCode = '';
      openWaPhoneNumber = '';
      openWaSessionStatus = 'DISCONNECTED';
      openWaConnectedNumber = '';

      update();

      Get.snackbar(
        'WhatsApp disconnected',
        'Your WhatsApp session has been deactivated.',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint('OPEN WA DEACTIVATE ERROR: $e');
      debugPrint('$stackTrace');

      Get.snackbar(
        'Disconnect failed',
        'Something went wrong while disconnecting WhatsApp.',
      );

      return false;
    }
  }

  // ============================================================
  // GET CURRENT USER
  //
  // GET /auth/me
  // ============================================================

  Future<bool> getUserProfile() async {
    isLoading = true;
    update();

    try {
      final endpoint = ApiConstants.me;

      _debugRequest(method: 'GET', endpoint: endpoint);

      final response = await _apiClient.get(endpoint);

      _debugResponse(
        method: 'GET',
        endpoint: endpoint,
        response: response.data,
      );

      if (!response.success || response.data == null || response.data is! Map) {
        return false;
      }

      final data = Map<String, dynamic>.from(response.data as Map);

      profileSettings = ProfileSettingsModel.fromJson(data);

      if (profileSettings!.userProfiles.isEmpty) {
        debugPrint('AUTH/ME: No user profiles found.');
        return false;
      }

      return profileId.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint('GET USER PROFILE ERROR: $e');
      debugPrint('$stackTrace');
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // ============================================================
  // GET PROFILE
  //
  // GET /profiles/{profileId}
  // ============================================================

  Future<bool> getProfile(String id) async {
    if (id.isEmpty) {
      debugPrint('GET PROFILE: Profile ID is empty.');
      return false;
    }

    isLoading = true;
    update();

    try {
      final endpoint = ApiConstants.profile(id);

      _debugRequest(method: 'GET', endpoint: endpoint);

      final response = await _apiClient.get(endpoint);

      _debugResponse(
        method: 'GET',
        endpoint: endpoint,
        response: response.data,
      );

      if (!response.success || response.data == null || response.data is! Map) {
        return false;
      }

      final data = Map<String, dynamic>.from(response.data as Map);

      selectedProfile = ProfileModel.fromJson(data);

      return true;
    } catch (e, stackTrace) {
      debugPrint('GET PROFILE ERROR: $e');
      debugPrint('$stackTrace');
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // ============================================================
  // LOAD USER AND PROFILE SETTINGS
  // ============================================================

  Future<bool> loadSettings() async {
    final userSuccess = await getUserProfile();

    if (!userSuccess) {
      debugPrint('SETTINGS: Failed to load user profile.');
      return false;
    }

    final id = profileId;

    if (id.isEmpty) {
      debugPrint('SETTINGS: Profile ID is empty.');
      return false;
    }

    final profileSuccess = await getProfile(id);

    if (!profileSuccess) {
      debugPrint('SETTINGS: Failed to load profile details.');
      return false;
    }

    return true;
  }

  // ============================================================
  // SELECT PROFILE
  // ============================================================

  void selectProfile(ProfileModel profile) {
    selectedProfile = profile;
    update();
  }

  // ============================================================
  // ADD PROFILE
  //
  // POST /profiles
  // ============================================================

  Future<bool> addProfile({
    required String name,
    required String slug,
    required String systemPrompt,
    required bool autoReplyEnabled,
  }) async {
    isSaving = true;
    update();

    try {
      final endpoint = ApiConstants.addprofiles;

      final body = <String, dynamic>{
        'name': name,
        'slug': slug,
        'systemPrompt': systemPrompt,
        'autoReplyEnabled': autoReplyEnabled,
      };

      _debugRequest(method: 'POST', endpoint: endpoint, body: body);

      final response = await _apiClient.post(endpoint, body: body);

      if (!response.success) return false;

      if (response.data is Map) {
        try {
          selectedProfile = ProfileModel.fromJson(
            Map<String, dynamic>.from(response.data as Map),
          );
        } catch (e) {
          debugPrint('ADD PROFILE PARSE ERROR: $e');
        }
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('ADD PROFILE ERROR: $e');
      debugPrint('$stackTrace');
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  // ============================================================
  // UPDATE PROFILE
  //
  // PATCH /profiles/{profileId}
  // ============================================================

  Future<bool> updateProfile({
    required String id,
    required String name,
    required String systemPrompt,
    required bool autoReplyEnabled,
  }) async {
    if (id.isEmpty) return false;

    isSaving = true;
    update();

    try {
      final endpoint = ApiConstants.profile(id);

      final body = <String, dynamic>{
        'name': name,
        'systemPrompt': systemPrompt,
        'autoReplyEnabled': autoReplyEnabled,
      };

      _debugRequest(method: 'PATCH', endpoint: endpoint, body: body);

      final response = await _apiClient.patch(endpoint, body: body);

      if (!response.success) return false;

      await getProfile(id);
      return true;
    } catch (e, stackTrace) {
      debugPrint('UPDATE PROFILE ERROR: $e');
      debugPrint('$stackTrace');
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  // ============================================================
  // DELETE PROFILE
  //
  // DELETE /profiles/{profileId}
  // ============================================================

  Future<bool> deleteProfile(String id) async {
    if (id.isEmpty) return false;

    isDeleting = true;
    update();

    try {
      final endpoint = ApiConstants.profile(id);

      _debugRequest(method: 'DELETE', endpoint: endpoint);

      final response = await _apiClient.delete(endpoint);

      if (!response.success) return false;

      if (selectedProfile?.id == id) {
        selectedProfile = null;
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('DELETE PROFILE ERROR: $e');
      debugPrint('$stackTrace');
      return false;
    } finally {
      isDeleting = false;
      update();
    }
  }

  // ============================================================
  // SAVE WHATSAPP CLOUD API CONFIGURATION
  //
  // PUT /profiles/{profileId}/whatsapp
  // ============================================================

  Future<bool> saveWhatsappConfig({
    required String profileId,
    required String phoneNumberId,
    required String businessAccountId,
    required String accessToken,
    required String appSecret,
    required String verifyToken,
    required bool enabled,
  }) async {
    if (profileId.isEmpty) return false;

    isSaving = true;
    update();

    try {
      final endpoint = ApiConstants.whatsapp(profileId);

      final body = <String, dynamic>{
        'phoneNumberId': phoneNumberId,
        'businessAccountId': businessAccountId,
        'accessToken': accessToken,
        'appSecret': appSecret,
        'verifyToken': verifyToken,
        'enabled': enabled,
      };

      _debugRequest(method: 'PUT', endpoint: endpoint, body: body);

      final response = await _apiClient.put(endpoint, body: body);

      if (!response.success) return false;

      await getProfile(profileId);
      return true;
    } catch (e, stackTrace) {
      debugPrint('SAVE WHATSAPP CONFIG ERROR: $e');
      debugPrint('$stackTrace');
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  // ============================================================
  // SAVE INSTAGRAM CONFIGURATION
  //
  // PUT /profiles/{profileId}/instagram
  // ============================================================

  Future<bool> saveInstagramConfig({
    required String profileId,
    required String accountId,
    required String accessToken,
    required String appSecret,
    required String verifyToken,
    required bool enabled,
  }) async {
    if (profileId.isEmpty) return false;

    isSaving = true;
    update();

    try {
      final endpoint = ApiConstants.instagram(profileId);

      final body = <String, dynamic>{
        'accountId': accountId,
        'accessToken': accessToken,
        'appSecret': appSecret,
        'verifyToken': verifyToken,
        'enabled': enabled,
      };

      _debugRequest(method: 'PUT', endpoint: endpoint, body: body);

      final response = await _apiClient.put(endpoint, body: body);

      if (!response.success) return false;

      await getProfile(profileId);
      return true;
    } catch (e, stackTrace) {
      debugPrint('SAVE INSTAGRAM CONFIG ERROR: $e');
      debugPrint('$stackTrace');
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  bool _isControllerClosed = false;

  void _safeUpdate() {
    if (_isControllerClosed || isClosed) return;
    update();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    _isControllerClosed = true;

    isOpenWaPolling = false;
    isOpenWaConnecting = false;
    isOpenWaActivating = false;

    _apiClient.dispose();

    super.onClose();
  }
}
