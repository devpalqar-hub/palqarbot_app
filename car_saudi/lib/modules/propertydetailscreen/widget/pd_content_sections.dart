import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/compare_bottomsheet.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_tokens.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

// =====================================================================
// OVERVIEW
// =====================================================================

class PdOverviewSection extends StatefulWidget {
  final Property property;

  const PdOverviewSection({super.key, required this.property});

  @override
  State<PdOverviewSection> createState() => _PdOverviewSectionState();
}

class _PdOverviewSectionState extends State<PdOverviewSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final String description = widget.property.description.trim();
    final bool collapsible = description.length > 160;

    return PdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PdSectionHeader(title: 'Overview'.tr),
          SizedBox(height: 12.h),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Text(
              description,
              maxLines: _expanded || !collapsible ? null : 4,
              overflow: _expanded || !collapsible
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.sp, height: 1.65, color: PD.body),
            ),
          ),
          if (collapsible) ...[
            SizedBox(height: 8.h),
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Read less'.tr : 'Read more'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =====================================================================
// AMENITIES + NEARBY PLACES (one compact card, image-only tiles)
// =====================================================================

class PdFeaturesSection extends StatelessWidget {
  final Property property;

  const PdFeaturesSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final bool hasAmenities = property.amenities.isNotEmpty;
    final bool hasNearby = property.nearbyTags.isNotEmpty;

    return PdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasAmenities) ...[
            PdSectionHeader(
              title: 'Amenities'.tr,
              trailing: _CountBadge(count: property.amenities.length),
            ),
            SizedBox(height: 12.h),
            _ImageTileGrid(
              tiles: [
                for (final Amenity a in property.amenities)
                  _TileData(
                    title: a.title,
                    image: a.image,
                    fallback: Icons.check_circle_outline_rounded,
                  ),
              ],
            ),
          ],
          if (hasAmenities && hasNearby) ...[
            SizedBox(height: 18.h),
            Container(height: 1, color: PD.line),
            SizedBox(height: 18.h),
          ],
          if (hasNearby) ...[
            PdSectionHeader(
              title: 'Nearby Places'.tr,
              trailing: _CountBadge(count: property.nearbyTags.length),
            ),
            SizedBox(height: 12.h),
            _ImageTileGrid(
              tiles: [
                for (final NearbyTag n in property.nearbyTags)
                  _TileData(
                    title: n.title,
                    image: n.image,
                    fallback: Icons.place_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.maroonTint,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _TileData {
  final String title;
  final String? image;
  final IconData fallback;

  const _TileData({
    required this.title,
    required this.image,
    required this.fallback,
  });
}

/// Compact grid of square, image-only tiles (five per row). Tapping a tile
/// shows its name. Only the first nine are shown until the trailing "+N"
/// tile is tapped. A tile without an image shows an icon and its name so it
/// is never an unlabeled placeholder.
class _ImageTileGrid extends StatefulWidget {
  final List<_TileData> tiles;

  const _ImageTileGrid({required this.tiles});

  @override
  State<_ImageTileGrid> createState() => _ImageTileGridState();
}

class _ImageTileGridState extends State<_ImageTileGrid> {
  static const int _perRow = 5;
  static const int _collapsedCount = 9;

  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final int total = widget.tiles.length;
    final bool collapsible = total > _perRow * 2;
    final bool collapsed = collapsible && !_all;
    final List<_TileData> shown = collapsed
        ? widget.tiles.take(_collapsedCount).toList()
        : widget.tiles;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double gap = 8.w;
        final double size = (c.maxWidth - gap * (_perRow - 1)) / _perRow;

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final _TileData t in shown) _ImageTile(data: t, size: size),
              if (collapsible)
                _ToggleTile(
                  size: size,
                  label: collapsed ? '+${total - _collapsedCount}' : null,
                  onTap: () => setState(() => _all = !_all),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageTile extends StatelessWidget {
  final _TileData data;
  final double size;

  const _ImageTile({required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    final String image = (data.image ?? '').trim();

    // Scales down rather than overflowing on small screens / large text.
    Widget labelled() => FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: size * .76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.fallback, size: size * .3, color: AppColors.primary),
            SizedBox(height: 3.h),
            Text(
              data.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8.sp,
                height: 1.15,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );

    return Tooltip(
      message: data.title,
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: false,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * .12),
        decoration: BoxDecoration(
          color: PD.cell,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.warmBorder),
        ),
        child: image.isEmpty
            ? labelled()
            : Image.network(
                image,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => labelled(),
              ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final double size;

  /// "+N" when collapsed, null (shows a chevron) when expanded.
  final String? label;
  final VoidCallback onTap;

  const _ToggleTile({required this.size, required this.onTap, this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.maroonTint,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.primary.withValues(alpha: .18)),
          ),
          child: label != null
              ? Text(
                  label!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                )
              : Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 24.sp,
                  color: AppColors.primary,
                ),
        ),
      ),
    );
  }
}

// =====================================================================
// PROPERTY DETAILS (key information grid)
// =====================================================================

class PdSpecsSection extends StatelessWidget {
  final Property property;

  const PdSpecsSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final String type = PD.prettify(property.type.title);
    final String furnishing = property.furnishing.title.trim();
    final bool isRent = property.purpose.toUpperCase() == 'RENT';

    final List<(IconData, String, String)> rows = [
      if (type.isNotEmpty)
        (Icons.home_work_outlined, 'Property Type'.tr, type.tr),
      (
        Icons.sell_outlined,
        'Purpose'.tr,
        isRent ? 'For Rent'.tr : 'For Sale'.tr,
      ),
      (Icons.king_bed_outlined, 'Bedrooms'.tr, '${property.bedrooms}'),
      (Icons.bathtub_outlined, 'Bathrooms'.tr, '${property.bathrooms}'),
      (
        Icons.square_foot_rounded,
        'Built-up Area'.tr,
        '${PD.number(property.area)} ${'sqm'.tr}',
      ),
      if (furnishing.isNotEmpty)
        (Icons.chair_outlined, 'Furnishing'.tr, furnishing.tr),
      if (property.livingRooms > 0)
        (Icons.weekend_outlined, 'Living Rooms'.tr, '${property.livingRooms}'),
      if (property.parkingSpaces > 0)
        (
          Icons.directions_car_outlined,
          'Parking'.tr,
          '${property.parkingSpaces}',
        ),
      if (property.totalFloors > 0)
        (
          Icons.layers_outlined,
          'Floor'.tr,
          '${property.floorNumber} / ${property.totalFloors}',
        ),
      if (property.yearBuilt != null)
        (
          Icons.calendar_today_outlined,
          'Year Built'.tr,
          '${property.yearBuilt}',
        ),
      if (property.country.trim().isNotEmpty)
        (Icons.public_rounded, 'Country'.tr, property.country),
    ];

    return PdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PdSectionHeader(title: 'Property Details'.tr),
          SizedBox(height: 14.h),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final double gap = 10.w;
              final double width = (c.maxWidth - gap) / 2;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final (IconData, String, String) r in rows)
                    SizedBox(
                      width: width,
                      child: _SpecCell(icon: r.$1, label: r.$2, value: r.$3),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SpecCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: PD.cell,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warmBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                SizedBox(height: 3.h),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// OTHER FEATURES
// =====================================================================

class PdOtherFeaturesSection extends StatelessWidget {
  final Property property;

  const PdOtherFeaturesSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final List<String> features = property.otherFeatures
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return PdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PdSectionHeader(title: 'Other Features'.tr),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final String f in features)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.maroonTint,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: .14),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 15.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// LOCATION
// =====================================================================

class PdLocationSection extends StatefulWidget {
  final Property property;

  const PdLocationSection({super.key, required this.property});

  @override
  State<PdLocationSection> createState() => _PdLocationSectionState();
}

class _PdLocationSectionState extends State<PdLocationSection> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();

    if (!PD.hasCoordinates(widget.property)) return;

    final double lat = widget.property.latitude;
    final double lng = widget.property.longitude;

    final String html =
        '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
html, body { margin: 0; padding: 0; height: 100%; overflow: hidden; }
iframe { border: 0; width: 100%; height: 100%; }
</style>
</head>
<body>
<iframe loading="lazy" allowfullscreen
  src="https://maps.google.com/maps?q=$lat,$lng(Property)&z=16&output=embed">
</iframe>
</body>
</html>
''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(html);
  }

  Future<void> _openMaps() async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.property.latitude},${widget.property.longitude}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Property p = widget.property;
    final String location = PD.location(p);
    final String address = p.addressLine1.trim();
    final bool hasCoords = _controller != null;

    return PdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PdSectionHeader(title: 'Location'.tr),
          SizedBox(height: 14.h),

          ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: SizedBox(
              height: 190.h,
              width: double.infinity,
              child: hasCoords
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        WebViewWidget(controller: _controller!),
                        PositionedDirectional(
                          end: 10.w,
                          bottom: 10.h,
                          child: GestureDetector(
                            onTap: _openMaps,
                            child: PdGlass(
                              borderRadius: BorderRadius.circular(20.r),
                              tint: Colors.white.withValues(alpha: .92),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.near_me_rounded,
                                    size: 14.sp,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'View on Google Maps'.tr,
                                    style: TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.categoryIconGradient,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 40.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
          ),

          SizedBox(height: 14.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.maroonTint,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (address.isNotEmpty)
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    if (location.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          top: address.isNotEmpty ? 2.h : 8.h,
                        ),
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.4,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          if (hasCoords) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _Coordinate(label: 'Latitude'.tr, value: p.latitude),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _Coordinate(label: 'Longitude'.tr, value: p.longitude),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Coordinate extends StatelessWidget {
  final String label;
  final double value;

  const _Coordinate({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: PD.cell,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PD.label(label),
            style: TextStyle(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.inkFaint,
              letterSpacing: PD.tracking(.8),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            value.toStringAsFixed(5),
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// COMPARE
// =====================================================================

class PdCompareSection extends StatelessWidget {
  final Property property;

  const PdCompareSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CompareBottomSheet(currentProperty: property),
          );
        },
        child: Ink(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: PD.line),
            boxShadow: PD.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.maroonTint,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.compare_arrows_rounded,
                  size: 22.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compare Properties'.tr,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Compare this property with similar listings'.tr,
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .3),
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
