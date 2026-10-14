import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';

import '../../../Core/constants/app_colors.dart';

/// Trust strip closing the home page — a cream panel with a warm border and a
/// gold-washed shield, in the same material as the site's footer trust band.
class WhyChooseCard extends StatelessWidget {
  const WhyChooseCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.warmBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.categoryIconGradient,
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.primary,
                  size: 21.sp,
                ),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why choose Villas Qatar?'.tr,
                      style: AppTextStyles.bold14.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -0.1,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      'Wide range of verified properties'.tr,
                      style: AppTextStyles.body13.copyWith(
                        fontSize: 11.sp,
                        color: AppColors.inkMuted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13.sp,
                color: AppColors.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
