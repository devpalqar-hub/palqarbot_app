import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/utils/guest_limter.dart';
import 'package:villas_qatar/modules/home/model/ListingOptions.dart';
import 'package:villas_qatar/modules/home/service/UtilsController.dart';
import 'package:villas_qatar/modules/pricestimator/service/ai_price_estimator_controller.dart';
import 'package:villas_qatar/modules/propertylist/model/listing_options_model.dart';
import '../../propertylist/service/listproperty_controller.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class PriceEstimatorScreen extends StatefulWidget {
  const PriceEstimatorScreen({super.key});

  @override
  State<PriceEstimatorScreen> createState() => _PriceEstimatorScreenState();
}

class _PriceEstimatorScreenState extends State<PriceEstimatorScreen> {
  String? _selectedTypeId;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _highlightsController = TextEditingController();

  // ============================================================
  // SELECTED QUICK DETAILS
  // ============================================================
  int? _selectedBhk;
  int? _selectedBathrooms;
  FurnishingOption? _selectedFurnishing;
  int? _selectedFloor;
  int? _selectedTotalFloors;
  bool? _parkingAvailable;
  String? _selectedPropertyAge;
  final Set<String> _selectedAmenityIds = {};

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ListPropertyController>()) {
      Get.put(ListPropertyController());
    }
    if (!Get.isRegistered<AiPriceEstimatorController>()) {
      Get.put(AiPriceEstimatorController());
    }

    /// Property types come from /api/listings/options, which Homecontroller
    /// already loads through Utilscontroller. Reuse it, and only fetch here
    /// if the estimator is opened before that data has arrived.
    final Utilscontroller utils = Get.isRegistered<Utilscontroller>()
        ? Get.find<Utilscontroller>()
        : Get.put(Utilscontroller(), permanent: true);

    if (utils.listingTypes.isEmpty && !utils.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        utils.fetchPropertyType();
      });
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _areaController.dispose();
    _highlightsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Slightly off-white for depth
      appBar: _buildAppBar(context),
      bottomNavigationBar: SafeArea(child: _buildBottomBar()),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          children: [
            _sectionCard(
              title: 'Basic Details'.tr,
              child: Column(
                children: [
                  _buildTypeGrid(),
                  SizedBox(height: 12.h),
                  _inputField(
                    controller: _locationController,
                    hint: 'City, locality or area'.tr,
                    icon: Icons.location_on_outlined,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 10.h),
                  _inputField(
                    controller: _areaController,
                    hint: 'Total Area (sqm)'.tr,
                    icon: Icons.square_foot_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            _sectionCard(
              title: 'Specifications'.tr,
              optional: true,
              trailing: _hasSpecifications
                  ? InkWell(
                      onTap: _clearSpecifications,
                      borderRadius: BorderRadius.circular(6.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        child: Text(
                          'Clear'.tr,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  : null,
              child: _buildDetailGrid(),
            ),
            SizedBox(height: 12.h),
            _sectionCard(
              title: 'Extras & Highlights'.tr,
              child: Column(
                children: [
                  _buildAmenities(),
                  SizedBox(height: 10.h),
                  _buildHighlightsField(),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            _buildFooterNote(),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Text(
            'AI Price Estimator'.tr,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
    );
  }

  // ============================================================
  // STICKY BOTTOM BAR
  // ============================================================
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GetBuilder<AiPriceEstimatorController>(
        builder: (controller) {
          final bool loading = controller.isLoading;
          return SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: loading ? null : () => _estimatePrice(controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: loading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Calculate Estimate'.tr,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
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

  // ============================================================
  // SHARED BUILDING BLOCKS
  // ============================================================
  Widget _sectionCard({
    required String title,
    required Widget child,
    bool optional = false,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (optional) ...[
                SizedBox(width: 6.w),
                Text(
                  '(Optional)'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.textHint),
        prefixIcon: Icon(icon, size: 18.sp, color: AppColors.textSecondary),
        filled: true,
        fillColor: const Color(0xFFFAFAFB),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  // ============================================================
  // PROPERTY TYPE (LOADED FROM /api/listings/options)
  // ============================================================

  /// The chosen listing type, falling back to the first one the API returned.
  OptionItem? _resolveSelectedType(List<OptionItem> types) {
    if (types.isEmpty) return null;

    return types.firstWhereOrNull((t) => t.id == _selectedTypeId) ??
        types.first;
  }

  IconData _typeIcon(String title) {
    final String value = title.toLowerCase();

    if (value.contains('villa') || value.contains('house')) {
      return Icons.villa_outlined;
    }
    if (value.contains('apartment') || value.contains('flat')) {
      return Icons.apartment_outlined;
    }
    if (value.contains('plot') || value.contains('land')) {
      return Icons.crop_square;
    }
    if (value.contains('office')) return Icons.business_center_outlined;
    if (value.contains('shop') || value.contains('retail')) {
      return Icons.storefront_outlined;
    }
    if (value.contains('commercial') || value.contains('building')) {
      return Icons.store_mall_directory_outlined;
    }
    if (value.contains('warehouse') || value.contains('industrial')) {
      return Icons.warehouse_outlined;
    }
    if (value.contains('farm')) return Icons.agriculture_outlined;

    return Icons.home_work_outlined;
  }

  Widget _buildTypeGrid() {
    return GetBuilder<Utilscontroller>(
      builder: (utils) {
        final List<OptionItem> types = utils.listingTypes;

        if (types.isEmpty) {
          if (utils.isLoading) {
            return SizedBox(
              height: 40.h,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          return InkWell(
            onTap: utils.fetchPropertyType,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              height: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFB),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Unable to load property types. Tap to retry.'.tr,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final OptionItem? selectedType = _resolveSelectedType(types);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(types.length, (i) {
              final OptionItem type = types[i];
              final bool selected = type.id == selectedType?.id;

              return Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 6.w),
                child: InkWell(
                  onTap: () => setState(() => _selectedTypeId = type.id),
                  borderRadius: BorderRadius.circular(8.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 40.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withOpacity(0.1)
                          : const Color(0xFFFAFAFB),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon(
                        //   _typeIcon(type.title),
                        //   size: 16.sp,
                        //   color: selected
                        //       ? AppColors.primary
                        //       : AppColors.textSecondary,
                        // ),
                        SizedBox(width: 6.w),
                        Text(
                          type.title,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // ============================================================
  // PROPERTY DETAILS (COMPACT LIST TILE)
  // ============================================================
  Widget _detailCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    final bool isPlaceholder = value == "Select".tr || value == "Any".tr;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: fullWidth ? double.infinity : null,
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFB),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16.sp, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isPlaceholder
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.unfold_more_rounded,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailGrid() {
    return GetBuilder<ListPropertyController>(
      builder: (listingController) {
        if (listingController.isLoading &&
            listingController.furnishingOptions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _detailCard(
                    icon: Icons.bed_outlined,
                    title: "BHK".tr,
                    value: _selectedBhk?.toString() ?? "Any".tr,
                    onTap: () => _showOptionSheet<int>(
                      title: "Select BHK".tr,
                      options: const [1, 2, 3, 4, 5, 6],
                      labelBuilder: (v) => "$v BHK".tr,
                      selectedValue: _selectedBhk,
                      onSelected: (v) => setState(() => _selectedBhk = v),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _detailCard(
                    icon: Icons.bathtub_outlined,
                    title: "Bathrooms".tr,
                    value: _selectedBathrooms?.toString() ?? "Any".tr,
                    onTap: () => _showOptionSheet<int>(
                      title: "Bathrooms".tr,
                      options: const [1, 2, 3, 4, 5, 6],
                      labelBuilder: (v) => "$v".tr,
                      selectedValue: _selectedBathrooms,
                      onSelected: (v) => setState(() => _selectedBathrooms = v),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _detailCard(
                    icon: Icons.chair_outlined,
                    title: "Furnishing".tr,
                    value: _selectedFurnishing?.title ?? "Any".tr,
                    onTap: () => _showOptionSheet<FurnishingOption>(
                      title: "Furnishing".tr,
                      options: listingController.furnishingOptions,
                      labelBuilder: (i) => i.title,
                      selectedValue: _selectedFurnishing,
                      onSelected: (i) =>
                          setState(() => _selectedFurnishing = i),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _detailCard(
                    icon: Icons.directions_car_outlined,
                    title: "Parking".tr,
                    value: _parkingAvailable == null
                        ? "Any".tr
                        : (_parkingAvailable! ? "Yes".tr : "No".tr),
                    onTap: () => _showOptionSheet<bool>(
                      title: "Parking".tr,
                      options: const [true, false],
                      labelBuilder: (v) =>
                          v ? "Available".tr : "Not Available".tr,
                      selectedValue: _parkingAvailable,
                      onSelected: (v) => setState(() => _parkingAvailable = v),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _detailCard(
                    icon: Icons.layers_outlined,
                    title: "Floor".tr,
                    value: _selectedFloor?.toString() ?? "Any".tr,
                    onTap: () => _showOptionSheet<int>(
                      title: "Floor".tr,
                      options: List.generate(50, (i) => i),
                      labelBuilder: (v) => v == 0 ? "Ground".tr : "$v",
                      selectedValue: _selectedFloor,
                      onSelected: (v) => setState(() {
                        _selectedFloor = v;
                        if (_selectedTotalFloors != null &&
                            v > _selectedTotalFloors!)
                          _selectedTotalFloors = v;
                      }),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _detailCard(
                    icon: Icons.apartment_outlined,
                    title: "Total Floors".tr,
                    value: _selectedTotalFloors?.toString() ?? "Any".tr,
                    onTap: () => _showOptionSheet<int>(
                      title: "Total Floors".tr,
                      options: List.generate(50, (i) => i + 1),
                      labelBuilder: (v) => "$v",
                      selectedValue: _selectedTotalFloors,
                      onSelected: (v) => setState(() {
                        _selectedTotalFloors = v;
                        if (_selectedFloor != null && _selectedFloor! > v)
                          _selectedFloor = v;
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // AMENITIES & HIGHLIGHTS
  // ============================================================
  Widget _buildAmenities() {
    return GetBuilder<ListPropertyController>(
      builder: (controller) {
        final selectedItems = controller.amenities
            .where((item) => _selectedAmenityIds.contains(item.id))
            .toList();
        return InkWell(
          onTap: () => controller.amenities.isEmpty
              ? AppToast.show(msg: "Amenities not available.".tr)
              : _showAmenitiesSheet(controller.amenities),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: double.infinity,

            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFB),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.pool_outlined,
                  size: 18.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: selectedItems.isNotEmpty
                      ? Text(
                          selectedItems.map((e) => e.title).join(", "),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : Text(
                          "Select amenities".tr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textHint,
                          ),
                        ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHighlightsField() {
    return TextField(
      controller: _highlightsController,
      maxLength: 100,
      maxLines: 2,
      style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Any extra highlights? (e.g. Sea view)'.tr,
        hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.textHint),
        counterStyle: TextStyle(
          fontSize: 10.sp,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFB),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  // ============================================================
  // LOGIC & HELPERS
  // (Maintained exactly as original but kept compact)
  // ============================================================
  Future<void> _estimatePrice(AiPriceEstimatorController controller) async {
    final String areaName = _locationController.text.trim();
    final double? areaSqft = double.tryParse(_areaController.text.trim());
    final listingController = Get.find<ListPropertyController>();
    final selectedAmenityTitles = listingController.amenities
        .where((item) => _selectedAmenityIds.contains(item.id))
        .map((item) => item.title)
        .toList();

    List<String> highlightParts = [];
    if (selectedAmenityTitles.isNotEmpty)
      highlightParts.add(selectedAmenityTitles.join(', '));
    if (_highlightsController.text.trim().isNotEmpty)
      highlightParts.add(_highlightsController.text.trim());

    final OptionItem? selectedType = _resolveSelectedType(
      Get.find<Utilscontroller>().listingTypes,
    );

    if (selectedType == null) return _toast("Please select property type.".tr);
    if (areaName.isEmpty) return _toast("Please enter location.".tr);
    if (areaSqft == null || areaSqft <= 0)
      return _toast("Please enter valid area.".tr);

    final bool allowed = await GuestLimiter.canUseEstimator();
    if (!allowed) {
      GuestLimiter.showLimitReachedDialog();
      return;
    }

    final bool success = await controller.estimatePrice(
      areaName: areaName,
      areaSqft: areaSqft,
      propertyType: selectedType.title,
      bhk: _selectedBhk,
      bathrooms: _selectedBathrooms,
      furnishingStatus: _selectedFurnishing?.title,
      floorAbove: _selectedFloor,
      totalFloors: _selectedTotalFloors,
      parkingAvailable: _parkingAvailable,
      highlights: highlightParts.join(', '),
    );

    if (mounted && success)
      _showEstimateResult(controller);
    else if (mounted)
      _toast(
        controller.error.isNotEmpty
            ? controller.error
            : "Unable to estimate price.".tr,
      );
  }

  bool get _hasSpecifications =>
      _selectedBhk != null ||
      _selectedBathrooms != null ||
      _selectedFurnishing != null ||
      _selectedFloor != null ||
      _selectedTotalFloors != null ||
      _parkingAvailable != null;

  void _clearSpecifications() {
    setState(() {
      _selectedBhk = null;
      _selectedBathrooms = null;
      _selectedFurnishing = null;
      _selectedFloor = null;
      _selectedTotalFloors = null;
      _parkingAvailable = null;
    });
  }

  void _toast(String msg) =>
      AppToast.show(msg: msg.tr, gravity: ToastGravity.BOTTOM);

  void _showEstimateResult(AiPriceEstimatorController controller) {
    final result = controller.estimation;
    if (result == null) return;
    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "AI Estimated Value".tr,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _formatQar(result.averagePrice),
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFB),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text("Minimum".tr, style: TextStyle(fontSize: 11.sp)),
                          SizedBox(height: 4.h),
                          Text(
                            _formatQar(result.minPrice),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 30.h, color: AppColors.border),
                    Expanded(
                      child: Column(
                        children: [
                          Text("Maximum".tr, style: TextStyle(fontSize: 11.sp)),
                          SizedBox(height: 4.h),
                          Text(
                            _formatQar(result.maxPrice),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              _buildEstimateDisclaimer(),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: Get.back,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    "Done".tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _formatQar(double value) =>
      "${"QAR".tr} ${value.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}";

  /// Warning shown with every estimate: the figure is indicative only.
  Widget _buildEstimateDisclaimer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withOpacity(.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18.sp,
            color: AppColors.warning,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is an AI-estimated price'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'It is only an indicative figure and not a valuation. Please consult a qualified property expert or agent to confirm the actual price before making any decision.'
                      .tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shield_outlined,
          size: 14.sp,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            'AI estimates are indicative. Consult an expert to confirm.'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Helper inside State to avoid context issues, shortened for brevity
  Future<void> _showAmenitiesSheet(List<ListingOptionItem> amenities) async {
    final Set<String> temp = {..._selectedAmenityIds};
    await Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setStateSheet) => SafeArea(
          child: Container(
            constraints: BoxConstraints(maxHeight: Get.height * .7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Amenities".tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: Get.back,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    itemCount: amenities.length,
                    itemBuilder: (c, i) {
                      final am = amenities[i];
                      final bool sel = temp.contains(am.id);
                      return CheckboxListTile(
                        value: sel,
                        title: Text(
                          am.title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        activeColor: AppColors.primary,
                        dense: true,
                        onChanged: (v) => setStateSheet(
                          () =>
                              v == true ? temp.add(am.id) : temp.remove(am.id),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedAmenityIds.clear();
                          _selectedAmenityIds.addAll(temp);
                        });
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        "Apply".tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

Future<void> _showOptionSheet<T>({
  required String title,
  required List<T> options,
  required String Function(T value) labelBuilder,
  required T? selectedValue,
  required ValueChanged<T> onSelected,
}) async {
  await Get.bottomSheet(
    SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.height * .5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: Get.back,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (c, i) {
                  final T val = options[i];
                  final bool sel = val == selectedValue;
                  return ListTile(
                    dense: true,
                    title: Text(
                      labelBuilder(val),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: sel ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: sel
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      onSelected(val);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
