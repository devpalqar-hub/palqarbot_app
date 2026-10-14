import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/primary_button.dart';
import 'package:villas_qatar/modules/home/model/ListingOptions.dart';
import 'package:villas_qatar/modules/home/model/autocomplete_result.dart';
import 'package:villas_qatar/modules/home/service/UtilsController.dart';
import 'package:villas_qatar/modules/propertylist/model/property_filter.dart';
import 'package:villas_qatar/modules/searchscreen/service/searchlist_screen.dart';

/// A sort choice in the Sort dropdown, mapped to the API's
/// `sortBy` / `sortOrder` query parameters.
class _SortOption {
  final String label;
  final String sortBy;
  final String sortOrder;

  const _SortOption(this.label, this.sortBy, this.sortOrder);
}

const List<_SortOption> _sortOptions = [
  _SortOption("Newest", "createdAt", "desc"),
  _SortOption("Oldest", "createdAt", "asc"),
  _SortOption("Price: Low to High", "price", "asc"),
  _SortOption("Price: High to Low", "price", "desc"),
  _SortOption("Area: Low to High", "area", "asc"),
  _SortOption("Area: High to Low", "area", "desc"),
];

class SearchFilterCard extends StatefulWidget {
  final PropertySearchController controller;

  const SearchFilterCard({super.key, required this.controller});

  @override
  State<SearchFilterCard> createState() => _SearchFilterCardState();
}

class _SearchFilterCardState extends State<SearchFilterCard> {
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _autocompleteDebounce;
  bool _suggestionsLoading = false;
  List<AutocompleteResult> _suggestions = const [];

  final List<String> tabs = ["Buy".tr, "Rent".tr];

  PropertyFilter get _filter => widget.controller.filter;

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _autocompleteDebounce?.cancel();
    _searchFocusNode.dispose();
    super.dispose();
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

  /// Either a place or a property just fills the field and searches — the
  /// matching properties list below on this same screen. A place's
  /// coordinates come along when it has any; a property matches by name.
  Future<void> _selectSuggestion(AutocompleteResult result) async {
    FocusScope.of(context).unfocus();

    setState(() => _suggestions = const []);

    await widget.controller.applyFilters(
      search: result.name,
      latitude: result.latitude,
      longitude: result.longitude,
    );
  }

  /// Runs the search for whatever is typed in the field.
  Future<void> _submitSearch() async {
    FocusScope.of(context).unfocus();

    _autocompleteDebounce?.cancel();
    setState(() {
      _suggestions = const [];
      _suggestionsLoading = false;
    });

    await widget.controller.applyFilters(
      search: widget.controller.searchTextController.text,
    );
  }

  bool get _showSuggestions =>
      _searchFocusNode.hasFocus &&
      (_suggestionsLoading || _suggestions.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    // No tab is highlighted until Buy or Rent is chosen — with neither set,
    // the results include both.
    final int selectedTab = switch (_filter.purpose) {
      "SALE" => 0,
      "RENT" => 1,
      _ => -1,
    };

    int? selectedSort;
    if (_filter.sortBy.isNotEmpty) {
      final int index = _sortOptions.indexWhere(
        (o) => o.sortBy == _filter.sortBy && o.sortOrder == _filter.sortOrder,
      );
      if (index >= 0) selectedSort = index;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          /// BUY / RENT TOGGLE (tap the active tab again to clear it)
          Container(
            height: 42.h,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final selected = selectedTab == index;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.controller.applyFilters(
                        purpose: selected ? "" : (index == 0 ? "SALE" : "RENT"),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        tabs[index],
                        style: AppTextStyles.title14.copyWith(
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : const Color(0xff32354A),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 12.h),

          /// SEARCH FIELD
          Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xffE6E9EF), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 20.sp, color: Colors.grey.shade600),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: widget.controller.searchTextController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    style: AppTextStyles.body14.copyWith(
                      color: const Color(0xff32354A),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: "Search by location, area or property".tr,
                      hintStyle: AppTextStyles.body13.copyWith(
                        color: const Color(0xffA5ADBA),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _onQueryChanged(value);
                      if (value.trim().isEmpty && _filter.search.isNotEmpty) {
                        widget.controller.clearSearch();
                      }
                    },
                    onSubmitted: (_) => _submitSearch(),
                  ),
                ),
                if (widget.controller.searchTextController.text.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      setState(() => _suggestions = const []);
                      await widget.controller.clearSearch();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Icon(Icons.close, size: 18.sp, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),

          if (_showSuggestions) ...[
            SizedBox(height: 4.h),
            _SuggestionsList(
              loading: _suggestionsLoading,
              suggestions: _suggestions,
              onSelected: _selectSuggestion,
            ),
          ],

          SizedBox(height: 12.h),

          /// PROPERTY TYPE / SORT
          Row(
            children: [
              Expanded(
                child: GetBuilder<Utilscontroller>(
                  builder: (utils) {
                    final bool known = utils.listingTypes.any(
                      (t) => t.id == _filter.type,
                    );

                    return _FilterDropdown<String>(
                      icon: Icons.home_outlined,
                      hint: "Property Type".tr,
                      value: known ? _filter.type : null,
                      items: [
                        _dropdownItem("", "All Types".tr),
                        ...utils.listingTypes.map(
                          (t) => _dropdownItem(t.id, t.title.tr),
                        ),
                      ],
                      onChanged: (value) =>
                          widget.controller.applyFilters(type: value ?? ""),
                    );
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _FilterDropdown<int>(
                  icon: Icons.swap_vert,
                  hint: "Sort".tr,
                  value: selectedSort,
                  items: [
                    for (int i = 0; i < _sortOptions.length; i++)
                      _dropdownItem(i, _sortOptions[i].label.tr),
                  ],
                  onChanged: (index) {
                    if (index == null) return;
                    widget.controller.setSort(
                      _sortOptions[index].sortBy,
                      _sortOptions[index].sortOrder,
                    );
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          /// FILTERS + SEARCH
          Row(
            children: [
              GestureDetector(
                onTap: _showFilterBottomSheet,
                child: Container(
                  height: 45.h,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: _filter.activeFilterCount > 0
                          ? AppColors.primary
                          : const Color(0xffE6E9EF),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune, color: AppColors.primary, size: 18.sp),
                      SizedBox(width: 6.w),
                      Text(
                        "Filters".tr,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_filter.activeFilterCount > 0) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${_filter.activeFilterCount}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: 45.h,
                  child: ElevatedButton(
                    onPressed: _submitSearch,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            "Search Properties".tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.title16.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<T> _dropdownItem<T>(T value, String label) {
    return DropdownMenuItem<T>(
      value: value,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> _showFilterBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return FilterBottomSheet(controller: widget.controller);
      },
    );

    if (mounted) setState(() {});
  }
}

/// Compact bordered dropdown used for Property Type and Sort.
class _FilterDropdown<T> extends StatelessWidget {
  final IconData icon;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.icon,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xffE6E9EF)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16.sp),
          SizedBox(width: 4.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                hint: Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16.sp,
                  color: Colors.grey,
                ),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Advanced filters. Edits go to a draft copy and only reach the search when
/// "Apply Filters" is tapped, so closing the sheet never leaves the badge and
/// the results out of step.
class FilterBottomSheet extends StatefulWidget {
  final PropertySearchController controller;

  const FilterBottomSheet({super.key, required this.controller});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late final PropertyFilter draft = widget.controller.filter.copy();

  /// Spinner fields report 0 for "empty" — the API rejects 0 as a min/max.
  double? _amount(int value) => value > 0 ? value.toDouble() : null;

  void _apply() {
    // Keep min <= max if they were entered the wrong way round.
    final double? minPrice = draft.minPrice;
    final double? maxPrice = draft.maxPrice;
    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      draft.minPrice = maxPrice;
      draft.maxPrice = minPrice;
    }

    final double? minArea = draft.minArea;
    final double? maxArea = draft.maxArea;
    if (minArea != null && maxArea != null && minArea > maxArea) {
      draft.minArea = maxArea;
      draft.maxArea = minArea;
    }

    widget.controller.applyDraft(draft);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Lift the sheet above the keyboard so the Apply / Reset row stays
    // reachable while a price or area field is focused.
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * .78,
          ),
          decoration: BoxDecoration(
            color: const Color(0xffF8F9FB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Divider(height: 1, color: Colors.grey.shade200),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Location".tr),
                      GetBuilder<Utilscontroller>(
                        builder: (utils) => _SheetDropdown<String>(
                          hint: "All Locations".tr,
                          value: draft.locationId,
                          items: [
                            _sheetItem<String>(null, "All Locations".tr),
                            ...utils.municipalities.map(
                              (m) => _sheetItem<String>(m.id, m.name.tr),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => draft.locationId = v),
                        ),
                      ),

                      SizedBox(height: 20.h),
                      _sectionTitle("Price Range".tr),
                      _rangeRow(
                        minHint: "Min Price".tr,
                        maxHint: "Max Price".tr,
                        min: draft.minPrice,
                        max: draft.maxPrice,
                        onMin: (v) =>
                            setState(() => draft.minPrice = _amount(v)),
                        onMax: (v) =>
                            setState(() => draft.maxPrice = _amount(v)),
                      ),

                      SizedBox(height: 16.h),
                      _sectionTitle("Bedrooms".tr),
                      SizedBox(height: 5.h),
                      _roomChips(
                        selected: draft.minBedrooms,
                        onSelected: (v) =>
                            setState(() => draft.minBedrooms = v),
                      ),

                      SizedBox(height: 16.h),
                      _sectionTitle("Bathrooms".tr),
                      SizedBox(height: 5.h),
                      _roomChips(
                        selected: draft.minBathrooms,
                        onSelected: (v) =>
                            setState(() => draft.minBathrooms = v),
                      ),

                      SizedBox(height: 16.h),
                      _sectionTitle("Furnishing".tr),
                      GetBuilder<Utilscontroller>(
                        builder: (utils) => _SheetDropdown<String>(
                          hint: "Any".tr,
                          value: draft.furnishingId.isEmpty
                              ? null
                              : draft.furnishingId,
                          items: [
                            _sheetItem<String>(null, "Any".tr),
                            ...utils.furnishingOptions.map(
                              (item) =>
                                  _sheetItem<String>(item.id, item.title.tr),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => draft.furnishingId = v ?? ""),
                        ),
                      ),

                      GetBuilder<Utilscontroller>(
                        builder: (utils) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _multiSelect(
                              "Nearby".tr,
                              utils.nearbyTags,
                              draft.nearbyTags,
                            ),
                            _multiSelect(
                              "Amenities".tr,
                              utils.amenities,
                              draft.amenities,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),
                      _sectionTitle("Area (SQM)".tr),
                      _rangeRow(
                        minHint: "Min Area".tr,
                        maxHint: "Max Area".tr,
                        min: draft.minArea,
                        max: draft.maxArea,
                        onMin: (v) =>
                            setState(() => draft.minArea = _amount(v)),
                        onMax: (v) =>
                            setState(() => draft.maxArea = _amount(v)),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 44.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Filter Properties".tr,
                      style: AppTextStyles.title16.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Refine your search results".tr,
                      style: AppTextStyles.body13.copyWith(
                        color: AppColors.hintGrey,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Icon(Icons.close_rounded, size: 20.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42.h,
              child: OutlinedButton(
                onPressed: () => setState(draft.clearAdvanced),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  "Reset".tr,
                  style: AppTextStyles.body14.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: SizedBox(
              height: 42.h,
              child: PrimaryButton(title: "Apply Filters".tr, onTap: _apply),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rangeRow({
    required String minHint,
    required String maxHint,
    required double? min,
    required double? max,
    required ValueChanged<int> onMin,
    required ValueChanged<int> onMax,
  }) {
    return Row(
      children: [
        Expanded(
          child: NumberSpinnerField(
            hint: minHint,
            value: min?.toInt() ?? 0,
            onChanged: onMin,
          ),
        ),
        SizedBox(width: 12.w),
        const Text("-", style: TextStyle(fontSize: 22)),
        SizedBox(width: 12.w),
        Expanded(
          child: NumberSpinnerField(
            hint: maxHint,
            value: max?.toInt() ?? 0,
            onChanged: onMax,
          ),
        ),
      ],
    );
  }

  /// "All" plus 1+ … 6+ — the API treats the value as a minimum.
  Widget _roomChips({
    required int? selected,
    required ValueChanged<int?> onSelected,
  }) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 12.h,
      children: [
        _NumberChip(
          title: "All".tr,
          selected: selected == null,
          onTap: () => onSelected(null),
        ),
        for (int value = 1; value <= 6; value++)
          _NumberChip(
            title: "$value+",
            selected: selected == value,
            onTap: () => onSelected(value),
          ),
      ],
    );
  }

  /// Titled chip group; hidden until the options have loaded.
  Widget _multiSelect(
    String title,
    List<OptionItem> options,
    List<String> selectedIds,
  ) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: options.map((item) {
              final bool selected = selectedIds.contains(item.id);

              return CustomFilterChip(
                title: item.title,
                selected: selected,
                onTap: () => setState(() {
                  selected
                      ? selectedIds.remove(item.id)
                      : selectedIds.add(item.id);
                }),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

DropdownMenuItem<T> _sheetItem<T>(T? value, String label) {
  return DropdownMenuItem<T>(
    value: value,
    child: Text(label, style: TextStyle(fontSize: 13.sp)),
  );
}

/// Outlined dropdown used inside the filter sheet. Re-created whenever the
/// value changes from outside (e.g. Reset) so it never shows a stale choice.
class _SheetDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _SheetDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: color),
    );

    return SizedBox(
      height: 42.h,
      child: DropdownButtonFormField<T>(
        key: ValueKey(value),
        isDense: true,
        isExpanded: true,
        initialValue: value,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 10.h,
          ),
          border: border(Colors.grey.shade300),
          enabledBorder: border(Colors.grey.shade300),
          focusedBorder: border(AppColors.primary),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

//======================================================
// SECTION TITLE
//======================================================

Widget _sectionTitle(String title) {
  return Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Text(
      title,
      style: AppTextStyles.title14.copyWith(fontWeight: FontWeight.w500),
    ),
  );
}

class CustomFilterChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const CustomFilterChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: .08)
              : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xffD8DCE5),
            width: 1.4,
          ),
        ),
        child: Text(
          title.tr,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.primary : const Color(0xff555555),
          ),
        ),
      ),
    );
  }
}

class _NumberChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _NumberChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 45.w,
        height: 35.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: .08)
              : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xffD8DCE5),
            width: 1.w,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.primary : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class NumberSpinnerField extends StatefulWidget {
  final String hint;
  final int value;
  final ValueChanged<int> onChanged;

  const NumberSpinnerField({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  State<NumberSpinnerField> createState() => _NumberSpinnerFieldState();
}

class _NumberSpinnerFieldState extends State<NumberSpinnerField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: widget.value == 0 ? "" : widget.value.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant NumberSpinnerField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      controller.text = widget.value == 0 ? "" : widget.value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10.r),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: widget.hint,

                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              onChanged: (v) {
                widget.onChanged(int.tryParse(v) ?? 0);
              },
            ),
          ),

          Container(
            width: 50,

            child: Column(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final value = (int.tryParse(controller.text) ?? 0) + 1;
                      controller.text = value.toString();
                      widget.onChanged(value);
                    },
                    child: Icon(Icons.keyboard_arrow_up, size: 16.sp),
                  ),
                ),

                Expanded(
                  child: InkWell(
                    onTap: () {
                      int value = (int.tryParse(controller.text) ?? 0) - 1;

                      if (value < 0) value = 0;

                      controller.text = value.toString();
                      widget.onChanged(value);
                    },
                    child: Icon(Icons.keyboard_arrow_down, size: 16.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xffE6E9EF)),
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
                  Divider(height: 1, color: const Color(0xffE6E9EF)),
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
                            style: AppTextStyles.body14.copyWith(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff32354A),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          isPlace ? "Place".tr : "Property".tr,
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xffA5ADBA),
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
