import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Shared shimmer loading primitives. Keep skeleton layouts as close as
/// possible to the real content's dimensions (see `ShimmerListingCard`
/// below) so the loader -> content swap never shifts layout.
///
/// Colors are deliberately low-contrast neutral greys - not the brand
/// palette - so the shimmer reads as "loading", not as themed content.
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  static const Color _base = Color(0xffEDEDED);
  static const Color _highlight = Color(0xffF7F7F7);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

/// A single shimmering block - the building unit for skeleton layouts.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerBox({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
      ),
    );
  }
}

/// Skeleton matching the shape of the app's listing cards
/// (`PropertyCard` / `SellerPropertyCard` / `WishlistPropertyCard`):
/// an image block, a title line, a subtitle line, and a price line.
///
/// Wrap a `ListView`/`GridView` of these in [AppShimmer] once rather
/// than shimmering each card separately.
class ShimmerListingCard extends StatelessWidget {
  final double? width;

  const ShimmerListingCard({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: double.infinity,
            height: 120.h,
            borderRadius: BorderRadius.circular(12.r),
          ),

          SizedBox(height: 10.h),

          ShimmerBox(width: 140.w, height: 12.h),

          SizedBox(height: 8.h),

          ShimmerBox(width: 90.w, height: 10.h),

          SizedBox(height: 10.h),

          ShimmerBox(width: 70.w, height: 14.h),
        ],
      ),
    );
  }
}

/// Skeleton for a single-line list tile (e.g. a row loading its title
/// and a trailing value) - a lighter-weight alternative to
/// [ShimmerListingCard] for non-card rows.
class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          ShimmerBox(
            width: 42.w,
            height: 42.w,
            borderRadius: BorderRadius.circular(10.r),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 12.h),

                SizedBox(height: 8.h),

                ShimmerBox(width: 100.w, height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
