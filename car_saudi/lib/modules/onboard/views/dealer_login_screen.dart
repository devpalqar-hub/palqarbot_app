import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/auth_background.dart';
import 'package:villas_qatar/Core/widgets/app_logo.dart';
import 'package:villas_qatar/Core/widgets/primary_button.dart';
import 'package:villas_qatar/modules/dealer_dashboard/views/dealer_analytics_screen.dart';
import 'package:villas_qatar/modules/onboard/controller/auth_controller.dart';

/// Email/phone + password sign-in for dealer accounts — reached from
/// "Login as Dealer" on [WelcomeScreen]. Same visual language as
/// [WelcomeScreen] (the WhatsApp-OTP flow) so the two entry points read as
/// one app, just swapping the phone/OTP fields for identifier/password.
class DealerLoginScreen extends StatefulWidget {
  DealerLoginScreen({super.key});

  @override
  State<DealerLoginScreen> createState() => _DealerLoginScreenState();
}

class _DealerLoginScreenState extends State<DealerLoginScreen> {
  final AuthController controller = Get.find<AuthController>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: AuthBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),

                    Image.asset(AppLogo.heroPath, width: 120.w),

                    SizedBox(height: 20.h),

                    /// Title
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Login as ".tr,
                            style: AppTextStyles.bold16.copyWith(
                              fontSize: 21.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: "Dealer".tr,
                            style: AppTextStyles.bold16.copyWith(
                              fontSize: 21.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10.h),

                    /// Subtitle
                    Text(
                      "Enter your dealer account email and\npassword to continue"
                          .tr,
                      style: AppTextStyles.body13.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: 30.h),

                    /// Identifier field
                    Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: controller.dealerIdentifierError != null
                              ? AppColors.error
                              : AppColors.border,
                        ),
                      ),
                      child: TextField(
                        controller: controller.dealerIdentifierController,
                        keyboardType: TextInputType.emailAddress,
                        textAlignVertical: TextAlignVertical.center,
                        style: AppTextStyles.body14,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 13.h,
                          ),
                          hintText: "Email or phone".tr,
                          hintStyle: AppTextStyles.body14.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ),

                    if (controller.dealerIdentifierError != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, left: 4.w),
                        child: Text(
                          controller.dealerIdentifierError!,
                          style: AppTextStyles.body13.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),

                    SizedBox(height: 16.h),

                    /// Password field
                    Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: controller.dealerPasswordError != null
                              ? AppColors.error
                              : AppColors.border,
                        ),
                      ),
                      child: TextField(
                        controller: controller.dealerPasswordController,
                        obscureText: _obscurePassword,
                        textAlignVertical: TextAlignVertical.center,
                        style: AppTextStyles.body14,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 13.h,
                          ),
                          hintText: "Password".tr,
                          hintStyle: AppTextStyles.body14.copyWith(
                            color: AppColors.textHint,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (controller.dealerPasswordError != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, left: 4.w),
                        child: Text(
                          controller.dealerPasswordError!,
                          style: AppTextStyles.body13.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),

                    SizedBox(height: 25.h),

                    PrimaryButton(
                      title: controller.isLoading
                          ? "Logging in...".tr
                          : "Login".tr,
                      suffix: controller.isLoading
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
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
                              final success = await controller.dealerLogin();

                              if (success) {
                                Get.offAll(() => const DealerAnalyticsScreen());
                              }
                            },
                    ),

                    SizedBox(height: 40.h),

                    /// Info Card
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.authInfoBackground,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 42.w,
                            width: 42.w,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.authIconBackground,
                            ),
                            child: Icon(
                              Icons.storefront_outlined,
                              color: AppColors.primary,
                              size: 22.sp,
                            ),
                          ),

                          SizedBox(width: 14.w),

                          Expanded(
                            child: Text(
                              "The dealer portal is for agencies managing listings, leads and analytics for their team."
                                  .tr,
                              style: AppTextStyles.body13.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),
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
