import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_motion.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/utils/auth_guard.dart';
import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/wishlist/service/wishlist_controller.dart';

class SellerPropertyCard extends StatelessWidget {
  const SellerPropertyCard({super.key, required this.property, this.onTap});

  final Property property;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final image = property.photos.isNotEmpty ? property.photos.first.url : "";

    return PressableScale(
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10.r),
                      ),
                      child: image.isEmpty
                          ? Container(
                              color: AppColors.primarySoft,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.home_work_outlined,
                                color: AppColors.primary,
                                size: 34.sp,
                              ),
                            )
                          : Image.network(
                              image,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),

                    Positioned(
                      left: 10.w,
                      top: 10.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          property.purpose.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 10.w,
                      top: 10.h,
                      child: _WishlistButton(propertyId: property.id),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 7,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fixed space for title (always 2 lines)
                      SizedBox(
                        height: 36.h,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            property.propertyName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body12.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 2.h),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              property.areaName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body12.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      Row(
                        children: [
                          _Spec(
                            Icons.bed_outlined,
                            property.bedrooms.toString(),
                          ),
                          SizedBox(width: 10.w),
                          _Spec(
                            Icons.bathtub_outlined,
                            property.bathrooms.toString(),
                          ),
                          SizedBox(width: 10.w),
                          _Spec(
                            Icons.square_foot,
                            property.area.toInt().toString(),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        "${"QAR".tr} ${property.price.toStringAsFixed(0)}",
                        style: AppTextStyles.title16.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
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
    );
  }
}

class _WishlistButton extends StatelessWidget {
  const _WishlistButton({required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController());

    return GetBuilder<WishlistController>(
      init: wishlistController,
      builder: (controller) {
        final isWishlisted = controller.isWishlisted(propertyId);
        final isLoading = controller.isPropertyLoading(propertyId);

        return PressableScale(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isLoading
                ? null
                : () async {
                    if (!AuthGuard.requireLogin(
                      message:
                          "Please login to save properties to your wishlist."
                              .tr,
                    )) {
                      return;
                    }
                    await controller.toggleWishlist(propertyId);
                  },
            child: Container(
              height: 34.w,
              width: 34.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
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
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1.8,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isWishlisted),
                        color: AppColors.primary,
                        size: 18.sp,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec(this.icon, this.value);

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey),
        SizedBox(width: 3.w),
        Text(value, style: AppTextStyles.body12),
      ],
    );
  }
}
