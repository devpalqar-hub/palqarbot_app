import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/utils/auth_guard.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_tokens.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/wishlist/service/wishlist_controller.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
/// Fixed top bar that floats over the gallery as white round controls and
/// crossfades into a solid white bar (with the property name) once the page
/// has scrolled past the gallery.
class PdTopBar extends StatefulWidget {
  /// Current vertical scroll offset of the page.
  final ValueListenable<double> scrollOffset;

  /// Scroll offset at which the bar starts turning solid.
  final double solidFrom;

  final Property property;
  final bool isMyProperty;
  final VoidCallback onReport;

  const PdTopBar({
    super.key,
    required this.scrollOffset,
    required this.solidFrom,
    required this.property,
    required this.isMyProperty,
    required this.onReport,
  });

  @override
  State<PdTopBar> createState() => _PdTopBarState();
}

class _PdTopBarState extends State<PdTopBar> {
  late final WishlistController _wishlist =
      Get.isRegistered<WishlistController>()
      ? Get.find<WishlistController>()
      : Get.put(WishlistController());

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.scrollOffset,
      builder: (BuildContext context, double offset, _) {
        final double t = ((offset - widget.solidFrom) / 70)
            .clamp(0.0, 1.0)
            .toDouble();

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .97 * t),
            border: Border(
              bottom: BorderSide(color: PD.line.withValues(alpha: t)),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Row(
                  children: [
                    PdCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Opacity(
                        opacity: t,
                        child: Text(
                          widget.property.propertyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    PdCircleButton(
                      icon: Icons.ios_share_rounded,
                      onTap: _showShareSheet,
                    ),
                    if (!widget.isMyProperty) ...[
                      SizedBox(width: 8.w),
                      _wishlistButton(),
                      SizedBox(width: 8.w),
                      _moreMenu(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _wishlistButton() {
    return GetBuilder<WishlistController>(
      init: _wishlist,
      builder: (WishlistController controller) {
        final String id = widget.property.id;
        final bool wishlisted = controller.isWishlisted(id);
        final bool loading = controller.isPropertyLoading(id);

        return PdCircleButton(
          onTap: loading
              ? null
              : () async {
                  if (!AuthGuard.requireLogin(
                    message:
                        'Please login to save properties to your wishlist.'.tr,
                  )) {
                    return;
                  }
                  await controller.toggleWishlist(id);
                },
          child: loading
              ? SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: AppColors.primary,
                  ),
                )
              : Icon(
                  wishlisted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18.sp,
                  color: wishlisted ? AppColors.primary : AppColors.ink,
                ),
        );
      },
    );
  }

  Widget _moreMenu() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: Offset(0, 50.h),
      color: Colors.white,
      elevation: 6,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      onSelected: (String value) {
        if (value != 'report') return;

        if (!AuthGuard.requireLogin(
          message: 'Please login to report a listing.'.tr,
        )) {
          return;
        }
        widget.onReport();
      },
      itemBuilder: (_) => [
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
                'Report listing'.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
      child: const PdCircleButton(icon: Icons.more_vert_rounded),
    );
  }

  // ===============================================================
  // SHARE
  // ===============================================================

  void _showShareSheet() {
    final String slug = widget.property.slug.trim();

    if (slug.isEmpty) {
      AppToast.show(msg: 'Property link is not available'.tr);
      return;
    }

    final String link =
        'https://villas.palqar.cloud/property/${Uri.encodeComponent(slug)}';
    final String message = '${'Check out @name'.trParams({'name': widget.property.propertyName})}\n\n$link';

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(
          20.w,
          12.h,
          20.w,
          20.h + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: PD.line,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Share Property'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              widget.property.propertyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: AppColors.inkMuted),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _ShareTile(
                    color: const Color(0xFF25D366),
                    icon: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                    ),
                    label: 'Share on WhatsApp'.tr,
                    onTap: () async {
                      Get.back();

                      final Uri uri = Uri.parse(
                        'https://wa.me/?text=${Uri.encodeComponent(message)}',
                      );

                      try {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (_) {
                        AppToast.show(
                          msg: 'Could not open WhatsApp'.tr,
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ShareTile(
                    color: AppColors.primary,
                    icon: const Icon(Icons.link_rounded, color: Colors.white),
                    label: 'Copy Link'.tr,
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: link));

                      Get.back();

                      AppToast.show(
                        msg: 'Property link copied to clipboard'.tr,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _ShareTile extends StatelessWidget {
  final Color color;
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _ShareTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PD.cell,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: PD.line),
          ),
          child: Column(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: .35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(child: icon),
              ),
              SizedBox(height: 10.h),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
