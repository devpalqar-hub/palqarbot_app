import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';

/// Design tokens + shared primitives for the redesigned property details
/// page ("pd_*" files). Colours come from [AppColors] wherever the brand
/// palette already defines them so the page stays in step with the site.
class PD {
  PD._();

  /// Page background - warm off-white so white cards read as raised panels.
  static const Color canvas = Color(0xFFF5F4F2);

  /// Deep "console" ink used for the price panel, top bar and action bar.
  static const Color deep = Color(0xFF0E1015);

  static const Color line = Color(0xFFE8E6E1);
  static const Color cell = Color(0xFFFAF8F5);
  static const Color heart = Color(0xFFFF6B8E);
  static const Color body = Color(0xFF4B4D53);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEBC27F), AppColors.gold],
  );

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0F16181D), blurRadius: 24, offset: Offset(0, 10)),
  ];

  static bool get isArabic => Get.locale?.languageCode == 'ar';

  /// Letter-spacing breaks Arabic letter joining, so wide tracking is
  /// applied to Latin text only.
  static double tracking(double value) => isArabic ? 0 : value;

  /// Upper-cases micro labels (Latin only - Arabic has no case).
  static String label(String text) => isArabic ? text : text.toUpperCase();

  static String number(num value) =>
      NumberFormat('#,##0.##', 'en').format(value);

  /// "APARTMENT_TYPE" / "apartment type" -> "Apartment Type".
  static String prettify(String raw) {
    return raw
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }

  /// "Area, Municipality, Country" with any empty part skipped.
  static String location(Property property) {
    return [
      property.areaName,
      property.municipality.name,
      property.country,
    ].where((e) => e.trim().isNotEmpty).join(', ');
  }

  static bool hasCoordinates(Property property) =>
      property.latitude != 0 || property.longitude != 0;
}

/// White raised panel - the base container for every content section.
class PdCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const PdCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: PD.line),
        boxShadow: PD.softShadow,
      ),
      child: child,
    );
  }
}

/// Section title with the maroon -> gold accent bar.
class PdSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const PdSectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 16.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.gold],
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Frosted-glass surface for chips/controls that sit on top of imagery.
class PdGlass extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double blur;
  final Color tint;
  final EdgeInsetsGeometry? padding;

  const PdGlass({
    super.key,
    required this.child,
    required this.borderRadius,
    this.blur = 14,
    this.tint = const Color(0x59000000),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white.withValues(alpha: .16)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Round white icon button (back / share / wishlist / more / close) that
/// stays legible on both photos and the white page. Leave [onTap] null when
/// it is wrapped by something that handles taps itself, e.g. a
/// `PopupMenuButton`.
class PdCircleButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback? onTap;
  final Color? iconColor;
  final double size;

  const PdCircleButton({
    super.key,
    this.icon,
    this.child,
    this.onTap,
    this.iconColor,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = SizedBox(
      width: size.w,
      height: size.w,
      child: Center(
        child:
            child ?? Icon(icon, size: 17.sp, color: iconColor ?? AppColors.ink),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.white.withValues(alpha: .96),
        shape: const CircleBorder(side: BorderSide(color: PD.line)),
        child: onTap == null
            ? content
            : InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: content,
              ),
      ),
    );
  }
}

/// White frosted shell shared by the viewer and owner action bars.
class PdBottomBarShell extends StatelessWidget {
  final Widget child;

  const PdBottomBarShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final double inset = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h + inset),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .96),
              border: const Border(top: BorderSide(color: PD.line)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
