import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/modules/settings/service/profile_controller.dart';

class EditProfileBottomSheet extends StatelessWidget {
  const EditProfileBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return GetBuilder<ProfileController>(
      builder: (_) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            20.w,
            18.h,
            20.w,
            MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),

                SizedBox(height: 18.h),

                Text(
                  "Edit Profile".tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  "Update your account information".tr,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),

                SizedBox(height: 24.h),

                _field(
                  controller: controller.nameController,
                  label: "Full Name".tr,
                  icon: Icons.person_outline,
                ),

                SizedBox(height: 16.h),

                _field(
                  controller: controller.emailController,
                  label: "Email".tr,
                  icon: Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                ),

                SizedBox(height: 16.h),

                _field(
                  controller: controller.phoneController,
                  label: "Phone".tr,
                  icon: Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                ),

                SizedBox(height: 16.h),

                _field(
                  controller: controller.passwordController,
                  label: "Password".tr,
                  icon: Icons.lock_outline,
                  obscure: true,
                ),

                SizedBox(height: 28.h),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46.h,
                        child: OutlinedButton(
                          onPressed: Get.back,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF444444),
                            side: const BorderSide(color: Color(0xFFE2E2E2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Cancel".tr,
                            style: AppTextStyles.body14.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 14.w),

                    Expanded(
                      child: SizedBox(
                        height: 46.h,
                        child: ElevatedButton(
                          onPressed: controller.isSaving
                              ? null
                              : () async {
                                  final success = await controller
                                      .updateProfile();

                                  if (success) {
                                    Get.back();
                                    await controller.fetchProfile();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary
                                .withOpacity(.6),
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: controller.isSaving
                              ? SizedBox(
                                  height: 18.w,
                                  width: 18.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Save".tr,
                                  style: AppTextStyles.body14.copyWith(
                                    color: Colors.white,
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
          ),
        );
      },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xffF8F9FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
