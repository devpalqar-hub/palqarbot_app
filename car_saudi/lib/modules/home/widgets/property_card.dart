import 'dart:async';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_motion.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';
import 'package:villas_qatar/modules/home/model/PropertyModel.dart';
import 'package:villas_qatar/modules/propertydetailscreen/propertydetailscreen.dart';
import 'package:villas_qatar/modules/wishlist/service/wishlist_controller.dart';

import '../../PlansandFeatures/model/myfeatured_property.dart';
import 'package:villas_qatar/Core/utils/app_toast.dart';

// Adjust this import to wherever FeaturedListing actually lives in your
// project (the model you shared — id, slug, propertyName, purpose,
// bedrooms, bathrooms, area, price, photos, etc.).

/// Property card — "For Rent" / "For Sale" pill, wishlist heart, photo,
/// title, location, beds/baths/area stats and price — built entirely from
/// a [FeaturedListing], the same shape returned by the listings API.
class PropertyCard extends StatefulWidget {
  /// The listing this card renders. Replaces the old individual
  /// image/title/location/price/... parameters.
  final PropertyModel listing;

  /// Optional straight-line distance label shown next to the location
  /// (e.g. "1.2 km") — not part of [FeaturedListing], so it's still passed
  /// in separately when the caller has it.
  final String distance;

  /// Overrides the card's intrinsic width — pass [double.infinity] to fill
  /// a grid cell instead of the fixed width used in horizontal rails.
  final double? width;

  /// Overrides the trailing margin used between cards in a horizontal rail.
  final EdgeInsetsGeometry? margin;

  const PropertyCard({
    super.key,
    required this.listing,
    this.distance = '',
    this.width,
    this.margin,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  /// Time each photo stays on screen before the card slides to the next one.
  static const Duration _slideInterval = Duration(seconds: 4);
  static const Duration _slideDuration = Duration(milliseconds: 450);

  /// Starting page of the looping carousel — a large multiple of the photo
  /// count, so the user can swipe backwards from the first photo as well.
  static const int _loopBase = 1000;

  late final PageController _pageController;
  Timer? _autoSlideTimer;

  /// Raw page index of the looping carousel; use `% count` for the photo.
  int _page = 0;

  late List<String> _photoUrls;

  PropertyModel get listing => widget.listing;
  String get distance => widget.distance;
  double? get width => widget.width;
  EdgeInsetsGeometry? get margin => widget.margin;

  @override
  void initState() {
    super.initState();
    _photoUrls = _collectPhotoUrls();
    _page = _startPage();
    _pageController = PageController(initialPage: _page);
    _scheduleNextSlide();
  }

  int _startPage() => _photoUrls.length < 2 ? 0 : _loopBase * _photoUrls.length;

  @override
  void didUpdateWidget(covariant PropertyCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final List<String> urls = _collectPhotoUrls();

    if (!listEquals(urls, _photoUrls)) {
      _photoUrls = urls;
      _page = _startPage();

      if (_pageController.hasClients) {
        _pageController.jumpToPage(_page);
      }

      _scheduleNextSlide();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // =============================================================
  // PHOTO CAROUSEL
  // =============================================================

  /// Photo URLs in the listing's own order, skipping empty entries.
  List<String> _collectPhotoUrls() {
    final List<PropertyPhoto> photos = [...?listing.photos]
      ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));

    return photos
        .map((photo) => photo.url?.trim() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
  }

  void _scheduleNextSlide() {
    _autoSlideTimer?.cancel();

    if (_photoUrls.length < 2) {
      return;
    }

    // Small per-card offset so the cards in a rail don't all flip in step.
    final int offsetMs = (listing.id?.hashCode ?? 0).abs() % 1200;

    _autoSlideTimer = Timer(
      _slideInterval + Duration(milliseconds: offsetMs),
      _slideToNext,
    );
  }

  void _slideToNext() {
    if (!mounted) {
      return;
    }

    // TickerMode is off while another route covers this one, so the card
    // doesn't keep animating behind the property details screen.
    if (TickerMode.valuesOf(context).enabled && _pageController.hasClients) {
      // onPageChanged schedules the following slide.
      _pageController.nextPage(
        duration: _slideDuration,
        curve: AppMotion.curve,
      );
    } else {
      _scheduleNextSlide();
    }
  }

  Widget _buildPhotoCarousel() {
    final int count = _photoUrls.length;

    if (count == 0) {
      return _imagePlaceholder();
    }

    if (count == 1) {
      return _buildImage(_photoUrls.first);
    }

    return SizedBox(
      height: 120.h,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              // Photos advance on their own and can also be swiped by hand;
              // a drag on the photo moves the photos, a drag on the card body
              // moves the rail this card sits in.
              physics: const PageScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _page = index);
                _scheduleNextSlide();
              },
              itemBuilder: (context, index) =>
                  _buildImage(_photoUrls[index % count]),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 6.h,
            child: _buildPageIndicator(count),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    final int active = _page % count;

    if (count > 5) {
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.55),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            '${active + 1}/$count',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool isActive = i == active;

        return AnimatedContainer(
          duration: AppMotion.fast,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          width: isActive ? 14.w : 5.w,
          height: 5.w,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(.55),
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }),
    );
  }

  // =============================================================
  // NAVIGATION
  // =============================================================

  void _openDetails() {
    final String id = listing.id ?? '';

    if (id.isEmpty) {
      AppToast.show(msg: "Property ID is not available".tr);
      return;
    }

    Get.to(() => PropertyDetailsScreen(propertyId: id));
  }

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController =
        Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController());

    return PressableScale(
      child: Container(
        width: width ?? 180.w,
        height: 220.h,
        margin: margin ?? EdgeInsetsDirectional.only(end: 5.w),
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.goldBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,

        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: _openDetails,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===================================================
                /// IMAGE SECTION
                /// ===================================================
                Stack(
                  children: [
                    _buildPhotoCarousel(),

                    if (_purposeLabel() != null)
                      PositionedDirectional(
                        top: 8.h,
                        start: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _purposeLabel()!,
                            style: AppTextStyles.medium13.copyWith(
                              color: AppColors.ink,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else if (listing.isFeatured ?? false)
                      PositionedDirectional(
                        top: 8.h,
                        start: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            "Featured".tr,
                            style: AppTextStyles.medium13.copyWith(
                              color: Colors.white,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                      ),

                    /// =================================================
                    /// WISHLIST BUTTON
                    /// =================================================
                    PositionedDirectional(
                      top: 10.h,
                      end: 10.w,

                      /// GetBuilder rebuilds the heart whenever
                      /// WishlistController calls update().
                      child: GetBuilder<WishlistController>(
                        init: wishlistController,
                        builder: (controller) {
                          final String id = listing.id ?? "";

                          final bool wishlisted =
                              id.isNotEmpty && controller.isWishlisted(id);

                          final bool wishlistLoading =
                              id.isNotEmpty && controller.isPropertyLoading(id);

                          /// Material + InkWell gives this button
                          /// its own tap target.
                          ///
                          /// Tapping here calls wishlist API.
                          /// Tapping rest of card opens details.
                          return PressableScale(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                customBorder: const CircleBorder(),

                                onTap: wishlistLoading
                                    ? null
                                    : () async {
                                        if (id.isEmpty) {
                                          AppToast.show(
                                            msg: "Property ID is not available"
                                                .tr,
                                          );

                                          return;
                                        }

                                        /// Calls:
                                        /// WishlistController
                                        ///     .toggleWishlist(id)
                                        ///
                                        /// which internally calls:
                                        ///
                                        /// POST wishlistByProperty(id)
                                        await controller.toggleWishlist(id);
                                      },

                                child: Container(
                                  width: 32.w,
                                  height: 32.w,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),

                                  /// Show loader only for the
                                  /// property currently being toggled.
                                  child: AnimatedSwitcher(
                                    duration: AppMotion.fast,
                                    switchInCurve: AppMotion.curve,
                                    switchOutCurve: AppMotion.curve,
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                          scale: animation,
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        ),
                                    child: wishlistLoading
                                        ? SizedBox(
                                            key: const ValueKey('loading'),
                                            width: 15.w,
                                            height: 15.w,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.primary,
                                                ),
                                          )
                                        : Icon(
                                            wishlisted
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            key: ValueKey(wishlisted),
                                            size: 18.sp,
                                            color: wishlisted
                                                ? AppColors.primary
                                                : Colors.black87,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                /// ===================================================
                /// PROPERTY INFORMATION
                /// ===================================================
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE
                      Text(
                        listing.propertyName ?? "No Name".tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title16.copyWith(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          height: 1.35,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      /// LOCATION
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.sp,
                            color: AppColors.primary,
                          ),

                          SizedBox(width: 4.w),

                          Expanded(
                            child: Text(
                              listing.addressLine1 ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body13.copyWith(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.inkFaint,
                              ),
                            ),
                          ),

                          if (distance.isNotEmpty)
                            Text(
                              distance,
                              style: AppTextStyles.medium13.copyWith(
                                fontSize: 8.sp,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 5.h),

                      /// PRICE — bold maroon amount, lighter "/ month" suffix
                      /// for rentals, matching the site's listing badges.
                      _PriceLine(
                        amountText: _formattedPrice(),
                        suffix: _priceSuffix(),
                      ),

                      SizedBox(height: 5.h),

                      /// =================================================
                      /// BEDS / BATHS / AREA
                      /// =================================================
                      Row(
                        children: [
                          _statChip(
                            Icons.bed_outlined,
                            "${listing.bedrooms ?? 0} Beds".tr,
                          ),
                          SizedBox(width: 8.w),
                          _statChip(
                            Icons.bathtub_outlined,
                            "${listing.bathrooms ?? 0} Baths".tr,
                          ),
                          SizedBox(width: 8.w),
                          _statChip(Icons.square_foot_rounded, _areaText()),
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

  // =============================================================
  // PURPOSE LABEL ("For Rent" / "For Sale")
  // =============================================================

  String? _purposeLabel() {
    switch (listing.purpose) {
      case 'RENT':
        return "For Rent".tr;
      case 'SALE':
        return "For Sale".tr;
      default:
        return null;
    }
  }

  // =============================================================
  // PRICE
  // =============================================================

  /// "QAR 28,000" — thousands-separated, no decimals when the price is a
  /// whole number.
  String _formattedPrice() {
    final double price = listing.price ?? 0;
    final bool isWhole = price == price.roundToDouble();
    final String raw = isWhole
        ? price.toInt().toString()
        : price.toStringAsFixed(2);

    final parts = raw.split('.');
    final String intPart = parts[0];
    final buffer = StringBuffer();

    for (int i = 0; i < intPart.length; i++) {
      final int posFromEnd = intPart.length - i;
      buffer.write(intPart[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    final String formattedInt = buffer.toString();
    return '${'QAR'.tr} $formattedInt${parts.length > 1 ? '.${parts[1]}' : ''}';
  }

  /// "/ month" for rentals, nothing for sale listings.
  String? _priceSuffix() {
    return listing.purpose == 'RENT' ? '/ month'.tr : null;
  }

  // =============================================================
  // AREA TEXT
  // =============================================================

  String _areaText() {
    if (listing.area != null && listing.area! > 0) {
      return "${listing.area!.toStringAsFixed(0)} ${"m²".tr}";
    }
    return "0 m²";
  }

  // =============================================================
  // STAT CHIP (icon + value, e.g. bed / bath / area)
  // =============================================================

  Widget _statChip(IconData icon, String value) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: AppColors.inkFaint),
          SizedBox(width: 3.w),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.inkMuted, fontSize: 10.sp),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // PROPERTY IMAGE
  // =============================================================

  Widget _buildImage(String cleanImage) {
    final bool validNetworkImage =
        cleanImage.startsWith('https://') || cleanImage.startsWith('http://');

    if (validNetworkImage) {
      return Image.network(
        cleanImage,
        height: 120.h,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          final bool loaded = loadingProgress == null;

          return AnimatedSwitcher(
            duration: AppMotion.medium,
            switchInCurve: AppMotion.curve,
            child: loaded
                ? KeyedSubtree(key: const ValueKey('loaded'), child: child)
                : KeyedSubtree(
                    key: const ValueKey('loading'),
                    child: _imagePlaceholder(showLoader: true),
                  ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    }

    /// LOCAL ASSET
    if (cleanImage.startsWith('assets/')) {
      return Image.asset(
        cleanImage,
        height: 120.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    }

    /// INVALID / EMPTY IMAGE
    return _imagePlaceholder();
  }

  // =============================================================
  // IMAGE PLACEHOLDER
  // =============================================================

  Widget _imagePlaceholder({bool showLoader = false}) {
    return Container(
      height: 120.h,
      width: double.infinity,
      color: const Color(0xffF2F2F2),
      alignment: Alignment.center,
      child: showLoader
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF8E123E),
              ),
            )
          : Icon(
              Icons.home_work_outlined,
              size: 28.sp,
              color: Colors.grey.shade400,
            ),
    );
  }
}

/// "QAR 28,000 / month" — bold maroon amount, lighter gray suffix, laid
/// out on one line matching the card design.
class _PriceLine extends StatelessWidget {
  final String amountText;
  final String? suffix;

  const _PriceLine({required this.amountText, this.suffix});

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: AppTextStyles.bold14.copyWith(
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
        children: [
          TextSpan(text: amountText),
          if (suffix != null && suffix!.trim().isNotEmpty)
            TextSpan(
              text: ' ${suffix!.trim()}',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.inkFaint,
              ),
            ),
        ],
      ),
    );
  }
}
