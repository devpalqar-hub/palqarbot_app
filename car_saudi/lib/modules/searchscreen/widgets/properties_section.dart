import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/motion/app_shimmer.dart';
import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';
import 'package:villas_qatar/modules/propertydetailscreen/propertydetailscreen.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/searchscreen/service/searchlist_screen.dart';
import 'package:villas_qatar/modules/wishlist/service/wishlist_controller.dart';

final NumberFormat _priceFormat = NumberFormat.decimalPattern('en_US');

/// "48 Properties Found" + subtitle, with a shortcut to clear whatever is
/// narrowing the results.
class ResultsHeader extends StatelessWidget {
  final PropertySearchController controller;
  const ResultsHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool searching =
        controller.isLoading && controller.properties.isEmpty;
    final int total = controller.meta?.total ?? controller.properties.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                searching
                    ? "Searching...".tr
                    : "@count Properties Found".trParams({'count': '$total'}),
                style: AppTextStyles.title18.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "Premium properties across Qatar".tr,
                style: AppTextStyles.body13.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        if (controller.filter.hasCriteria)
          TextButton(
            onPressed: controller.clearFilters,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
            ),
            child: Text(
              "Clear Filters".tr,
              style: AppTextStyles.body12.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

/// The result list as a sliver: skeleton while loading, error / empty
/// states, then the (lazily built) property cards with a load-more footer.
class PropertyResultsSliver extends StatelessWidget {
  final PropertySearchController controller;
  const PropertyResultsSliver({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final properties = controller.properties;

    if (properties.isEmpty) {
      if (controller.isLoading) {
        return const SliverToBoxAdapter(child: _ResultsSkeleton());
      }

      if (controller.error.isNotEmpty) {
        return SliverToBoxAdapter(
          child: _MessageState(
            icon: Icons.cloud_off_rounded,
            title: "Something went wrong".tr,
            message: controller.error,
            actionLabel: "Retry".tr,
            onAction: controller.fetchProperties,
          ),
        );
      }

      return SliverToBoxAdapter(
        child: _MessageState(
          icon: Icons.search_off_rounded,
          title: "No properties found".tr,
          message: "Try adjusting your search or filters".tr,
          actionLabel: controller.filter.hasCriteria
              ? "Clear Filters".tr
              : null,
          onAction: controller.clearFilters,
        ),
      );
    }

    return SliverList.builder(
      itemCount: properties.length + 1,
      itemBuilder: (_, index) {
        if (index == properties.length) {
          return controller.isLoadingMore
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 5.h),
          child: PropertyCard(property: properties[index]),
        );
      },
    );
  }
}

//======================================================
// LOADING / EMPTY / ERROR
//======================================================

class _ResultsSkeleton extends StatelessWidget {
  const _ResultsSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: List.generate(
          5,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  ShimmerBox(
                    width: _PropertyCardMetrics.imageWidth,
                    height: _PropertyCardMetrics.minHeight,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: double.infinity, height: 13.h),
                        SizedBox(height: 8.h),
                        ShimmerBox(width: 110.w, height: 11.h),
                        SizedBox(height: 14.h),
                        ShimmerBox(width: 150.w, height: 11.h),
                        SizedBox(height: 14.h),
                        ShimmerBox(width: 90.w, height: 14.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 12.w),
      child: Column(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34.sp, color: AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.title16.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body13.copyWith(color: Colors.grey.shade600),
          ),
          if (actionLabel != null) ...[
            SizedBox(height: 18.h),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                actionLabel!,
                style: AppTextStyles.body13.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

//======================================================
// PROPERTY CARD
//======================================================

class _PropertyCardMetrics {
  static double get imageWidth => 120.w;
  static double get minHeight => 116.h;
}

class PropertyCard extends StatelessWidget {
  final Property property;
  const PropertyCard({super.key, required this.property});

  static String _formatArea(double area) => area == area.roundToDouble()
      ? area.toInt().toString()
      : area.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final photos = property.sortedPhotos;
    final bool isRent = property.purpose == "RENT";

    final String location = [
      property.areaName,
      property.municipality.name,
    ].where((part) => part.trim().isNotEmpty).join(", ");

    // Beds / baths are meaningless for land and commercial listings.
    final List<_Spec> specs = [
      if (property.bedrooms > 0)
        _Spec(
          Icons.bed_outlined,
          "${property.bedrooms} ${(property.bedrooms == 1 ? "Bed" : "Beds").tr}",
        ),
      if (property.bathrooms > 0)
        _Spec(
          Icons.bathtub_outlined,
          "${property.bathrooms} ${(property.bathrooms == 1 ? "Bath" : "Baths").tr}",
        ),
      if (property.area > 0)
        _Spec(Icons.square_foot_outlined, "${_formatArea(property.area)} ${"m²".tr}"),
    ];

    return PressableScale(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () =>
                Get.to(() => PropertyDetailsScreen(propertyId: property.id)),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: _PropertyCardMetrics.minHeight,
                ),
                // Height follows the text, so larger system font sizes grow
                // the card instead of overflowing it.
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// LEFT: photo with purpose pill
                      SizedBox(
                        width: _PropertyCardMetrics.imageWidth,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: _CardPhoto(
                                  url: photos.isNotEmpty
                                      ? photos.first.url
                                      : null,
                                ),
                              ),
                              PositionedDirectional(
                                top: 8.h,
                                start: 8.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    isRent ? "For Rent".tr : "For Sale".tr,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      /// RIGHT: details
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      property.propertyName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.title16.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                  _WishlistButton(propertyId: property.id),
                                ],
                              ),

                              if (location.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 14.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Text(
                                          location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.body12.copyWith(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (specs.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Wrap(
                                    spacing: 12.w,
                                    runSpacing: 4.h,
                                    children: specs.map(_buildSpec).toList(),
                                  ),
                                ),

                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                        "${"QAR".tr} ${_priceFormat.format(property.price.round())}",
                                    style: AppTextStyles.title16.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                    children: [
                                      if (isRent)
                                        TextSpan(
                                          text: " / month".tr,
                                          style: AppTextStyles.body12.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpec(_Spec spec) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(spec.icon, size: 14.sp, color: Colors.grey.shade600),
        SizedBox(width: 4.w),
        Text(
          spec.label,
          style: AppTextStyles.body12.copyWith(
            color: Colors.grey.shade700,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}

class _Spec {
  final IconData icon;
  final String label;
  const _Spec(this.icon, this.label);
}

/// Listing photo that falls back to the placeholder when there is no photo
/// or it fails to load, and shows a neutral block while it downloads.
class _CardPhoto extends StatelessWidget {
  final String? url;
  const _CardPhoto({required this.url});

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = Image.asset(
      "assets/villa.jpg",
      fit: BoxFit.cover,
    );

    if (url == null || url!.isEmpty) return placeholder;

    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : const ColoredBox(color: Color(0xffEDEDED)),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  final String propertyId;
  const _WishlistButton({required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WishlistController>(
      init: Get.isRegistered<WishlistController>()
          ? null
          : WishlistController(),
      builder: (wishlist) {
        final bool saved = wishlist.isWishlisted(propertyId);
        final bool busy = wishlist.isPropertyLoading(propertyId);

        return InkResponse(
          radius: 20.r,
          onTap: busy ? null : () => wishlist.toggleWishlist(propertyId),
          child: Padding(
            padding: EdgeInsets.only(left: 6.w, bottom: 6.h),
            child: Icon(
              saved ? Icons.favorite : Icons.favorite_border,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
        );
      },
    );
  }
}
