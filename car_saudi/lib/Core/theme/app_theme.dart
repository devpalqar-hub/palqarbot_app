import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final fontFamily = Get.locale?.languageCode == 'ar'
        ? AppFonts.arabic
        : AppFonts.english;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),

      fontFamily: fontFamily,

      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),

        headlineMedium: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),

        bodyLarge: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          fontFamily: fontFamily,
        ),

        bodyMedium: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          fontFamily: fontFamily,
        ),

        labelLarge: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
      ),
    );
  }
}
