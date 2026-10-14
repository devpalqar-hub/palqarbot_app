import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/app_logo.dart';
import 'package:villas_qatar/Core/widgets/primary_button.dart';
import 'package:villas_qatar/modules/mainscreen/mainscreen.dart';
import 'package:villas_qatar/modules/onboard/controller/auth_controller.dart';
import 'package:villas_qatar/modules/onboard/views/dealer_login_screen.dart';
import 'package:villas_qatar/modules/onboard/views/otp_screen.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final AuthController controller = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
       
          body: SizedBox.expand(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset('assets/bg1.png', fit: BoxFit.cover),
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        
                          children: [
                          
                            _buildLanguageToggle(),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                              ),
                              onPressed: () {
                                Get.offAll(() => MainScreen());
                              },
                              iconAlignment: IconAlignment.end,
                              icon: Icon(
                                Icons.arrow_forward_rounded,
                                size: 18.sp,
                              ),
                              label: Text(
                                "Skip".tr,
                                style: AppTextStyles.medium14.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 25.h),

                        /// Logo
                        Image.asset(AppLogo.path, width: 150.w),

                        SizedBox(height: 15.h),

                        /// Headline
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Find your dream villa in '.tr,
                                style: AppTextStyles.bold16.copyWith(
                                  fontSize: 21.sp,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: 'Qatar'.tr,
                                style: AppTextStyles.bold16.copyWith(
                                  fontSize: 21.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 8.h),

                        Container(
                          width: 55.w,
                          height: 1.h,
                          color: AppColors.primary,
                        ),

                        SizedBox(height: 10.h),

                        /// Description
                        Text(
                          'Premium living Prime locations\nThe lifestyle you deserve'
                              .tr,
                          style: AppTextStyles.body13.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 18.h),

                        /// WhatsApp number + Send OTP (one step, no second
                        /// login screen)
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.whatsapp,
                              size: 15.sp,
                              color: const Color(0xFF1FA855),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              "WhatsApp Number".tr,
                              style: AppTextStyles.medium13.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8.h),

                        _buildPhoneField(controller),

                        SizedBox(height: 16.h),

                        PrimaryButton(
                          title: controller.isLoading
                              ? "Sending...".tr
                              : "Send OTP".tr,
                          prefix: FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.white,
                            size: 18.sp,
                          ),
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
                                  final success = await controller.sendOtp();

                                  if (success) {
                                    Get.to(() => OtpScreen());
                                  }
                                },
                        ),

                        SizedBox(height: 25.h),

                        _buildInfoCard(),

                        SizedBox(height: 25.h),

                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                'or continue with'.tr,
                                style: AppTextStyles.body14.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        SizedBox(height: 18.h),

                        /// Social Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildSocialButton(
                                image: "assets/google.png",
                                text: "Google".tr,
                                onTap: () async {
                                  final success = await controller
                                      .signInWithGoogle();

                                  debugPrint("Google Success: $success");
                                  debugPrint(
                                    "Is New User: ${controller.isNewUser}",
                                  );

                                  // Google already gives us name + email, so
                                  // there's nothing left to collect - skip
                                  // Complete Profile even for new users.
                                  if (success) {
                                    Get.off(() => MainScreen());
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildSocialButton(
                                image: "assets/mac.png",
                                text: "Apple".tr,
                                onTap: () async {
                                  final success = await controller
                                      .signInWithApple();

                                  debugPrint("Apple Success: $success");
                                  debugPrint(
                                    "Is New User: ${controller.isNewUser}",
                                  );

                                  // Apple already gives us name + email (on
                                  // first sign-in), so there's nothing left
                                  // to collect - skip Complete Profile even
                                  // for new users.
                                  if (success) {
                                    Get.off(() => MainScreen());
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 15.h),

                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'By continuing, you agree to our\n'.tr,
                              style: AppTextStyles.body13.copyWith(
                                color: Colors.grey.shade600,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Use'.tr,
                                  style: AppTextStyles.medium13.copyWith(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _openWebUrl(
                                        'https://villas.palqar.cloud/terms',
                                      );
                                    },
                                ),
                                TextSpan(text: ' and '.tr),
                                TextSpan(
                                  text: 'Privacy Policy'.tr,
                                  style: AppTextStyles.medium13.copyWith(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _openWebUrl(
                                        'https://villas.palqar.cloud/privacy',
                                      );
                                    },
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 14.h),

                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              Get.to(() => DealerLoginScreen());
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                            icon: Icon(Icons.storefront_outlined, size: 16.sp),
                            label: Text(
                              "Login as Dealer".tr,
                              style: AppTextStyles.medium13.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LANGUAGE TOGGLE (EN / AR)
  // ============================================================
  //
  // Switches Get's locale immediately (GetMaterialApp rebuilds the
  // whole app, so every `.tr` string and the RTL/LTR direction set
  // in main.dart's Directionality both update right away) and
  // persists the choice so it survives an app restart.

  Widget _buildLanguageToggle() {
    final bool isArabic = (Get.locale?.languageCode ?? 'en') == 'ar';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langOption(
            label: 'EN',
            selected: !isArabic,
            onTap: () => _changeLanguage('en'),
          ),
          _langOption(
            label: 'عربي',
            selected: isArabic,
            onTap: () => _changeLanguage('ar'),
          ),
        ],
      ),
    );
  }

  Widget _langOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.medium13.copyWith(
            color: selected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  void _changeLanguage(String code) {
    final Locale locale = code == 'ar'
        ? const Locale('ar', 'QA')
        : const Locale('en', 'US');

    Get.updateLocale(locale);

    StorageService.saveLanguage(code);
  }

  /// Country-code dropdown + number field, as one bordered box.
  Widget _buildPhoneField(AuthController controller) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110.w,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedCountry,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
                items: ["QA", "IN", "AE", "US"].map((code) {
                  final country = CountryPickerUtils.getCountryByIsoCode(code);

                  return DropdownMenuItem<String>(
                    value: code,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(start: 8.w),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22.w,
                            height: 16.h,
                            child: CountryPickerUtils.getDefaultFlagImage(
                              country,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "+${country.phoneCode}",
                            style: AppTextStyles.body13,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  // Also refreshes selectedCountryCode / phoneNumber.
                  controller.changeCountry(value);
                },
              ),
            ),
          ),

          Container(width: 1, height: 28.h, color: AppColors.border),

          Expanded(
            child: TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.body14,
              onChanged: (value) {
                controller.phoneNumber =
                    "${controller.selectedCountryCode}${value.trim()}";
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                hintText: "WhatsApp Number".tr,
                hintStyle: AppTextStyles.body14.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.authInfoBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            height: 34.w,
            width: 34.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.authIconBackground,
            ),
            child: Icon(
              Icons.shield_outlined,
              color: AppColors.primary,
              size: 18.sp,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              "We will send an OTP to your WhatsApp to verify your account".tr,
              style: AppTextStyles.body13.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String image,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(image, width: 24.w),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body13.copyWith(
                    color: const Color(0xFF222222),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openWebUrl(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error'.tr,
        'Unable to open the page'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
