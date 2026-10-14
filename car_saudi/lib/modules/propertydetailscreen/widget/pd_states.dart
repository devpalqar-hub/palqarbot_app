import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/widgets/motion/app_shimmer.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_tokens.dart';

/// Skeleton shaped like the loaded page (gallery, headline, price console,
/// stats row, two section cards) so the swap to content doesn't jump.
class PdLoadingSkeleton extends StatelessWidget {
  const PdLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: PD.canvas,
      body: Stack(
        children: [
          AppShimmer(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: double.infinity,
                    height: 340.h + top,
                    borderRadius: BorderRadius.zero,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(
                          width: 130.w,
                          height: 24.h,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        SizedBox(height: 14.h),
                        ShimmerBox(width: 260.w, height: 24.h),
                        SizedBox(height: 10.h),
                        ShimmerBox(width: 190.w, height: 14.h),
                        SizedBox(height: 18.h),
                        ShimmerBox(
                          width: double.infinity,
                          height: 150.h,
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            for (int i = 0; i < 3; i++) ...[
                              if (i > 0) SizedBox(width: 8.w),
                              Expanded(
                                child: ShimmerBox(
                                  height: 92.h,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 14.h),
                        ShimmerBox(
                          width: double.infinity,
                          height: 130.h,
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: top + 9,
            left: 14.w,
            child: PdCircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PdNotFoundState extends StatelessWidget {
  const PdNotFoundState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PD.canvas,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84.w,
                  height: 84.w,
                  decoration: BoxDecoration(
                    gradient: AppColors.categoryIconGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldBorder),
                  ),
                  child: Icon(
                    Icons.location_off_outlined,
                    size: 36.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'Property not found'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 9,
            left: 14.w,
            child: PdCircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
