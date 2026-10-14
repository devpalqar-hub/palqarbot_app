import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';

import '../../../Core/constants/app_colors.dart';

/// Section heading in the website's house style: an ink-coloured title with an
/// optional muted subtitle stacked underneath, and a maroon "View all" link
/// pushed to the far edge.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showSeeAll;
  final VoidCallback? onSeeAllTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showSeeAll = true,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.title16.copyWith(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  letterSpacing: -0.2,
                  height: 1.2,
                ),
              ),

              if (subtitle != null && subtitle!.isNotEmpty) ...[
                SizedBox(height: 3.h),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontSize: 11.sp, color: Colors.grey,fontWeight: FontWeight.w600,),
                          
                ),
              ],
            ],
          ),
        ),

        if (showSeeAll) ...[
          SizedBox(width: 12.w),
          InkWell(
            borderRadius: BorderRadius.circular(6.r),
            onTap: onSeeAllTap,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View all'.tr,
                    style: AppTextStyles.medium13.copyWith(
                      color: AppColors.primary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary,
                    size: 15.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
