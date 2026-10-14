import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/app_logo.dart';

import '../../../Core/constants/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 0.h),
      child: Row(
        children: [
          // Icon(Icons.menu, color: AppColors.primary, size: 24.sp),
          SizedBox(width: 10.w),

          Image.asset(AppLogo.path, width: 120.w, fit: BoxFit.contain),
          Spacer(),

          SizedBox(width: 8.w),

          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none, size: 24.sp),

              PositionedDirectional(
                end: -2.w,
                top: -2.h,
                child: CircleAvatar(
                  radius: 8.r,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    '3',
                    style: AppTextStyles.body13.copyWith(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
