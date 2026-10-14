import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'package:villas_qatar/modules/home/model/banner_model.dart';
import 'package:villas_qatar/modules/home/widgets/banner_video.dart';

class InvestmentBanner extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback? onTap;

  const InvestmentBanner({super.key, required this.banner, this.onTap});

  @override
  Widget build(BuildContext context) {
    /// Do not display inactive banners.
    if (!banner.isActive) {
      return const SizedBox.shrink();
    }

    /// Check banner validity using startDate and endDate.
    final DateTime now = DateTime.now();

    if (banner.startDate != null && now.isBefore(banner.startDate!)) {
      return const SizedBox.shrink();
    }

    if (banner.endDate != null && now.isAfter(banner.endDate!)) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 150.h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// ==========================================
              /// BANNER IMAGE
              /// imageUrl from BannerModel
              /// ==========================================
              _buildBannerImage(),

              /// ==========================================
              /// OVERLAY
              /// Makes text readable over bright images. Skipped for a
              /// video with no text on it, so it plays untinted.
              /// ==========================================
              if (!banner.isVideo ||
                  banner.title.trim().isNotEmpty ||
                  banner.linkUrl.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                      colors: [
                        const Color(0xff5E0D27).withOpacity(.88),

                        const Color(0xff8C1437).withOpacity(.45),

                        Colors.black.withOpacity(.05),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),

              /// ==========================================
              /// FEATURED BADGE
              /// Uses isFeatured from model
              /// ==========================================
              if (banner.isFeatured)
                PositionedDirectional(
                  top: 12.h,
                  end: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.92),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 12.sp,
                          color: const Color(0xff8C1437),
                        ),

                        SizedBox(width: 3.w),

                        Text(
                          "Featured".tr,
                          style: TextStyle(
                            color: const Color(0xff8C1437),
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              /// ==========================================
              /// CONTENT
              /// ==========================================
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: 16.w,
                  top: 70.h,
                  bottom: 2.h,
                  end: 16.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// TITLE FROM API
                    SizedBox(
                      width: 210.w,
                      child: Text(
                        banner.title.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),

                    // /// We cannot make a subtitle dynamic
                    // /// because BannerModel/API currently
                    // /// has no subtitle/description field.
                    // SizedBox(
                    //   width: 190.w,
                    //   child: Text(
                    //     "Discover premium properties "
                    //     "and opportunities across Qatar",
                    //     maxLines: 2,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: TextStyle(
                    //       color:
                    //           Colors.white.withOpacity(.90),
                    //       fontSize: 10.sp,
                    //       fontWeight: FontWeight.w400,
                    //       height: 1.3,
                    //     ),
                    //   ),
                    // ),

                    /// LINK URL ACTION
                    if (banner.linkUrl.isNotEmpty)
                      SizedBox(
                        height: 30.h,
                        child: OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            side: BorderSide(
                              color: Colors.white.withOpacity(.45),
                            ),
                            backgroundColor: Colors.white.withOpacity(.10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Explore Now".tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              SizedBox(width: 7.w),

                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 14.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================================================
  /// NETWORK IMAGE
  /// ================================================

  Widget _buildBannerImage() {
    if (banner.imageUrl.trim().isEmpty) {
      return _fallbackImage();
    }

    if (banner.isVideo) {
      return BannerVideo(url: banner.imageUrl, fallback: _fallbackImage());
    }

    return Image.network(
      banner.imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      // Mirrors the picture in RTL so it flips along with the text and the
      // gradient.
      matchTextDirection: true,

      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: const Color(0xff8C1437),
          alignment: Alignment.center,
          child: SizedBox(
            width: 22.w,
            height: 22.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        );
      },

      errorBuilder: (context, error, stackTrace) {
        return _fallbackImage();
      },
    );
  }

  /// ================================================
  /// FALLBACK IMAGE
  /// ================================================

  Widget _fallbackImage() {
    return Image.asset(
      "assets/banner_img.png",
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      // Mirrors the picture in RTL so it flips along with the text and the
      // gradient.
      matchTextDirection: true,
    );
  }
}
