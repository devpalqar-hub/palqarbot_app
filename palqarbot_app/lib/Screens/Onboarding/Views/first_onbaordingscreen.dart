
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Screens/Onboarding/Views/buisness_descriptionscreen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _continue() {
    Get.to(() => const BusinessDescriptionScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      22.w,
                      10.h,
                      22.w,
                      10.h,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 32.h,
                      ),
                      child: Column(
                        children: [
                          // Skip button
                          Row(
                            children: [
                              const Spacer(),

                              TextButton(
                                onPressed: _continue,
                                child: Text(
                                  'Skip',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 15.h),

                          // Hero illustration
                          SizedBox(
                            width: double.infinity,
                            height: constraints.maxHeight * 0.30,
                            child: const _RobotIllustration(),
                          ),

                          SizedBox(height: 12.h),

                          // Main heading
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Your AI Assistant\n',
                                  style: TextStyle(
                                    fontSize: 30.sp,
                                    height: 1.16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -1.0.sp,
                                  ),
                                ),
                                TextSpan(
                                  text: 'for ',
                                  style: TextStyle(
                                    fontSize: 30.sp,
                                    height: 1.16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -1.0.sp,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Business',
                                  style: AppTextStyles.heading1.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 30.sp,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.heading1.copyWith(
                              fontSize: 30.sp,
                              height: 1.16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          SizedBox(height: 15.h),

                          // Description
                          Text(
                            'Set up Palqarbot to understand\n'
                            'your business and assist\n'
                            'your customers 24/7.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Feature card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.border,
                              ),
                            ),
                            child: Column(
                              children: [
                                const _FeatureRow(
                                  icon: Icons.bolt_rounded,
                                  title: 'Answer customer enquiries',
                                  subtitle:
                                      'Provide instant and accurate responses',
                                  iconColor: Color(0xFF7938F5),
                                  iconBackground: Color(0xFFF3EEFF),
                                ),

                                const _FeatureDivider(),

                                const _FeatureRow(
                                  icon: Icons.chat_bubble_rounded,
                                  title: 'Handle common questions',
                                  subtitle:
                                      'Automate frequently asked questions',
                                  iconColor: AppColors.primaryDark,
                                  iconBackground: AppColors.primaryLight,
                                ),

                                const _FeatureDivider(),

                                const _FeatureRow(
                                  icon: Icons.access_time_rounded,
                                  title: 'Save time and grow faster',
                                  subtitle: 'Focus on what matters most',
                                  iconColor: AppColors.success,
                                  iconBackground: AppColors.successLight,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Fixed bottom CTA
            Padding(
              padding: EdgeInsets.fromLTRB(
                22.w,
                5.h,
                22.w,
                40.h,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 23.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Feature row
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackground;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.h,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(17.r),
            ),
            child: Icon(
              icon,
              size: 29.sp,
              color: iconColor,
            ),
          ),

          SizedBox(width: 17.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 5.h),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 5.w),

          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}

// Feature divider
class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 69.w),
      child: const Divider(
        height: 1,
        color: AppColors.divider,
      ),
    );
  }
}

// Robot illustration
class _RobotIllustration extends StatelessWidget {
  const _RobotIllustration();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Center(
        child: Image.asset(
          'assets/robo.png',
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.smart_toy_rounded,
              size: 120.sp,
              color: AppColors.primary,
            );
          },
        ),
      ),
    );
  }
}
