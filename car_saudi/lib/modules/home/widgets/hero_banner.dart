import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/Core/theme/app_fonts.dart';
import 'package:villas_qatar/Core/utils/app_transitions.dart';
import 'package:villas_qatar/modules/home/model/autocomplete_result.dart';
import 'package:villas_qatar/modules/propertydetailscreen/propertydetailscreen.dart';
import 'package:villas_qatar/modules/propertydetailscreen/service/deeplink_controller.dart';

/// Search intent selected alongside the query.
enum PropertySearchType { rent, sale }

/// Single entry from GET /api/hero-banners.
class HeroBannerModel {
  final String id;
  final String mobileImageUrl;
  final String webImageUrl;
  final String title;
  final String subtitle;

  /// Arabic counterparts the backend sends alongside the English copy.
  /// Either can be null/empty if the dealer hasn't translated that banner
  /// yet, in which case the English text is shown instead.
  final String? arabicTitle;
  final String? arabicHeroText;

  final String? actionUrl;
  final String? actionButtonName;

  const HeroBannerModel({
    required this.id,
    required this.mobileImageUrl,
    required this.webImageUrl,
    required this.title,
    required this.subtitle,
    this.arabicTitle,
    this.arabicHeroText,
    this.actionUrl,
    this.actionButtonName,
  });

  factory HeroBannerModel.fromJson(Map<String, dynamic> json) {
    return HeroBannerModel(
      id: json['id'] as String? ?? '',
      mobileImageUrl: json['mobileImageUrl'] as String? ?? '',
      webImageUrl: json['webImageUrl'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      arabicTitle: json['arabicTitle'] as String?,
      arabicHeroText: json['arabicHeroText'] as String?,
      actionUrl: json['actionUrl'] as String?,
      actionButtonName: json['actionButtonName'] as String?,
    );
  }

  bool get _isArabic => (Get.locale?.languageCode ?? 'en') == 'ar';

  /// [arabicTitle] when the app is in Arabic and the backend provided one,
  /// otherwise the English [title].
  String get displayTitle {
    final String? ar = arabicTitle?.trim();
    return _isArabic && ar != null && ar.isNotEmpty ? ar : title;
  }

  /// [arabicHeroText] when the app is in Arabic and the backend provided
  /// one, otherwise the English [subtitle].
  String get displaySubtitle {
    final String? ar = arabicHeroText?.trim();
    return _isArabic && ar != null && ar.isNotEmpty ? ar : subtitle;
  }
}

/// Home hero: a full-bleed property photograph with a headline and an
/// "Explore Properties" CTA, topped by a Rent/Buy search card that overlaps
/// the bottom edge of the photo. The banner (image + title + subtitle) is
/// fetched directly from GET /api/hero-banners inside this widget — no
/// separate controller/service.
class HomeBanner extends StatefulWidget {
  /// Passes back the query text, which mode (rent/sale) was active, and — if
  /// the query came from picking a place suggestion — its coordinates.
  final void Function(
    String propertyName,
    PropertySearchType type, {
    double? latitude,
    double? longitude,
  })
  onSearch;

  /// "Explore Properties" button on the photo. Passes back the active
  /// banner's `actionUrl` (may be null).
  final void Function(String? actionUrl)? onExploreProperties;

  /// "Advanced Filters" link on the search card.
  final VoidCallback? onAdvancedFilters;

  const HomeBanner({
    super.key,
    required this.onSearch,
    this.onExploreProperties,
    this.onAdvancedFilters,
  });

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  static const String _heroBannersEndpoint =
      'https://apivillas.palqar.cloud/api/hero-banners';

  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final PageController _pageController = PageController();

  PropertySearchType _selectedType = PropertySearchType.sale;
  bool _isFocused = false;
  int _activeIndex = 0;

  bool _loading = true;
  List<HeroBannerModel> _slides = const [];

  Timer? _autocompleteDebounce;
  bool _suggestionsLoading = false;
  List<AutocompleteResult> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    _loadHeroBanners();
  }

  /// Debounced GET /api/search/autocomplete?q=... as the user types.
  void _onQueryChanged(String value) {
    _autocompleteDebounce?.cancel();

    final String query = value.trim();

    if (query.length < 2) {
      setState(() {
        _suggestions = const [];
        _suggestionsLoading = false;
      });
      return;
    }

    _autocompleteDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _fetchAutocomplete(query),
    );
  }

  Future<void> _fetchAutocomplete(String query) async {
    if (!mounted) return;

    setState(() => _suggestionsLoading = true);

    try {
      final dynamic response = await ApiHandler.get(
        ApiEndpoints.searchAutocomplete(query),
      );

      final List<dynamic> rawResults = response is Map
          ? (response['results'] as List<dynamic>? ?? const [])
          : const [];

      final List<AutocompleteResult> results = rawResults
          .whereType<Map>()
          .map((e) => AutocompleteResult.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _suggestionsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = const [];
        _suggestionsLoading = false;
      });
    }
  }

  /// A place fills the field with its name and immediately searches with
  /// its coordinates attached; a property opens straight to its details.
  void _selectSuggestion(AutocompleteResult result) {
    FocusScope.of(context).unfocus();

    setState(() => _suggestions = const []);

    if (result.type == AutocompleteResultType.property) {
      searchController.clear();
      _openPropertyBySlug(result.slug);
      return;
    }

    widget.onSearch(
      result.name,
      _selectedType,
      latitude: result.latitude,
      longitude: result.longitude,
    );

    searchController.clear();
  }

  Future<void> _openPropertyBySlug(String? slug) async {
    if (slug == null || slug.trim().isEmpty) return;

    final DeepLinkController deepLinkController =
        Get.isRegistered<DeepLinkController>()
        ? Get.find<DeepLinkController>()
        : Get.put(DeepLinkController(), permanent: true);

    final property = await deepLinkController.fetchPropertyBySlug(slug: slug);

    if (property == null || !mounted) return;

    Get.to(
      () => PropertyDetailsScreen(propertyId: property.id),
      transition: AppTransitions.forward,
    );
  }

  /// Direct API call — no controller/service in between.
  Future<void> _loadHeroBanners() async {
    try {
      final response = await http
          .get(Uri.parse(_heroBannersEndpoint), headers: {'accept': '*/*'})
          .timeout(const Duration(seconds: 12));

      List<HeroBannerModel> parsed = [];
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          parsed = decoded
              .map((e) => HeroBannerModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      if (!mounted) return;
      setState(() {
        _slides = parsed;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _slides = const [];
        _loading = false;
      });
    }
  }

  void _searchProperty() {
    final propertyName = searchController.text.trim();

    if (propertyName.isEmpty) return;

    FocusScope.of(context).unfocus();

    // Pass search value + selected type
    widget.onSearch(propertyName, _selectedType);

    // Then clear TextField
    searchController.clear();
  }

  @override
  void dispose() {
    _autocompleteDebounce?.cancel();
    searchController.dispose();
    _focusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fallback content if the API returns nothing / fails.
    final HeroBannerModel fallback = HeroBannerModel(
      id: 'fallback',
      mobileImageUrl: '',
      webImageUrl: '',
      title: 'A Better Way to Live in Qatar'.tr,
      subtitle:
          'Discover exceptional homes in Qatar — buy, rent or invest with confidence.'
              .tr,
    );

    final List<HeroBannerModel> slides = _slides.isNotEmpty
        ? _slides
        : [fallback];
    final int activeIndex = _activeIndex.clamp(0, slides.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _photoHeight.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  /// Background photograph(s) — swipeable if the API
                  /// returns more than one banner.
                  PageView.builder(
                    controller: _pageController,
                    itemCount: slides.length,
                    onPageChanged: (i) => setState(() => _activeIndex = i),
                    itemBuilder: (context, index) {
                      return _BannerImage(
                        loading: _loading,
                        imageUrl: slides[index].mobileImageUrl,
                      );
                    },
                  ),

                  /// Horizontal scrim — dark on the text side, clearing to
                  /// the right.
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          // Dark on the text side: left in LTR, right in RTL.
                          begin: AlignmentDirectional.centerStart,
                          end: AlignmentDirectional.centerEnd,
                          colors: [
                            Color(0xE60B1019),
                            Color(0x8C0B1019),
                            Color(0x1F0B1019),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  /// Bottom scrim so the caption + dots read on the photo.
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0x990B1019), Color(0x000B1019)],
                          stops: [0.0, 0.5],
                        ),
                      ),
                    ),
                  ),

                  /// Content
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 22.h, 12.w, 0.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _HeroEyebrow(),

                        SizedBox(height: 14.h),

                        /// Headline from the API's `title` (or its Arabic
                        /// counterpart), last word picked out in gold.
                        _HeroTitle(title: slides[activeIndex].displayTitle),

                        SizedBox(height: 10.h),

                        SizedBox(
                          width: 250.w,
                          child: Text(
                            slides[activeIndex].displaySubtitle,
                            style: TextStyle(
                              fontFamily: AppFonts.currentFont,
                              fontSize: 11.5.sp,
                              height: 1.5,
                              color: Colors.white.withOpacity(.88),
                            ),
                          ),
                        ),

                        SizedBox(height: 18.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// ---- Search card — overlaps the photo's bottom edge ----
            ///
            /// The card is the Stack's in-flow child, pinned by a fixed top
            /// offset. When the autocomplete list opens it grows downward and
            /// pushes the content below it, instead of the card being
            /// bottom-anchored and climbing up over the photo.
            Padding(
              padding: EdgeInsets.only(top: _searchCardTop),
              child: _SearchCard(
                selectedType: _selectedType,
                onTypeChanged: (type) => setState(() => _selectedType = type),
                controller: searchController,
                focusNode: _focusNode,
                isFocused: _isFocused,
                onSubmit: _searchProperty,
                onAdvancedFilters: widget.onAdvancedFilters,
                onQueryChanged: _onQueryChanged,
                suggestions: _suggestions,
                suggestionsLoading: _suggestionsLoading,
                onSuggestionSelected: _selectSuggestion,
              ),
            ),
          ],
        ),

        SizedBox(height: 4.h),
      ],
    );
  }

  static const double _photoHeight = 250;

  /// How far the search card hangs below the photo's bottom edge.
  static const double _cardOverhang = 35;

  /// Top offset that lands the collapsed card (14.w padding, 34.h toggle,
  /// 10.h gap, 48.h field, 14.w padding) [_cardOverhang] below the photo.
  double get _searchCardTop => _photoHeight.h + _cardOverhang.h - (92.h + 28.w);
}

/// Renders the banner photo from the network, with a placeholder while
/// loading and a graceful fallback to the bundled asset if the URL is
/// empty or fails to load.
class _BannerImage extends StatelessWidget {
  final bool loading;
  final String imageUrl;

  const _BannerImage({required this.loading, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(color: AppColors.maroonDeep.withOpacity(.85));
    }

    if (imageUrl.isEmpty) {
      return Image.asset(
        "assets/hero-bg.jpg",
        fit: BoxFit.cover,
        alignment: AlignmentDirectional.centerEnd,
        errorBuilder: (_, __, ___) => Container(color: AppColors.maroonDeep),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      alignment: AlignmentDirectional.centerEnd,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(color: AppColors.maroonDeep.withOpacity(.85));
      },
      errorBuilder: (_, __, ___) => Image.asset(
        "assets/hero-bg.jpg",
        fit: BoxFit.cover,
        alignment: AlignmentDirectional.centerEnd,
        errorBuilder: (_, __, ___) => Container(color: AppColors.maroonDeep),
      ),
    );
  }
}

/// "A Better Way to Live in Qatar" style headline, built dynamically from
/// the API's `title` string — every word white except the last, which is
/// picked out in gold.
class _HeroTitle extends StatelessWidget {
  final String title;

  const _HeroTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final words = title.trim().split(RegExp(r'\s+'));
    final String lastWord = words.isNotEmpty ? words.removeLast() : '';
    final String leadingText = words.isEmpty ? '' : '${words.join(' ')} ';

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: AppFonts.currentFont,
          fontSize: 26.sp,
          fontWeight: FontWeight.w700,
          height: 1.18,
          letterSpacing: -0.3,
          color: Colors.white,
        ),
        children: [
          if (leadingText.isNotEmpty) TextSpan(text: leadingText),
          TextSpan(
            text: lastWord,
            style: const TextStyle(color: AppColors.gold),
          ),
        ],
      ),
    );
  }
}

/// Uppercase eyebrow label over the hero photo.
class _HeroEyebrow extends StatelessWidget {
  const _HeroEyebrow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "PREMIUM PROPERTIES".tr,
          style: TextStyle(
            fontFamily: AppFonts.currentFont,
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: AppColors.goldPale,
          ),
        ),
        SizedBox(width: 8.w),
        Icon(Icons.circle, size: 4.sp, color: AppColors.goldPale),
      ],
    );
  }
}

/// White "Explore Properties" pill button. Uses the banner's own
/// `actionButtonName` when the API provides one, otherwise falls back to
/// the default label.
class _ExploreButton extends StatelessWidget {
  final String? label;
  final VoidCallback? onTap;

  const _ExploreButton({this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String text = (label != null && label!.trim().isNotEmpty)
        ? label!
        : "Explore Properties".tr;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: AppFonts.currentFont,
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_rounded,
              size: 15.sp,
              color: AppColors.ink,
            ),
          ],
        ),
      ),
    );
  }
}

/// Carousel dots — one per banner returned by the API.
class _HeroDots extends StatelessWidget {
  final int activeIndex;
  final int count;

  const _HeroDots({required this.activeIndex, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final bool active = index == activeIndex;

        return Container(
          margin: EdgeInsetsDirectional.only(end: 5.w),
          width: active ? 14.w : 5.w,
          height: 5.w,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withOpacity(.45),
            borderRadius: BorderRadius.circular(999.r),
          ),
        );
      }),
    );
  }
}

/// White search card: Rent/Buy toggle + Advanced Filters, then the search
/// field — floated over the hero photo's bottom edge.
class _SearchCard extends StatelessWidget {
  final PropertySearchType selectedType;
  final ValueChanged<PropertySearchType> onTypeChanged;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final VoidCallback onSubmit;
  final VoidCallback? onAdvancedFilters;
  final ValueChanged<String> onQueryChanged;
  final List<AutocompleteResult> suggestions;
  final bool suggestionsLoading;
  final ValueChanged<AutocompleteResult> onSuggestionSelected;

  const _SearchCard({
    required this.selectedType,
    required this.onTypeChanged,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.onSubmit,
    this.onAdvancedFilters,
    required this.onQueryChanged,
    required this.suggestions,
    required this.suggestionsLoading,
    required this.onSuggestionSelected,
  });

  bool get _showSuggestions =>
      isFocused && (suggestionsLoading || suggestions.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _SearchTypeToggle(
                selected: selectedType,
                onChanged: onTypeChanged,
              ),
              const Spacer(),
            ],
          ),

          SizedBox(height: 10.h),

          _SearchField(
            controller: controller,
            focusNode: focusNode,
            isFocused: isFocused,
            onSubmit: onSubmit,
            onChanged: onQueryChanged,
          ),

          if (_showSuggestions) ...[
            SizedBox(height: 8.h),
            _SuggestionsList(
              loading: suggestionsLoading,
              suggestions: suggestions,
              onSelected: onSuggestionSelected,
            ),
          ],
        ],
      ),
    );
  }
}

/// Pill-shaped Rent / Buy segmented toggle.
class _SearchTypeToggle extends StatelessWidget {
  final PropertySearchType selected;
  final ValueChanged<PropertySearchType> onChanged;

  const _SearchTypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34.h,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.warmBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(context, "Buy".tr, PropertySearchType.sale),
          _buildOption(context, "Rent".tr, PropertySearchType.rent),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    String label,
    PropertySearchType type,
  ) {
    final bool isActive = selected == type;

    return GestureDetector(
      onTap: () => onChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          gradient: isActive ? AppColors.ctaGradient : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.currentFont,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.inkMuted,
          ),
        ),
      ),
    );
  }
}

/// Location search field with a plain magnifier prefix and a filled circular
/// search button, matching the site's search bar.
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final VoidCallback onSubmit;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.onSubmit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isFocused ? AppColors.primary : AppColors.warmBorder,
          width: isFocused ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 14.w),

          Icon(Icons.search_rounded, color: AppColors.inkFaint, size: 19.sp),

          SizedBox(width: 8.w),

          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmit(),
              style: TextStyle(
                fontFamily: AppFonts.currentFont,
                fontSize: 12.sp,
                color: AppColors.ink,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search by location, area or landmark".tr,
                isDense: true,
                isCollapsed: true,
                hintStyle: TextStyle(
                  fontFamily: AppFonts.currentFont,
                  fontSize: 11.sp,
                  color: AppColors.inkFaint,
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(6.w),
            child: GestureDetector(
              onTap: onSubmit,
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  gradient: AppColors.ctaGradient,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Autocomplete dropdown — places (with coordinates) and existing
/// properties (opened directly by slug), rendered under the search field.
class _SuggestionsList extends StatelessWidget {
  final bool loading;
  final List<AutocompleteResult> suggestions;
  final ValueChanged<AutocompleteResult> onSelected;

  const _SuggestionsList({
    required this.loading,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 240.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.warmBorder),
      ),
      child: loading
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: Center(
                child: SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 6.h),
              physics: const ClampingScrollPhysics(),
              itemCount: suggestions.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: AppColors.warmBorder),
              itemBuilder: (context, index) {
                final AutocompleteResult result = suggestions[index];
                final bool isPlace =
                    result.type == AutocompleteResultType.place;

                return InkWell(
                  onTap: () => onSelected(result),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPlace ? Icons.place_outlined : Icons.villa_outlined,
                          size: 17.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            result.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.currentFont,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          isPlace ? "Place".tr : "Property".tr,
                          style: TextStyle(
                            fontFamily: AppFonts.currentFont,
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkFaint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
