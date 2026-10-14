import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/modules/onboard/views/welcome_screen.dart';

class GuestLimiter {
  static const _estimateKey = "guest_estimate_count";

  /// Guests get this many AI price estimates before being asked to sign in.
  static const int maxGuestEstimates = 3;

  /// Returns true (and consumes one use) if the guest is still under the
  /// limit. Logged-in users are always unlimited.
  static Future<bool> canUseEstimator() async {
    if (StorageService.getToken()?.isNotEmpty == true) {
      return true; // Logged in
    }

    final prefs = await SharedPreferences.getInstance();

    int count = prefs.getInt(_estimateKey) ?? 0;

    if (count >= maxGuestEstimates) {
      return false;
    }

    await prefs.setInt(_estimateKey, count + 1);

    return true;
  }

  /// Number of free estimates a guest has left, without consuming one.
  static Future<int> remainingGuestEstimates() async {
    if (StorageService.getToken()?.isNotEmpty == true) {
      return maxGuestEstimates; // Not applicable, but harmless.
    }

    final prefs = await SharedPreferences.getInstance();

    final int count = prefs.getInt(_estimateKey) ?? 0;

    return (maxGuestEstimates - count).clamp(0, maxGuestEstimates);
  }

  /// Shown once a guest has used up all free estimates.
  static void showLimitReachedDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text("Free Estimates Used".tr)),
          ],
        ),
        content: Text(
          "You've used all @count free AI price estimates. Sign in to keep estimating."
              .trParams({'count': '$maxGuestEstimates'}),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      "Not Now".tr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.to(() => WelcomeScreen());
                    },
                    child: Text(
                      "Login".tr,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}