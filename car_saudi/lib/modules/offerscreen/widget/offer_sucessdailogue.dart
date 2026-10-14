import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_textstyles.dart';

class OfferSuccessDialog extends StatelessWidget {
  const OfferSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: const BoxDecoration(
                color: Color(0xffF4FFF6),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green, size: 52.sp),
            ),

            SizedBox(height: 20.h),

            Text(
              "Offer Submitted!".tr,
              style: AppTextStyles.title18.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 10.h),

            Text(
              "Your offer has been sent successfully.\nThe seller will review it and contact you soon."
                  .tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),

            SizedBox(height: 26.h),

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  "Done".tr,
                  style: AppTextStyles.bold16.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
