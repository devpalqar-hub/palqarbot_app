import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';

import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';

import 'package:palqarbot_app/Screens/Onboarding/Service/onboarding_controller.dart';

import 'package:palqarbot_app/Screens/Onboarding/Views/onboarding_questionscreen.dart';

class BusinessDescriptionScreen extends StatefulWidget {
  const BusinessDescriptionScreen({super.key});

  @override
  State<BusinessDescriptionScreen> createState() =>
      _BusinessDescriptionScreenState();
}

class _BusinessDescriptionScreenState extends State<BusinessDescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final OnboardingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<OnboardingController>()
        ? Get.find<OnboardingController>()
        : Get.put(OnboardingController());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _startOnboarding() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await controller.startOnboarding(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );
    if (!mounted || !success) return;
    if (controller.current != null) {
      Get.to(() => const OnboardingQuestionsScreen());
    }
  }

  void _goBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    bool multiline = false,
  }) {
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: AppColors.border, width: 1),
    );
    return InputDecoration(
      hintText: hint,
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 12.w,
          top: multiline ? 17 : 0,
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 22.sp),
      ),
      prefixIconConstraints: BoxConstraints(minWidth: 56.w),
      hintStyle: AppTextStyles.body.copyWith(
        fontSize: 14.sp,
        height: 1.5,
        color: AppColors.textTertiary,
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 15.h,
        vertical: multiline ? 16 : 17,
      ),
      border: outline,
      enabledBorder: outline,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.error, width: 1.4),
      ),
      errorStyle: AppTextStyles.caption.copyWith(
        color: AppColors.error,
        fontSize: 11.sp,
      ),
    );
  }

  // ============================================================

  // FIELD LABEL

  // ============================================================

  Widget _fieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 8.h),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================

  // ILLUSTRATION

  // ============================================================

  Widget _storeIllustration() {
    return SizedBox(
      width: double.infinity,
      height: 130.h,
      child: Image.asset('assets/business.png', fit: BoxFit.contain),
    );
  }

  // ============================================================

  // TIP CARD

  // ============================================================

  Widget _tipCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 26.sp,
            color: AppColors.warning,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Include what you offer, common customer questions, '
              'and how you want the bot to respond.',
              style: AppTextStyles.body.copyWith(
                fontSize: 12.sp,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GetBuilder<OnboardingController>(
          builder: (onboardingController) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(25.w, 8.h, 25.w, 20.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _storeIllustration(),
                          SizedBox(height: 16.h),
                          Text(
                            'Tell us about your\nbusiness',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.heading1.copyWith(
                              fontSize: 26.sp,
                              height: 1.12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.6,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            'Add a few details so Palqarbot can\n'
                            'understand your brand and respond to\n'
                            'customer enquiries more effectively.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 14.sp,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          _fieldLabel('Business name'),
                          TextFormField(
                            controller: _nameController,
                            enabled: !onboardingController.isLoading,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            style: AppTextStyles.body.copyWith(fontSize: 12.sp),
                            decoration: _inputDecoration(
                              hint: 'e.g. Clean Amria',
                              icon: Icons.business_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your business name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15.h),
                          _fieldLabel('Business description'),
                          TextFormField(
                            controller: _descriptionController,
                            enabled: !onboardingController.isLoading,
                            minLines: 3,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.newline,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 13.sp,
                              height: 1.2,
                            ),
                            decoration: _inputDecoration(
                              hint:
                                  'Describe your products or services,\n'
                                  'target customers, and what you want\n'
                                  'your bot to help with.',
                              icon: Icons.description_outlined,
                              multiline: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please describe your business';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          _tipCard(),
                          if (onboardingController.errorMessage.isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            _ErrorMessage(
                              message: onboardingController.errorMessage,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(25.w, 12.h, 25.w, 16.h),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(top: BorderSide(color: AppColors.divider)),
                  ),
                  child: SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: onboardingController.isLoading
                          ? null
                          : _startOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.5,
                        ),
                        foregroundColor: AppColors.textWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: onboardingController.isLoading
                          ? SizedBox(
                              height: 22.h,
                              width: 22.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textWhite,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Continue', style: AppTextStyles.button),
                                SizedBox(width: 10.w),
                                Icon(Icons.arrow_forward_rounded, size: 21.sp),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


class _ErrorMessage extends StatelessWidget {
  final String message;
  const _ErrorMessage({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r.r),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 19.sp,
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
