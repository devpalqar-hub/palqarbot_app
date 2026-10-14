import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villas_qatar/Core/utils/auth_guard.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/wishlist/service/wishlist_controller.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class HeroImageCard extends StatefulWidget {
  final Property property;
  final bool isMyProperty;
  final VoidCallback? onReport;
  final int selectedImageIndex;

  const HeroImageCard({
    super.key,
    required this.property,
    this.isMyProperty = false,
    this.onReport,
    required this.selectedImageIndex,
  });

  @override
  State<HeroImageCard> createState() => _HeroImageCardState();
}

class _HeroImageCardState extends State<HeroImageCard> {
  int currentPage = 0;

  @override
  void didUpdateWidget(covariant HeroImageCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedImageIndex != widget.selectedImageIndex) {
      currentPage = widget.selectedImageIndex;

      _pageController.animateToPage(
        widget.selectedImageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      if (mounted) {
        setState(() {});
      }
    }
  }

  late final WishlistController wishlistController;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    currentPage = widget.selectedImageIndex;
    _pageController = PageController(initialPage: widget.selectedImageIndex);

    if (Get.isRegistered<WishlistController>()) {
      wishlistController = Get.find<WishlistController>();
    } else {
      wishlistController = Get.put(WishlistController());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.property.sortedPhotos;

    return SizedBox(
      width: double.infinity,
      height: 220.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // =========================================================
          // PROPERTY IMAGE SLIDER
          // =========================================================
          PageView.builder(
            controller: _pageController,
            itemCount: images.isEmpty ? 1 : images.length,
            onPageChanged: (index) {
              if (!mounted) return;

              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (_, index) {
              String? imageUrl;

              if (images.isNotEmpty && index >= 0 && index < images.length) {
                imageUrl = images[index].url;
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null && imageUrl.trim().isNotEmpty)
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Image.asset(
                          "assets/villa.jpg",
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.25, 0.72, 1.0],
                        colors: [
                          Colors.black.withOpacity(0.18),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.20),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // =========================================================
          // BACK BUTTON
          // =========================================================
          Positioned(
            left: 16.w,
            top: 18.h,
            child: _circleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),

          // =========================================================
          // RIGHT SIDE BUTTONS
          // Share -> Wishlist -> More
          // =========================================================
          Positioned(
            right: 16.w,
            top: 18.h,
            child: Row(
              children: [
                // ================= SHARE =================
                _circleButton(
                  icon: Icons.share_outlined,
                  iconSize: 15.sp,
                  onTap: _shareProperty,
                ),

                // ================= WISHLIST =================
                if (!widget.isMyProperty) ...[
                  SizedBox(width: 10.w),

                  GetBuilder<WishlistController>(
                    init: wishlistController,
                    builder: (controller) {
                      final propertyId = widget.property.id;

                      final bool isWishlisted = controller.isWishlisted(
                        propertyId,
                      );

                      final bool isLoading = controller.isPropertyLoading(
                        propertyId,
                      );

                      return GestureDetector(
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
                          width: 35.w,
                          height: 35.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.96),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                    color: Color(0xffA60F46),
                                  ),
                                )
                              : Icon(
                                  isWishlisted
                                      ? Icons.favorite
                                      : Icons.favorite_border_rounded,
                                  color: const Color(0xffA60F46),
                                  size: 15.sp,
                                ),
                        ),
                      );
                    },
                  ),
                ],

                // ================= MORE =================
                if (!widget.isMyProperty) ...[
                  SizedBox(width: 10.w),

                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    offset: Offset(0, 50.h),
                    color: Colors.white,
                    elevation: 6,
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    onSelected: (value) {
                      if (value == 'report') {
                        if (!AuthGuard.requireLogin(
                          message: "Please login to report a listing.".tr,
                        )) {
                          return;
                        }
                        widget.onReport?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'report',
                        height: 42.h,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 18.sp,
                              color: const Color(0xFFD64545),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "Report listing".tr,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      width: 35.w,
                      height: 35.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.96),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: const Color(0xff151515),
                        size: 15.sp,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // =========================================================
          // IMAGE COUNTER
          // =========================================================
          Positioned(
            right: 18.w,
            bottom: 18.h,
            child: Container(
              height: 20.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.68),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                    size: 10.sp,
                  ),

                  SizedBox(width: 9.w),

                  Text(
                    "${currentPage + 1} / "
                    "${images.isEmpty ? 1 : images.length}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CIRCLE BUTTON
  // ===============================================================

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double? iconSize,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 30.w,
          height: 30.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xff151515),
            size: iconSize ?? 12.sp,
          ),
        ),
      ),
    );
  }

  void _shareProperty() {
    final String? slug = widget.property.slug;

    if (slug == null || slug.trim().isEmpty) {
      AppToast.show(msg: "Property link is not available".tr);
      return;
    }

    final String propertyLink =
        "https://villas.palqar.cloud/property/"
        "${Uri.encodeComponent(slug)}";

    final String message =
        "${"Check out @name".trParams({'name': widget.property.propertyName})}\n\n"
        "$propertyLink";

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                "Share Property".tr,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
              ),

              SizedBox(height: 18.h),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF25D366),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat, color: Colors.white),
                ),
                title: Text(
                  "Share on WhatsApp".tr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Get.back();

                  final Uri whatsappUri = Uri.parse(
                    "https://wa.me/?text="
                    "${Uri.encodeComponent(message)}",
                  );

                  try {
                    await launchUrl(
                      whatsappUri,
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    AppToast.show(msg: "Could not open WhatsApp".tr);
                  }
                },
              ),

              Divider(color: Colors.grey.shade200),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: const Color(0xff8E123E).withOpacity(.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: Color(0xff8E123E),
                  ),
                ),
                title: Text(
                  "Copy Link".tr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: propertyLink));

                  Get.back();

                  AppToast.show(
                    msg: "Property link copied to clipboard".tr,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
