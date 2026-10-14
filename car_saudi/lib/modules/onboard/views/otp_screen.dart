import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/auth_background.dart';
import 'package:villas_qatar/Core/widgets/primary_button.dart';
import 'package:villas_qatar/modules/home/views/home_screen.dart';
import 'package:villas_qatar/modules/mainscreen/mainscreen.dart';
import 'package:villas_qatar/modules/onboard/controller/auth_controller.dart';
import 'package:villas_qatar/modules/onboard/views/complete_profile_screen.dart';

class OtpScreen extends StatelessWidget {
  OtpScreen({super.key});
  final AuthController controller = Get.find<AuthController>();
  Widget otpBox(bool active) {
    return Container(
      width: 45.w,
      height: 55.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,

          body: AuthBackground(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),

                    IconButton(
                      onPressed: Get.back,
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),

                    SizedBox(height: 40.h),

                    /// Title
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Verify '.tr,
                            style: AppTextStyles.bold16.copyWith(
                              fontSize: 22.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: 'OTP'.tr,
                            style: AppTextStyles.bold16.copyWith(
                              fontSize: 22.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Text(
                      'Enter the 6-digit code sent to\n@phone'.trParams({
                        'phone': controller.phoneNumber,
                      }),
                      style: AppTextStyles.body13.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    /// OTP Boxes
                    Pinput(
                      controller: controller.otpController,
                      length: 6,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        if (controller.otpError != null) {
                          controller.otpError = null;
                          controller.update();
                        }
                      },
                      defaultPinTheme: PinTheme(
                        width: 45.w,
                        height: 55.h,
                        textStyle: AppTextStyles.bold16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: controller.otpError != null
                                ? AppColors.error
                                : AppColors.border,
                          ),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 45.w,
                        height: 55.h,
                        textStyle: AppTextStyles.bold16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: controller.otpError != null
                                ? AppColors.error
                                : AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    if (controller.otpError != null) ...[
                      SizedBox(height: 10.h),
                      Text(
                        controller.otpError!,
                        style: AppTextStyles.body13.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ],

                    SizedBox(height: 24.h),

                    /// Timer
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Resend OTP in 00:25'.tr,
                        style: AppTextStyles.body13.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const Spacer(),

                    PrimaryButton(
                      title: controller.isLoading
                          ? "Verifying...".tr
                          : "Verify OTP".tr,
                      suffix: controller.isLoading
                          ? SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                      onTap: controller.isLoading
                          ? null
                          : () async {
                              final success = await controller.verifyOtp();
                              debugPrint(
                                "Navigation isNewUser: ${controller.isNewUser}",
                              );
                              if (!success) return;

                              if (controller.isNewUser) {
                                Get.off(() => CompleteProfileScreen());
                              } else {
                                Get.off(() => MainScreen());
                              }
                            },
                    ),

                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
