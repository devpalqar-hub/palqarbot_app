import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';
import 'package:villas_qatar/modules/home/model/ListingOptions.dart';

/// Popular-place card, matching the website's Popular Places carousel: a white
/// tile with a neutral hairline border, a maroon-tinted map-pin badge, the
/// place name, its live listing count and the cheapest asking price.
class PopularPlaceCard extends StatelessWidget {
  final Municipality place;
  final VoidCallback? onTap;

  const PopularPlaceCard({super.key, required this.place, this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          width: 210.w,
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 12.w, 14.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.coolBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.maroonTint,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 19.sp,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bold14.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -0.1,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      place.listingCount > 0
                          ? "${place.listingCount}+ ${"Properties".tr}"
                          : "Explore area".tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body13.copyWith(
                        fontSize: 11.sp,
                        color: AppColors.inkMuted,
                      ),
                    ),

                    if (place.cheapestListingPrice != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        "${"From".tr} ${_formatPrice(place.cheapestListingPrice!)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bold12.copyWith(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 6.w),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12.sp,
                color: AppColors.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "QAR 2,450,000" — thousands separated, matching the site's price format.
  String _formatPrice(double price) {
    final String whole = price.round().toString();

    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(whole[i]);
    }

    return "${"QAR".tr} $buffer";
  }
}
