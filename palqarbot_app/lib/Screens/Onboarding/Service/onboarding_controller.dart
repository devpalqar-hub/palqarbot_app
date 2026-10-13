import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:palqarbot_app/Core/Constants/api_constants.dart';
import 'package:palqarbot_app/Core/Network/api_client.dart';
import 'package:palqarbot_app/Screens/Auth/Service/auth_controller.dart';
import 'package:palqarbot_app/Screens/Onboarding/Model/onboarding_model.dart';

class OnboardingController extends GetxController {
  late final ApiClient _apiClient;

  static const String _requestIdKey = 'profile_onboarding_request_id';

  bool isLoading = false;
  bool isSubmitting = false;

  String errorMessage = '';

  String businessName = '';
  String businessDescription = '';

  String? selectedAnswer;
  String customAnswer = '';

  OnboardingModel? current;

  OnboardingController() {
    _log('Controller initialized');

    _apiClient = ApiClient(
      onUnauthorized: () async {
        _log('401 Unauthorized: logging out');

        if (Get.isRegistered<AuthController>()) {
          await Get.find<AuthController>().logout(showMessage: true);
        } else {
          _log('AuthController is not registered');
        }
      },
    );
  }

  // --------------------------------------------------
  // DEBUG HELPERS
  // --------------------------------------------------

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[ONBOARDING] $message');
    }
  }

  void _logError(String message, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[ONBOARDING ERROR] $message');
      debugPrint('Error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _logState(String label, OnboardingModel? model) {
    if (model == null) {
      _log('$label: current model is null');
      return;
    }

    _log(
      '$label | '
      'requestId=${model.requestId} | '
      'step=${model.step}/${model.maxSteps} | '
      'done=${model.done} | '
      'nullable=${model.nullable}',
    );
  }

  // --------------------------------------------------
  // GETTERS
  // --------------------------------------------------

  bool get isComplete => current?.done ?? false;

  bool get isNullable => current?.nullable ?? false;

  double get progress {
    final item = current;

    if (item == null || item.maxSteps <= 0) {
      return 0.0;
    }

    return (item.step / item.maxSteps).clamp(0.0, 1.0).toDouble();
  }

  bool get hasSelectedAnswer {
    return (selectedAnswer?.trim().isNotEmpty ?? false) ||
        customAnswer.trim().isNotEmpty;
  }

  // --------------------------------------------------
  // START ONBOARDING
  // POST /profile-onboarding
  // --------------------------------------------------

  Future<bool> startOnboarding({
    required String name,
    required String description,
  }) async {
    _log('========== START ONBOARDING ==========');

    if (isLoading) {
      _log('Blocked: another start request is in progress');
      return false;
    }

    final trimmedName = name.trim();
    final trimmedDescription = description.trim();

    _log('Business name length: ${trimmedName.length}');
    _log('Description length: ${trimmedDescription.length}');

    if (trimmedName.isEmpty) {
      errorMessage = 'Please enter your business name.';
      _log('Validation failed: business name is empty');
      update();
      return false;
    }

    if (trimmedDescription.isEmpty) {
      errorMessage = 'Please describe your business.';
      _log('Validation failed: description is empty');
      update();
      return false;
    }

    isLoading = true;
    errorMessage = '';

    businessName = trimmedName;
    businessDescription = trimmedDescription;

    update();

    try {
      final endpoint = ApiConstants.profileOnboarding;

      _log('POST $endpoint');
      _log('Sending onboarding request');

      final response = await _apiClient.post(
        endpoint,
        body: {'name': businessName, 'description': businessDescription},
      );

      _log('Response success: ${response.success}');
      _log('Response message: ${response.message}');
      _log('Response data type: ${response.data.runtimeType}');
      _log('Response data: ${response.data}');

      if (!response.success) {
        errorMessage =
            response.message ?? 'Unable to start onboarding. Please try again.';

        _log('API returned unsuccessful response');
        update();
        return false;
      }

      if (response.data is! Map) {
        errorMessage = 'Invalid server response. Please try again.';
        _log('Parsing failed: response data is not a Map');
        update();
        return false;
      }

      final model = OnboardingModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      _logState('Parsed onboarding response', model);

      if (model.requestId.trim().isEmpty) {
        errorMessage = 'The server did not return an onboarding request ID.';

        _log('Validation failed: requestId is empty');
        update();
        return false;
      }

      current = model;
      selectedAnswer = null;
      customAnswer = '';

      _log('Getting SharedPreferences');

      final prefs = await SharedPreferences.getInstance();

      final saved = await prefs.setString(_requestIdKey, model.requestId);

      _log('Request ID saved: $saved');

      final savedId = prefs.getString(_requestIdKey);
      _log('Saved request ID verified: ${savedId != null}');

      _log('Onboarding started successfully');

      return true;
    } catch (e, stackTrace) {
      _logError('Failed to start onboarding', e, stackTrace);

      errorMessage =
          'Something went wrong while starting onboarding. Please try again.';

      return false;
    } finally {
      isLoading = false;
      update();
      _log('Start request finished; isLoading=false');
    }
  }

  // --------------------------------------------------
  // SELECT AN OPTION
  // --------------------------------------------------

  void selectAnswer(String answer) {
    _log('Selecting answer; length=${answer.length}');

    if (isSubmitting || isComplete) {
      _log('Selection ignored: submitting or onboarding complete');
      return;
    }

    selectedAnswer = answer;
    customAnswer = '';
    errorMessage = '';

    update();
  }

  // --------------------------------------------------
  // SET A CUSTOM ANSWER
  // --------------------------------------------------

  void setCustomAnswer(String value) {
    _log('Custom answer updated; length=${value.length}');

    if (isSubmitting || isComplete) {
      _log('Custom answer ignored: submitting or complete');
      return;
    }

    customAnswer = value;
    selectedAnswer = null;
    errorMessage = '';

    update();
  }

  // --------------------------------------------------
  // SUBMIT ANSWER
  // POST /profile-onboarding/{requestId}/answer
  // --------------------------------------------------

  Future<bool> submitAnswer({String? answer}) async {
    _log('========== SUBMIT ANSWER ==========');

    final item = current;

    if (item == null) {
      errorMessage = 'Please start onboarding first.';
      _log('Submission blocked: current model is null');
      update();
      return false;
    }

    if (isSubmitting || isComplete) {
      _log(
        'Submission blocked: '
        'isSubmitting=$isSubmitting, isComplete=$isComplete',
      );
      return false;
    }

    final value = (answer ?? selectedAnswer ?? customAnswer).trim();

    _logState('Before submission', item);
    _log('Answer length: ${value.length}');
    _log('Answer is empty: ${value.isEmpty}');

    if (value.isEmpty && !item.nullable) {
      errorMessage = 'Please select or enter an answer.';
      _log('Validation failed: answer is required');
      update();
      return false;
    }

    isSubmitting = true;
    errorMessage = '';

    update();

    try {
      final endpoint = ApiConstants.profileOnboardingAnswer(item.requestId);

      _log('POST $endpoint');

      final response = await _apiClient.post(
        endpoint,
        body: {'answer': value.isEmpty ? null : value},
      );

      _log('Response success: ${response.success}');
      _log('Response message: ${response.message}');
      _log('Response data type: ${response.data.runtimeType}');
      _log('Response data: ${response.data}');

      if (!response.success) {
        errorMessage =
            response.message ??
            'Unable to submit your answer. Please try again.';

        _log('API returned unsuccessful answer response');
        update();
        return false;
      }

      if (response.data is! Map) {
        errorMessage = 'Invalid server response. Please try again.';
        _log('Parsing failed: response data is not a Map');
        update();
        return false;
      }

      final next = OnboardingModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      _logState('Parsed next step', next);

      if (next.requestId.trim().isEmpty) {
        errorMessage =
            'The server did not return a valid onboarding request ID.';

        _log('Validation failed: next requestId is empty');
        update();
        return false;
      }

      current = next;
      selectedAnswer = null;
      customAnswer = '';

      final prefs = await SharedPreferences.getInstance();

      final saved = await prefs.setString(_requestIdKey, next.requestId);

      _log('Next request ID saved: $saved');

      _logState('Submission completed', current);

      return true;
    } catch (e, stackTrace) {
      _logError('Failed to submit answer', e, stackTrace);

      errorMessage =
          'Something went wrong while submitting your answer. Please try again.';

      return false;
    } finally {
      isSubmitting = false;
      update();
      _log('Answer request finished; isSubmitting=false');
    }
  }

  // --------------------------------------------------
  // CLEAR SAVED REQUEST
  // --------------------------------------------------

  Future<void> clearSavedRequest() async {
    _log('Clearing saved onboarding request');

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_requestIdKey);

      _log('Saved request ID cleared');
    } catch (e, stackTrace) {
      _logError('Failed to clear saved request ID', e, stackTrace);
    }
  }

  // --------------------------------------------------
  // RESET ONBOARDING
  // --------------------------------------------------

  void resetOnboarding() {
    _log('Resetting onboarding state');

    current = null;

    businessName = '';
    businessDescription = '';

    selectedAnswer = null;
    customAnswer = '';
    errorMessage = '';

    isLoading = false;
    isSubmitting = false;

    update();

    _log('Onboarding state reset successfully');
  }

  @override
  void onClose() {
    _log('Disposing ApiClient');
    _apiClient.dispose();
    super.onClose();
  }
}
