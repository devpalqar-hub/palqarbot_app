import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_motion.dart';
import 'package:villas_qatar/Core/utils/app_transitions.dart';
import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';
import 'package:villas_qatar/modules/propertydetailscreen/propertydetailscreen.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/searchscreen/service/searchlist_screen.dart';
import 'package:villas_qatar/modules/wishlist/service/wishlist_controller.dart';

class WishlistPropertyCard extends StatelessWidget {
  final Property property;

  const WishlistPropertyCard({super.key, required this.property});

  // Future<void> _openDetails() async {
  //   final searchController = Get.isRegistered<PropertySearchController>()
  //       ? Get.find<PropertySearchController>()
  //       : Get.put(PropertySearchController());

  //   await searchController.fetchPropertyDetails(property.id);

  //   if (searchController.selectedProperty != null) {
  //     Get.to(
  //       () => const PropertyDetailsScreen(),
  //       transition: AppTransitions.forward,
  //       duration: const Duration(milliseconds: 400),
  //     );
  //   }
  // }
  Future<void> _openDetails() async {
    Get.to(
      () => PropertyDetailsScreen(propertyId: property.id),
      transition: AppTransitions.forward,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: _openDetails,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 112.h,
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xffEEEEEE), width: .8),
            ),
            child: Row(
              children: [
                // IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(9.r),
                  child: SizedBox(
                    width: 95.w,
                    height: double.infinity,
                    child: property.photos.isNotEmpty
                        ? Image.network(
                            property.photos.first.url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return _fallbackImage();
                            },
                          )
                        : _fallbackImage(),
                  ),
                ),

                SizedBox(width: 10.w),

                // DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NAME + HEART
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              property.propertyName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff202124),
                                height: 1.3,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _WishlistButton(propertyId: property.id),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      // LOCATION
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.sp,
                            color: AppColors.primary,
                          ),

                          SizedBox(width: 3.w),

                          Expanded(
                            child: Text(
                              _locationText(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                color: const Color(0xff7A7A7A),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 7.h),

                      // FEATURES
                      Row(
                        children: [
                          _smallFeature(
                            Icons.king_bed_outlined,
                            "${property.bedrooms}",
                          ),

                          _dot(),

                          _smallFeature(
                            Icons.bathtub_outlined,
                            "${property.bathrooms}",
                          ),

                          _dot(),

                          Expanded(
                            child: _smallFeature(
                              Icons.square_foot_outlined,
                              "${_formatArea(property.area)} ${"sqm".tr}",
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // PRICE + ARROW
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${"QAR".tr} ${_formatPrice(property.price)}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallFeature(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: const Color(0xff777777)),
        SizedBox(width: 3.w),
        Text(
          value,
          maxLines: 1,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xff666666),
          ),
        ),
      ],
    );
  }

  Widget _dot() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Container(
        width: 3.w,
        height: 3.w,
        decoration: const BoxDecoration(
          color: Color(0xffB5B5B5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  String _locationText() {
    final parts = <String>[];

    if (property.areaName.trim().isNotEmpty) {
      parts.add(property.areaName);
    }

    if (property.municipality.name.trim().isNotEmpty) {
      parts.add(property.municipality.name);
    }

    return parts.isEmpty ? "Qatar".tr : parts.join(", ");
  }

  String _formatPrice(num value) {
    final text = value.toStringAsFixed(0);

    return text.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  String _formatArea(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  Widget _fallbackImage() {
    return Image.asset("assets/villa.jpg", fit: BoxFit.cover);
  }
}

class _WishlistButton extends StatelessWidget {
  final String propertyId;

  const _WishlistButton({required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (!Get.isRegistered<WishlistController>()) {
          return Container(
            width: 28.w,
            height: 28.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xffFFF1F4),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.favorite_border,
              color: AppColors.primary,
              size: 16.sp,
            ),
          );
        }

        return GetBuilder<WishlistController>(
          builder: (wishlistController) {
            final isWishlisted = wishlistController.isWishlisted(propertyId);

            final isLoading = wishlistController.isPropertyLoading(propertyId);

            return PressableScale(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isLoading
                    ? null
                    : () async {
                        await wishlistController.toggleWishlist(propertyId);
                      },
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xffFFF1F4),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: AppMotion.fast,
                    switchInCurve: AppMotion.curve,
                    switchOutCurve: AppMotion.curve,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: isLoading
                        ? SizedBox(
                            key: const ValueKey('loading'),
                            width: 13.w,
                            height: 13.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            key: ValueKey(isWishlisted),
                            color: AppColors.primary,
                            size: 16.sp,
                          ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
