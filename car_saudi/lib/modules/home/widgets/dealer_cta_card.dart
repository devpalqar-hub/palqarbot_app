import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_fonts.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';

/// "Grow Your Business with Villas Qatar" panel, ported from the website's
/// dealer call-to-action: a warm sand panel behind a faded skyline, a gold
/// eyebrow rule, the headline with the brand picked out in maroon, four
/// feature rows on maroon-tinted icon tiles, and the dealer sign-up button.
class DealerCtaCard extends StatelessWidget {
  const DealerCtaCard({super.key, required this.onBecomeDealer});

  final VoidCallback onBecomeDealer;

  static const List<({IconData icon, String title, String description})>
  _features = [
    (
      icon: Icons.dashboard_customize_outlined,
      title: 'Easy Property Management',
      description: 'Add, edit and manage your listings with ease.',
    ),
    (
      icon: Icons.groups_2_outlined,
      title: 'Connect with Genuine Clients',
      description: 'Receive and manage inquiries in real-time.',
    ),
    (
      icon: Icons.insights_outlined,
      title: 'Track Your Performance',
      description: 'Get insights on views, leads and conversions.',
    ),
    (
      icon: Icons.rocket_launch_outlined,
      title: 'Grow with Flexible Plans',
      description: 'Choose a plan that fits your business and scale faster.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.warmBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          /// Faded skyline, as on the website's dealer CTA.
          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: .18,
              child: Image.asset(
                "assets/dealer-cta-bg.png",
                fit: BoxFit.fitHeight,
                alignment: AlignmentDirectional.centerEnd,
                matchTextDirection: true,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Gold rule + uppercase eyebrow
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 24.w, height: 1.h, color: AppColors.gold),
                    SizedBox(width: 10.w),
                    Flexible(
                      child: Text(
                        "FOR REAL ESTATE DEALERS".tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.currentFont,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: const Color(0xFFB5835A),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: AppFonts.currentFont,
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      letterSpacing: -0.3,
                      color: AppColors.ink,
                    ),
                    children: [
                      TextSpan(text: "${"Grow Your Business".tr}\n"),
                      TextSpan(text: "${"with".tr} "),
                      TextSpan(
                        text: "Villas Qatar".tr,
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                Text(
                  "List your properties, manage inquiries and reach thousands of buyers and renters — all in one place."
                      .tr,
                  style: AppTextStyles.body13.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.inkMuted,
                    height: 1.55,
                  ),
                ),

                SizedBox(height: 18.h),

                for (final feature in _features)
                  Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: _Feature(
                      icon: feature.icon,
                      title: feature.title.tr,
                      description: feature.description.tr,
                    ),
                  ),

                SizedBox(height: 4.h),

                PressableScale(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: onBecomeDealer,
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: AppColors.ctaGradient,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(.22),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              "Become a Dealer".tr,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bold14.copyWith(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16.sp,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: AppColors.maroonTint,
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Icon(icon, size: 19.sp, color: AppColors.primary),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bold14.copyWith(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),

              SizedBox(height: 3.h),

              Text(
                description,
                style: AppTextStyles.body13.copyWith(
                  fontSize: 11.sp,
                  color: AppColors.inkMuted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
