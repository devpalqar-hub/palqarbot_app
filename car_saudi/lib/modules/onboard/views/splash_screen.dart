import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/app_logo.dart';
import 'package:villas_qatar/modules/dealer_dashboard/views/dealer_analytics_screen.dart';
import 'package:villas_qatar/modules/mainscreen/mainscreen.dart';

import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final token = StorageService.getToken();

    if (token != null && token.isNotEmpty) {
      // Valid stored token - no need to log in again. But a dealer
      // session must land back on the dealer dashboard, not the
      // buyer/renter MainScreen, or a refreshed app silently drops
      // dealers into the wrong home screen every time.
      final role = StorageService.getProfile()?['role']
          ?.toString()
          .toUpperCase();

      if (role == "DEALER") {
        Get.offAll(() => const DealerAnalyticsScreen());
      } else {
        Get.offAll(() => const MainScreen());
      }
    } else {
      Get.offAll(() => WelcomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                /// Logo
                ///
                Center(
                  child: Image.asset(
                    AppLogo.heroPath,
                    width: 150.w,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: 24.h),

                /// Title
                Text(
                  'Find your dream villa'.tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold16.copyWith(
                    fontSize: 21.sp,
                    color: const Color(0xff222222),
                  ),
                ),

                SizedBox(height: 4.h),

                /// Subtitle
                Text(
                  'in Qatar'.tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold16.copyWith(
                    fontSize: 21.sp,
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(height: 10.h),

                /// Description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
                  child: Text(
                    'Discover premium villas and properties\nin the best locations across Qatar'
                        .tr,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body13.copyWith(
                      color: const Color(0xff666666),
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(),

                /// Bottom Content
                Column(
                  children: [
                    Text(
                      'Premium Living. Perfect Location'.tr,
                      style: AppTextStyles.body14.copyWith(
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 15.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _indicator(true),
                        SizedBox(width: 8.w),
                        _indicator(false),
                        SizedBox(width: 8.w),
                        _indicator(false),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicator(bool active) {
    return Container(
      width: 30.w,
      height: 2.h,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }
}
