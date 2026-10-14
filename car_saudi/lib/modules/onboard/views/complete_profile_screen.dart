import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/app_textfield.dart';
import 'package:villas_qatar/Core/widgets/auth_background.dart';
import 'package:villas_qatar/Core/widgets/primary_button.dart';
import 'package:villas_qatar/modules/mainscreen/mainscreen.dart';
import 'package:villas_qatar/modules/onboard/controller/auth_controller.dart';

class CompleteProfileScreen extends StatelessWidget {
  CompleteProfileScreen({super.key});

  final AuthController controller = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          body: AuthBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),

                    SizedBox(height: 30.h),

                    /// Heading
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Let's complete\n".tr,
                            style: AppTextStyles.bold16.copyWith(
                              fontSize: 21.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: "your profile".tr,
                            style: AppTextStyles.bold16.copyWith(
                              fontSize: 21.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    /// Subtitle
                    Text(
                      "Add your details to personalize\nyour experience".tr,
                      style: AppTextStyles.body14.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: 30.h),

                    /// Full Name Label
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                          size: 22.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Full Name'.tr,
                          style: AppTextStyles.bold14.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    AppTextField(
                      controller: controller.nameController,
                      hint: 'Enter your full name'.tr,
                      errorText: controller.nameError,
                      onChanged: (_) {
                        if (controller.nameError != null) {
                          controller.nameError = null;
                          controller.update();
                        }
                      },
                    ),

                    SizedBox(height: 22.h),

                    /// Email Label
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                          size: 22.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Email Address'.tr,
                          style: AppTextStyles.bold14.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    AppTextField(
                      controller: controller.emailController,
                      hint: 'Enter your email address'.tr,
                      keyboardType: TextInputType.emailAddress,
                      errorText: controller.emailError,
                      onChanged: (_) {
                        if (controller.emailError != null) {
                          controller.emailError = null;
                          controller.update();
                        }
                      },
                    ),

                    SizedBox(height: 24.h),

                    /// Privacy Info
                    Container(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          Container(
                            width: 52.w,
                            height: 52.w,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.authIconBackground,
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: AppColors.primary,
                              size: 24.sp,
                            ),
                          ),

                          SizedBox(width: 12.w),

                          Expanded(
                            child: Text(
                              "We'll never share your information with anyone"
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

                    PrimaryButton(
                      title: controller.isLoading
                          ? "Please wait...".tr
                          : "Continue".tr,
                      suffix: controller.isLoading
                          ? SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                      onTap: controller.isLoading
                          ? null
                          : () async {
                              final success = await controller
                                  .completeProfile();

                              if (success) {
                                Get.offAll(() => const MainScreen());
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
