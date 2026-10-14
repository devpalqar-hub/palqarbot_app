import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/modules/onboard/views/welcome_screen.dart';

class AuthGuard {
  static bool requireLogin({
    String? title,
    String? message,
  }) {
    title ??= "Login Required".tr;
    message ??= "Please sign in to use this feature.".tr;
    final token = StorageService.getToken();

    if (token != null && token.isNotEmpty) {
      return true;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
     actions: [
  Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 38.h,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: AppColors.primary),
            ),
            onPressed: () => Get.back(),
            child: Text(
              "Not Now".tr,
              style: TextStyle(
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
          height: 38.h,
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
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
],
      ),
    );

    return false;
  }
}
