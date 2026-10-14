import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';

/// Property-type card in the website's style: a cream-washed tile with a warm
/// hairline border, a maroon→gold rule along the top edge, the category icon
/// on a blush-to-gold wash, and the live listing count picked out in maroon.
class CategoryCard extends StatelessWidget {
  final String title;

  /// Remote icon from `GET /api/listings/options`. Falls back to [icon].
  final String? imageUrl;

  /// Local fallback glyph, used when no remote icon is available.
  final IconData icon;

  /// ACTIVE listings in this category — rendered as "N+ Properties".
  final int listingCount;

  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.icon = Icons.home_work_outlined,
    this.listingCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Container(
          width: 138.w,
          decoration: BoxDecoration(
            gradient: AppColors.creamCardGradient,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.warmBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Maroon → gold accent rule along the top edge.
              Container(
                height: 3.h,
                decoration: const BoxDecoration(gradient: AppColors.accentLine),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        gradient: AppColors.categoryIconGradient,
                        borderRadius: BorderRadius.circular(13.r),
                      ),
                      alignment: Alignment.center,
                      child: _buildIcon(),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bold14.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -0.1,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      "$listingCount+ ${"Properties".tr}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bold12.copyWith(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final String url = imageUrl ?? '';

    if (url.isEmpty) {
      return Icon(icon, color: AppColors.primary, size: 22.sp);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.network(
        url,
        width: 28.w,
        height: 28.w,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(icon, color: AppColors.primary, size: 22.sp),
      ),
    );
  }
}
