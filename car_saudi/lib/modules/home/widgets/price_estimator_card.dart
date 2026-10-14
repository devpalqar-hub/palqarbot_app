import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';

/// Compact "AI Price Estimator" promo banner: eyebrow + headline + CTA on
/// the left, a photo thumbnail with a floating estimate badge on the right.
class PriceEstimatorCard extends StatelessWidget {
  const PriceEstimatorCard({super.key, required this.onGetEstimate});

  final VoidCallback onGetEstimate;

  @override
  Widget build(BuildContext context) {
    final double cardRadius = 20.r;

    return Container(
      width: double.infinity,
      height: 125.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: AppColors.warmBorder),
        image: const DecorationImage(
          image: AssetImage("assets/estimator_card.png"),
          fit: BoxFit.cover,
          // Mirrors the artwork in RTL so the photo stays opposite the text.
          matchTextDirection: true,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.w, 10.h, 10.w, 10.h),
            child: FractionallySizedBox(
              widthFactor: 0.82,
              alignment: AlignmentDirectional.centerStart,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: AppColors.goldChipBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 11.sp,
                          color: AppColors.gold,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          "AI PRICE ESTIMATOR".tr,
                          style: AppTextStyles.bold12.copyWith(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.inkFaint,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  Text(
                    "Know Your Property's True Value".tr,
                    style: AppTextStyles.title18.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Text(
                    "Get AI-powered accurate price estimates in seconds.".tr,
                    style: AppTextStyles.body13.copyWith(
                      fontSize: 8.sp,
                      color: AppColors.inkMuted,
                      height: 1.45,
                    ),
                  ),

                  SizedBox(height: 5.h),

                  _EstimateCta(onPressed: onGetEstimate),
                ],
              ),
            ),
          ),

          PositionedDirectional(
            top: 16.h,
            end: 14.w,
            child: const _EstimateBadge(),
          ),
        ],
      ),
    );
  }
}

/// Floating "AI Estimate" value chip pinned over the photo.
class _EstimateBadge extends StatelessWidget {
  const _EstimateBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AI Estimate".tr,
            style: AppTextStyles.body13.copyWith(
              fontSize: 7.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.inkFaint,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "QAR 2.4M".tr,
                style: AppTextStyles.bold12.copyWith(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.trendText,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(
                Icons.trending_up_rounded,
                size: 11.sp,
                color: AppColors.trendText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Maroon gradient "Estimate Now" button.
class _EstimateCta extends StatelessWidget {
  const _EstimateCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: AppColors.ctaGradient,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Estimate Now".tr,
                style: AppTextStyles.bold14.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_rounded,
                size: 12.sp,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
