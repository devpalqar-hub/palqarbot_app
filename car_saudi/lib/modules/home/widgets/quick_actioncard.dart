import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';

/// Home quick-action row: four icon shortcuts (Map Search, Near Me, Price
/// Estimator, Saved) sitting directly on the page, matching the site's
/// home hero quick links.
class QuickActionsCard extends StatelessWidget {
  final VoidCallback onMapSearch;
  final VoidCallback onNearMe;
  final VoidCallback onPriceEstimator;
  final VoidCallback onSaved;

  const QuickActionsCard({
    super.key,
    required this.onMapSearch,
    required this.onNearMe,
    required this.onPriceEstimator,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickAction(
        icon: Icons.map_outlined,
        label: "Map Search".tr,
        background: AppColors.pinkBg,
        iconColor: AppColors.primary,
        onTap: onMapSearch,
      ),
      _QuickAction(
        icon: Icons.near_me_outlined,
        label: "Near Me".tr,
        background: const Color(0xFFE3EEFF),
        iconColor: const Color(0xFF2563EB),
        onTap: onNearMe,
      ),
      _QuickAction(
        icon: Icons.calculate_outlined,
        label: "Price Estimator".tr,
        background: AppColors.greenBg,
        iconColor: AppColors.greenText,
        onTap: onPriceEstimator,
      ),
      _QuickAction(
        icon: Icons.favorite_border_rounded,
        label: "Saved".tr,
        background: AppColors.goldChipBg,
        iconColor: AppColors.gold,
        onTap: onSaved,
      ),
    ];

    return Row(
      children: items
          .map((item) => Expanded(child: item))
          .toList(growable: false),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, color: iconColor, size: 22.sp),
            ),

            SizedBox(height: 8.h),

            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
