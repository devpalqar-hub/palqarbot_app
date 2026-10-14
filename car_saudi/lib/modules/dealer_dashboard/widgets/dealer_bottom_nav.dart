import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'package:villas_qatar/Core/constants/app_colors.dart';

/// Floating maroon pill nav for the dealer portal — same visual language
/// as [HomeBottomNav] on the buyer/renter side, but with the 5 dealer
/// tabs from the analytics dashboard mockup (Dashboard/Listings/Add/
/// Chats/Profile).
class DealerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const DealerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 65.h,
        margin: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 10.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.all(Radius.circular(40.r)),
        ),
        child: Row(
          children: [
            _navItem(icon: Icons.pie_chart_rounded, label: "Dashboard".tr, index: 0),
            _navItem(icon: Icons.list_alt_rounded, label: "Listings".tr, index: 1),
            _navItem(icon: Icons.add_circle_rounded, label: "Add".tr, index: 2),
            _navItem(icon: Icons.chat_bubble_rounded, label: "Chats".tr, index: 3),
            _navItem(icon: Icons.person_rounded, label: "Profile".tr, index: 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(40.r),
        onTap: () => onChanged(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: selected ? const Color(0xffA71A46) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20.sp),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
