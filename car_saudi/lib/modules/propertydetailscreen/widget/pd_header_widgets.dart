import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_tokens.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';

// =====================================================================
// HEADLINE - tags, title, location
// =====================================================================

class PdHeadline extends StatelessWidget {
  final Property property;

  const PdHeadline({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final bool isRent = property.purpose.toUpperCase() == 'RENT';
    final String type = PD.prettify(property.type.title);
    final String furnishing = property.furnishing.title.trim();
    final String location = PD.location(property);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: [
            _TagChip(
              label: isRent ? 'For Rent'.tr : 'For Sale'.tr,
              icon: Icons.sell_outlined,
              foreground: isRent ? const Color(0xFF9A6A1E) : AppColors.primary,
              background: isRent ? AppColors.goldChipBg : AppColors.pinkBg,
            ),
            if (type.isNotEmpty)
              _TagChip(
                label: type.tr,
                foreground: PD.body,
                background: Colors.white,
                border: PD.line,
              ),
            if (furnishing.isNotEmpty)
              _TagChip(
                label: furnishing,
                foreground: PD.body,
                background: Colors.white,
                border: PD.line,
              ),
            if (property.isFeatured)
              _TagChip(
                label: 'Featured'.tr,
                icon: Icons.star_rounded,
                foreground: PD.deep,
                background: AppColors.gold,
                gradient: PD.goldGradient,
              ),
            if (property.contactVerified)
              _TagChip(
                label: 'Verified'.tr,
                icon: Icons.verified_rounded,
                foreground: AppColors.trendText,
                background: AppColors.trendBg,
              ),
          ],
        ),

        SizedBox(height: 12.h),

        Text(
          property.propertyName,
          style: TextStyle(
            fontSize: 22.sp,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),

        if (location.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color foreground;
  final Color background;
  final Color? border;
  final Gradient? gradient;

  const _TagChip({
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
    this.border,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: background,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20.r),
        border: border == null ? null : Border.all(color: border!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: foreground),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// PRICE PANEL - white card with asking price and a maroon -> gold accent
// =====================================================================

class PdPriceConsole extends StatelessWidget {
  final Property property;
  final bool isMyProperty;
  final VoidCallback onInsights;
  final VoidCallback onBoost;

  const PdPriceConsole({
    super.key,
    required this.property,
    required this.isMyProperty,
    required this.onInsights,
    required this.onBoost,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRent = property.purpose.toUpperCase() == 'RENT';
    final String reference = property.referenceCode.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.goldBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23.r),
        child: Stack(
          children: [
            // Warm white wash + faint HUD grid + soft maroon glow.
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, AppColors.cream],
                  ),
                ),
                child: CustomPaint(painter: _HudGridPainter()),
              ),
            ),
            PositionedDirectional(
              top: -80,
              end: -60,
              child: Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: .10),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Accent hairline along the top edge.
            const PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: SizedBox(
                height: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.accentLine),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          PD.label('Asking Price'.tr),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkFaint,
                            letterSpacing: PD.tracking(1.6),
                          ),
                        ),
                      ),
                      if (property.priceNegotiable) const _NegotiableChip(),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'QAR'.tr,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          PD.number(property.price),
                          style: TextStyle(
                            fontSize: 34.sp,
                            height: 1.05,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (isRent) ...[
                          SizedBox(width: 8.w),
                          Text(
                            ' / month'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gold.withValues(alpha: .55),
                          PD.line.withValues(alpha: .2),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 14.h),

                  Row(
                    children: [
                      if (reference.isNotEmpty)
                        Expanded(
                          child: _Readout(
                            label: 'Reference'.tr,
                            value: reference,
                          ),
                        ),
                      Expanded(
                        child: _Readout(
                          label: 'Listed On'.tr,
                          value: DateFormat(
                            'dd MMM yyyy',
                          ).format(property.createdAt),
                        ),
                      ),
                    ],
                  ),

                  if (isMyProperty) ...[
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _ConsoleButton(
                            icon: Icons.insights_rounded,
                            label: 'Insights'.tr,
                            onTap: onInsights,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _ConsoleButton(
                            icon: Icons.rocket_launch_outlined,
                            label: 'Boost Property'.tr,
                            onTap: onBoost,
                            highlighted: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NegotiableChip extends StatelessWidget {
  const _NegotiableChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.trendBg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 12.sp,
            color: AppColors.trendText,
          ),
          SizedBox(width: 5.w),
          Text(
            'Negotiable'.tr,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.trendText,
            ),
          ),
        ],
      ),
    );
  }
}

class _Readout extends StatelessWidget {
  final String label;
  final String value;

  const _Readout({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PD.label(label),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.inkFaint,
            letterSpacing: PD.tracking(1.2),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _ConsoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  const _ConsoleButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color foreground = highlighted ? Colors.white : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: highlighted ? AppColors.ctaGradient : null,
          color: highlighted ? null : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: highlighted
              ? null
              : Border.all(color: AppColors.primary.withValues(alpha: .45)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: SizedBox(
            height: 44.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17.sp, color: foreground),
                SizedBox(width: 7.w),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HudGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.primary.withValues(alpha: .035)
      ..strokeWidth = 1;

    const double step = 22;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =====================================================================
// STATS STRIP - beds, baths, area, ...
// =====================================================================

class PdStatsStrip extends StatelessWidget {
  final Property property;

  const PdStatsStrip({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final List<_StatTile> tiles = [
      _StatTile(
        icon: Icons.bed_outlined,
        value: '${property.bedrooms}',
        label: 'Beds'.tr,
      ),
      _StatTile(
        icon: Icons.bathtub_outlined,
        value: '${property.bathrooms}',
        label: 'Baths'.tr,
      ),
      _StatTile(
        icon: Icons.square_foot_rounded,
        value: PD.number(property.area),
        unit: 'sqm'.tr,
        label: 'Area'.tr,
      ),
      if (property.parkingSpaces > 0)
        _StatTile(
          icon: Icons.directions_car_outlined,
          value: '${property.parkingSpaces}',
          label: 'Parking'.tr,
        ),
      if (property.livingRooms > 0)
        _StatTile(
          icon: Icons.weekend_outlined,
          value: '${property.livingRooms}',
          label: 'Living Rooms'.tr,
        ),
      if (property.totalFloors > 0)
        _StatTile(
          icon: Icons.layers_outlined,
          value: '${property.totalFloors}',
          label: 'Floors'.tr,
        ),
      if (property.yearBuilt != null)
        _StatTile(
          icon: Icons.calendar_today_outlined,
          value: '${property.yearBuilt}',
          label: 'Year Built'.tr,
        ),
    ];

    // Up to four tiles share the row evenly; more than that scrolls.
    if (tiles.length <= 4) {
      return Row(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            if (i > 0) SizedBox(width: 8.w),
            Expanded(child: tiles[i]),
          ],
        ],
      );
    }

    // Sized by its content (not a fixed height) so larger system text
    // scales the tiles instead of overflowing them.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < tiles.length; i++) ...[
              if (i > 0) SizedBox(width: 8.w),
              SizedBox(width: 92.w, child: tiles[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String? unit;
  final String label;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: PD.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              gradient: AppColors.categoryIconGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 18.sp, color: AppColors.primary),
          ),
          SizedBox(height: 8.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  if (unit != null)
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkFaint,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            PD.label(label),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.inkFaint,
              letterSpacing: PD.tracking(.8),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// REJECTION BANNER (owner only)
// =====================================================================

class PdRejectionBanner extends StatelessWidget {
  final String issue;
  final VoidCallback onEdit;

  const PdRejectionBanner({
    super.key,
    required this.issue,
    required this.onEdit,
  });

  static const Color _red = Color(0xFFD64545);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFF6CFCF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 20.sp,
                  color: _red,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Listing Rejected'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _red,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.45,
                          color: AppColors.ink,
                        ),
                        children: [
                          TextSpan(
                            text: 'Issue: '.tr,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: issue,
                            style: const TextStyle(
                              color: Color(0xFFB03030),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 42.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.ctaGradient,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: ElevatedButton.icon(
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, size: 16.sp),
                label: Text(
                  'Edit and Resubmit'.tr,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
