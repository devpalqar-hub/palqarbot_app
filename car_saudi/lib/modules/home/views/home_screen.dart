import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/theme/app_theme.dart';
import 'package:villas_qatar/Core/utils/app_location.dart';
import 'package:villas_qatar/Core/utils/app_transitions.dart';
import 'package:villas_qatar/Core/widgets/motion/app_shimmer.dart';
import 'package:villas_qatar/Core/widgets/motion/staggered_entrance_column.dart';
import 'package:villas_qatar/modules/PlansandFeatures/model/featured_property_model.dart';
import 'package:villas_qatar/modules/PlansandFeatures/services/FeaturedPropertiesController.dart';
import 'package:villas_qatar/modules/dealers/service/dealer_controller.dart';
import 'package:villas_qatar/modules/dealers/view/dealer_detail_screen.dart';
import 'package:villas_qatar/modules/dealers/view/detail_list_screen.dart';
import 'package:villas_qatar/modules/home/service/HomeController.dart';
import 'package:villas_qatar/modules/home/service/UtilsController.dart';
import 'package:villas_qatar/modules/home/service/banner_controller.dart';
import 'package:villas_qatar/modules/home/service/loaction_controller.dart';
import 'package:villas_qatar/modules/home/widgets/agent_card.dart';
import 'package:villas_qatar/modules/home/widgets/banner_carousel.dart';
import 'package:villas_qatar/modules/home/widgets/category_card.dart';
import 'package:villas_qatar/modules/home/widgets/dealer_cta_card.dart';
import 'package:villas_qatar/modules/home/widgets/featured_properties_carousel.dart';
import 'package:villas_qatar/modules/home/widgets/home_app_bar.dart';
import 'package:villas_qatar/modules/home/widgets/popular_place_card.dart';
import 'package:villas_qatar/modules/home/widgets/price_estimator_card.dart';
import 'package:villas_qatar/modules/home/widgets/hero_banner.dart';
import 'package:villas_qatar/modules/home/widgets/location_card.dart';
import 'package:villas_qatar/modules/home/widgets/section_header.dart';
import 'package:villas_qatar/modules/home/widgets/social_media_card.dart';
import 'package:villas_qatar/modules/home/widgets/sponser_banner.dart';
import 'package:villas_qatar/modules/home/widgets/why_choose_card.dart';
import 'package:villas_qatar/modules/pricestimator/views/price_estimator_screen.dart';

class HomeScreen extends StatefulWidget {
  /// Fired when the AI search bar's arrow is tapped — carries the typed
  /// query plus which Rent/Sale toggle was active ("RENT" / "SALE").
  final void Function(
    String propertyName,
    String purpose, {
    double? latitude,
    double? longitude,
  })
  onSearch;
  final void Function(String type) onCategorySelected;
  final void Function(String purpose) onPurposeSelected;

  /// Opens the Search screen, optionally scoped to a municipality
  /// ([locationId]) — used by "See all" and the popular places.
  final void Function({String? locationId}) onOpenSearch;

  const HomeScreen({
    super.key,
    required this.onSearch,
    required this.onCategorySelected,
    required this.onPurposeSelected,
    required this.onOpenSearch,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FeaturedPropertiesController featuredController;
  late final BannerController bannerController;
  late final DealerController dealerController;
  final ScrollController featuredScrollController = ScrollController();
  final Utilscontroller utilscontroller = Get.put(Utilscontroller());
  final LocationController locationcontroller = Get.put(LocationController());
  @override
  void initState() {
    super.initState();

    featuredController = Get.isRegistered<FeaturedPropertiesController>()
        ? Get.find<FeaturedPropertiesController>()
        : Get.put(FeaturedPropertiesController(), permanent: true);

    bannerController = Get.isRegistered<BannerController>()
        ? Get.find<BannerController>()
        : Get.put(BannerController(), permanent: true);

    dealerController = Get.isRegistered<DealerController>()
        ? Get.find<DealerController>()
        : Get.put(DealerController());
  }

  @override
  void dispose() {
    featuredScrollController.dispose();

    super.dispose();
  }

  Homecontroller hctrl = Get.put(Homecontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      body: GetBuilder<Homecontroller>(
        builder: (___) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: hctrl.refreshHomeScreenData,
            child: SingleChildScrollView(
              // Always scrollable so the pull still triggers a refresh when the
              // content is shorter than the screen.
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: StaggeredEntranceColumn(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// ─── HERO ────────────────────────────────────────────────────
                  HomeBanner(
                    onSearch: (propertyName, type, {latitude, longitude}) {
                      widget.onSearch(
                        propertyName,
                        type == PropertySearchType.rent ? "RENT" : "SALE",
                        latitude: latitude,
                        longitude: longitude,
                      );
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: SectionHeader(
                      title: 'Featured Properties'.tr,
                      subtitle: 'Handpicked homes in the best locations'.tr,
                      onSeeAllTap: () => widget.onOpenSearch(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  FeaturedPropertiesCarousel(
                    properties: hctrl.featuredProperties,
                  ),

                  /// ─── FEATURED PROPERTIES ────────────────────────────────────
                  SizedBox(height: 12.h),

                  /// ─── AI PRICE ESTIMATOR ─────────────────────────────────────
                  _spaced(
                    Padding(
                      padding: _gutter,
                      child: PriceEstimatorCard(
                        onGetEstimate: () {
                          Get.to(
                            () => const PriceEstimatorScreen(),
                            transition: AppTransitions.forward,
                          );
                        },
                      ),
                    ),
                  ),

                  /// ─── SEARCH BY PROPERTY TYPE ────────────────────────────────
                  _buildCategoriesSection(),

                  /// ─── NEAR YOU ───────────────────────────────────────────────
                  _buildNearYouSection(),

                  /// ─── SPONSORED BANNERS ──────────────────────────────────────
                  _buildBannersSection(),

                  /// ─── FEATURED DEALERS ───────────────────────────────────────
                  _buildDealersSection(),

                  /// ─── POPULAR PLACES ─────────────────────────────────────────
                  _buildPopularPlacesSection(),
                  _spaced(
                    Padding(
                      padding: _gutter,
                      child: DealerCtaCard(
                        onBecomeDealer: _openDealerOnboarding,
                      ),
                    ),
                  ),

                  /// ─── TRUST STRIP ────────────────────────────────────────────
                  Padding(
                    padding: _gutter,
                    child: WhyChooseCard(onTap: _openWebsite),
                  ),

                  /// ─── JOIN US ON SOCIAL MEDIA ────────────────────────────────
                  SizedBox(height: _sectionGap.h),
                  Padding(padding: _gutter, child: const SocialMediaCard()),

                  // No bottom bar any more, so clear the system gesture area.
                  SizedBox(height: 24.h + MediaQuery.paddingOf(context).bottom),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Horizontal page gutter — the 16px side margin the website uses on mobile.
  EdgeInsets get _gutter => EdgeInsets.symmetric(horizontal: 16.w);

  /// Vertical rhythm between home sections.
  static const double _sectionGap = 12;

  /// Adds the trailing section gap to [child].
  ///
  /// The gap lives inside each section rather than on the parent Column, so a
  /// section that has nothing to show can collapse to zero height without
  /// leaving a hole in the page.
  Widget _spaced(Widget child) => Padding(
    padding: EdgeInsets.only(bottom: _sectionGap.h),
    child: child,
  );

  static const double _headerGap = 14;

  /// ═══════════════════════════════════════════════════════════════════════
  /// SEARCH BY PROPERTY TYPE
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildCategoriesSection() {
    return GetBuilder<Utilscontroller>(
      builder: (controller) {
        if (controller.isLoading && controller.listingTypes.isEmpty) {
          return _spaced(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: _gutter,
                  child: SectionHeader(
                    title: "Search by Property Type".tr,
                    subtitle: "Find the right property type for your search".tr,
                    showSeeAll: false,
                  ),
                ),

                SizedBox(height: 8.h),

                SizedBox(
                  height: 110.h,
                  child: AppShimmer(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: 3,
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemBuilder: (_, __) => ShimmerBox(
                        width: 110.w,
                        height: 110.h,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.listingTypes.isEmpty) {
          return const SizedBox.shrink();
        }

        return _spaced(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: _gutter,
                child: SectionHeader(
                  title: "Search by Property Type".tr,
                  subtitle: "Find the right property type for your search".tr,
                  onSeeAllTap: () => widget.onOpenSearch(),
                ),
              ),

              SizedBox(height: 8.h),

              SizedBox(
                height: 120.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: controller.listingTypes.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (_, index) {
                    final type = controller.listingTypes[index];

                    return SizedBox(
                      width: 110.w,
                      child: CategoryCard(
                        title: type.title.tr,
                        imageUrl: type.image,
                        listingCount: type.listingCount,
                        onTap: () => widget.onCategorySelected(type.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// NEAR YOU
  /// ═══════════════════════════════════════════════════════════════════════
  Widget _buildNearYouSection() {
    return GetBuilder<LocationController>(
      builder: (controller) {
        // Nothing nearby (and not still loading) — drop the whole
        // "Near You" section instead of showing an empty header
        // over a "No nearby properties" placeholder.
        if (!controller.isNearbyLoading &&
            controller.nearbyProperties.isEmpty) {
          return const SizedBox.shrink();
        }

        return _spaced(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: _gutter,
                child: SectionHeader(
                  title: "Near You".tr,
                  subtitle: "Listings closest to where you are right now".tr,
                  showSeeAll: false,
                ),
              ),

              SizedBox(height: _headerGap.h),

              SizedBox(
                height: 120.h,
                child: controller.isNearbyLoading
                    ? AppShimmer(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: _gutter,
                          itemCount: 3,
                          separatorBuilder: (_, __) => SizedBox(width: 12.w),
                          itemBuilder: (_, __) => ShimmerBox(
                            width: 180.w,
                            height: 120.h,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: _gutter,
                        itemCount: controller.nearbyProperties.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12.w),
                        itemBuilder: (context, index) {
                          return LocationCard(
                            property: controller.nearbyProperties[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// FEATURED DEALERS
  /// ═══════════════════════════════════════════════════════════════════════
  Widget _buildDealersSection() {
    return GetBuilder<DealerController>(
      builder: (controller) {
        if (!controller.isLoading && controller.dealers.isEmpty) {
          return const SizedBox.shrink();
        }

        return _spaced(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: _gutter,
                child: SectionHeader(
                  title: "Featured Dealers".tr,
                  subtitle: "Trusted agencies listing across Qatar".tr,
                  onSeeAllTap: () {
                    Get.to(() => const DealerListScreen());
                  },
                ),
              ),

              SizedBox(height: _headerGap.h),

              SizedBox(
                height: 70.h,
                child: controller.isLoading && controller.dealers.isEmpty
                    ? AppShimmer(
                        child: ListView.separated(
                          padding: _gutter,
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          separatorBuilder: (_, __) => SizedBox(width: 12.w),
                          itemBuilder: (_, __) => ShimmerBox(
                            width: 120.w,
                            height: 50.h,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: _gutter,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.dealers.length,
                        separatorBuilder: (_, __) => SizedBox(width: 6.w),
                        itemBuilder: (_, index) {
                          final dealer = controller.dealers[index];

                          return CompactAgentCard(
                            image: dealer.dealerProfile.coverImage,
                            name: dealer.dealerProfile.dealerName.isNotEmpty
                                ? dealer.dealerProfile.dealerName
                                : dealer.name,
                            onTap: () {
                              Get.to(
                                () => const DealerDetailsScreen(),
                                arguments: dealer.id,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// POPULAR PLACES
  /// ═══════════════════════════════════════════════════════════════════════
  Widget _buildPopularPlacesSection() {
    return GetBuilder<Utilscontroller>(
      builder: (controller) {
        final places = controller.popularMunicipalities;

        if (places.isEmpty) {
          return const SizedBox.shrink();
        }

        return _spaced(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: _gutter,
                child: SectionHeader(
                  title: "Popular Places in Qatar".tr,
                  subtitle:
                      "Discover properties in the most sought-after locations"
                          .tr,
                  showSeeAll: false,
                  onSeeAllTap: () => widget.onOpenSearch(),
                ),
              ),

              SizedBox(height: _headerGap.h),

              SizedBox(
                height: 100.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: _gutter,
                  itemCount: places.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (_, index) {
                    final place = places[index];

                    return PopularPlaceCard(
                      place: place,
                      onTap: () => widget.onOpenSearch(locationId: place.id),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildBannersSection() {
  return GetBuilder<BannerController>(
    builder: (controller) {
      /// INITIAL LOADING
      if (controller.isLoading && controller.banners.isEmpty) {
        return Padding(
          padding: _bannerInsets,
          child: Container(
            width: double.infinity,
            height: 150.h,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.warmBorder),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 22.w,
              height: 22.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      }

      /// NO BANNERS / ERROR
      if (controller.banners.isEmpty) {
        return const SizedBox.shrink();
      }

      final now = DateTime.now();

      /// Only banners that are:
      /// 1. Active
      /// 2. Started
      /// 3. Not expired
      final banners = controller.banners.where((banner) {
        if (!banner.isActive) {
          return false;
        }

        if (banner.startDate != null && now.isBefore(banner.startDate!)) {
          return false;
        }

        if (banner.endDate != null && now.isAfter(banner.endDate!)) {
          return false;
        }

        return true;
      }).toList();

      /// Sort according to API position.
      banners.sort((a, b) => a.position.compareTo(b.position));

      if (banners.isEmpty) {
        return const SizedBox.shrink();
      }

      /// ONE BANNER
      if (banners.length == 1) {
        final banner = banners.first;

        return Padding(
          padding: _bannerInsets,
          child: InvestmentBanner(
            banner: banner,
            onTap: () {
              _handleBannerTap(banner.linkUrl);
            },
          ),
        );
      }

      /// MULTIPLE BANNERS — auto-advancing carousel with page dots.
      /// (Horizontal inset is 4.w smaller than the single banner's because
      /// each page carries its own 4.w gutter.)
      return Padding(
        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
        child: BannerCarousel(
          banners: banners,
          onTap: (banner) => _handleBannerTap(banner.linkUrl),
        ),
      );
    },
  );
}

/// Gutter + trailing section gap for the banner strip, matching the rhythm the
/// other home sections use.
EdgeInsets get _bannerInsets => EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h);

/// Dealer sign-up happens on the website, not in the app.
const String _dealerOnboardingUrl =
    'https://dealer.villasqatar.qa/dealer-onboarding';

const String _websiteUrl = 'https://villasqatar.qa/';

Future<void> _openDealerOnboarding() => _openExternalUrl(_dealerOnboardingUrl);

Future<void> _openWebsite() => _openExternalUrl(_websiteUrl);

/// Opens [url] in the phone's browser.
Future<void> _openExternalUrl(String url) async {
  try {
    final bool launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      debugPrint("Unable to open URL: $url");
    }
  } catch (e) {
    debugPrint("URL launch error ($url): $e");
  }
}

Future<void> _handleBannerTap(String linkUrl) async {
  if (linkUrl.trim().isEmpty) {
    return;
  }

  final Uri? uri = Uri.tryParse(linkUrl.trim());

  if (uri == null) {
    debugPrint("Invalid banner URL: $linkUrl");
    return;
  }

  try {
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      debugPrint("Unable to open banner URL: $linkUrl");
    }
  } catch (e) {
    debugPrint("Banner URL error: $e");
  }
}

class LocationBottomSheet extends StatelessWidget {
  const LocationBottomSheet({super.key, required this.controller});

  final LocationController controller;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: .50,
          // minChildSize: .45,
          maxChildSize: .60,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 12.h),

                  /// Handle
                  Container(
                    width: 55.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  /// Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Choose Location".tr,
                            style: AppTextStyles.title18.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: Get.back,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded, size: 18.sp),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.r),
                      onTap: () async {
                        await controller.detectCurrentLocation();
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: AppColors.primary.withOpacity(.05),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.04),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 35.h,
                              width: 35.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.my_location_rounded,
                                color: Colors.white,
                                size: 15.sp,
                              ),
                            ),

                            SizedBox(width: 14.w),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Use Current Location".tr,
                                    style: AppTextStyles.medium14.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Detect location using GPS".tr,
                                    style: AppTextStyles.body13.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.primary,
                                size: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  /// Search Box
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: TextField(
                      controller: controller.searchController,
                      textInputAction: TextInputAction.search,
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Search city, area or landmark".tr,

                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.grey.shade600,
                        ),

                        suffixIcon: controller.searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  controller.searchController.clear();
                                  controller.results.clear();
                                  controller.update();
                                },
                                icon: const Icon(Icons.close_rounded),
                              )
                            : null,

                        filled: true,
                        fillColor: Colors.grey.shade100,

                        contentPadding: EdgeInsets.symmetric(vertical: 16.h),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  if (controller.isLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  if (!controller.isLoading)
                    Expanded(
                      child: controller.results.isEmpty
                          ? SingleChildScrollView(
                              controller: scrollController,
                              physics: const BouncingScrollPhysics(),
                              child: SizedBox(
                                height: 180.h,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 45.w,
                                      width: 45.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          .08,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.location_searching_rounded,
                                        color: AppColors.primary,
                                        size: 20.sp,
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    Text(
                                      controller.searchController.text.isEmpty
                                          ? "Search for a location".tr
                                          : "No locations found".tr,
                                      style: AppTextStyles.medium14.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 40.w,
                                      ),
                                      child: Text(
                                        controller.searchController.text.isEmpty
                                            ? "Search by city, area or landmark"
                                                  .tr
                                            : "Try another keyword".tr,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.body13.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 25.h),
                              itemCount: controller.results.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (_, index) {
                                final item = controller.results[index];

                                return Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18.r),
                                  elevation: .5,
                                  shadowColor: Colors.black12,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18.r),
                                    onTap: () {
                                      controller.selectLocation(item);
                                      Get.back();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(14.w),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 45.w,
                                            height: 45.w,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(.08),
                                              borderRadius:
                                                  BorderRadius.circular(15.r),
                                            ),
                                            child: Icon(
                                              Icons.location_on_rounded,
                                              color: AppColors.primary,
                                              size: 20.sp,
                                            ),
                                          ),

                                          SizedBox(width: 14.w),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.data.areaName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTextStyles.medium14
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),

                                                SizedBox(height: 5.h),

                                                Text(
                                                  item.data.formattedAddress,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTextStyles.body13
                                                      .copyWith(
                                                        color: Colors
                                                            .grey
                                                            .shade600,
                                                        height: 1.4,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          SizedBox(width: 8.w),

                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: AppColors.primary,
                                            size: 14.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
