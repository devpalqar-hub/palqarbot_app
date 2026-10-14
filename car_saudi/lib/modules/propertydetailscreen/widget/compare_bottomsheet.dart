import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';

import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/searchscreen/service/searchlist_screen.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
enum CompareStep { selection, comparison }

class CompareBottomSheet extends StatefulWidget {
  final Property currentProperty;

  const CompareBottomSheet({super.key, required this.currentProperty});

  @override
  State<CompareBottomSheet> createState() => _CompareBottomSheetState();
}

class _CompareBottomSheetState extends State<CompareBottomSheet> {
  late final PropertySearchController controller;

  final List<Property> selectedProperties = [];

  CompareStep step = CompareStep.selection;

  @override
  void initState() {
    super.initState();

    controller = Get.find<PropertySearchController>();

    if (controller.properties.isEmpty) {
      controller.fetchProperties();
    }
  }

  bool isSelected(Property property) {
    return selectedProperties.any((e) => e.id == property.id);
  }

  void toggle(Property property) {
    if (isSelected(property)) {
      setState(() {
        selectedProperties.removeWhere((e) => e.id == property.id);
      });
      return;
    }

    if (selectedProperties.length >= 2) {
      AppToast.show(
        msg: "You can compare only two properties.".tr,
      );
      return;
    }

    setState(() {
      selectedProperties.add(property);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .70,
      maxChildSize: .80,
      minChildSize: .65,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: step == CompareStep.selection
              ? _selectionView(scrollController)
              : ComparisonView(
                  currentProperty: widget.currentProperty,
                  compareProperties: selectedProperties,
                  onBack: () {
                    setState(() {
                      step = CompareStep.selection;
                    });
                  },
                ),
        );
      },
    );
  }

  Widget _selectionView(ScrollController scrollController) {
    return GetBuilder<PropertySearchController>(
      builder: (controller) {
        final properties = controller.properties
            .where((e) => e.id != widget.currentProperty.id)
            .toList();

        return Column(
          children: [
            SizedBox(height: 8.h),

            Container(
              width: 60.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(50),
              ),
            ),

            SizedBox(height: 8.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Compare Properties".tr,
                      style: AppTextStyles.title18.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select up to 2 properties".tr,
                  style: AppTextStyles.body13.copyWith(color: Colors.grey),
                ),
              ),
            ),

            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                height: 42.h,
                child: TextField(
                  controller: controller.searchTextController,
                  onChanged: controller.searchProperty,
                  style: AppTextStyles.body13,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: "Search Property".tr,
                    hintStyle: AppTextStyles.body13.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20.sp,
                      color: Colors.grey.shade600,
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 40.w,
                      minHeight: 40.h,
                    ),
                    filled: true,
                    fillColor: const Color(0xffF8F8F8),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 0,
                    ),
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
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 15.h),

            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : properties.isEmpty
                  ? Center(child: Text("No Properties Found".tr))
                  : ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: properties.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (_, index) {
                        final property = properties[index];

                        return ComparePropertyTile(
                          property: property,
                          selected: isSelected(property),
                          onTap: () => toggle(property),
                        );
                      },
                    ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: selectedProperties.isEmpty
                        ? null
                        : () {
                            setState(() {
                              step = CompareStep.comparison;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      "${"Compare".tr} (${selectedProperties.length})",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


class ComparePropertyTile extends StatelessWidget {
  final Property property;
  final bool selected;
  final VoidCallback onTap;

  const ComparePropertyTile({
    super.key,
    required this.property,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = property.sortedPhotos.isNotEmpty
        ? property.sortedPhotos.first.url
        : "";

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8.h,
              horizontal: 2.w,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          width: 56.w,
                          height: 56.w,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 56.w,
                          height: 56.w,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.home_work_outlined,
                            size: 20.sp,
                            color: Colors.grey,
                          ),
                        ),
                ),

                SizedBox(width: 10.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.propertyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body13.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 2.h),

                      Text(
                        property.areaName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body12.copyWith(
                          fontSize: 9.sp,
                          color: Colors.grey,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        "${"QAR".tr} ${property.price.toStringAsFixed(0)}",
                        style: AppTextStyles.body12.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      Row(
                        children: [
                          Icon(
                            Icons.bed_outlined,
                            size: 12.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            "${property.bedrooms}",
                            style: TextStyle(fontSize: 9.sp),
                          ),

                          SizedBox(width: 8.w),

                          Icon(
                            Icons.bathtub_outlined,
                            size: 12.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            "${property.bathrooms}",
                            style: TextStyle(fontSize: 9.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : Colors.grey.shade400,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check,
                          size: 10.sp,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String value;

  const _Feature(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.primary),
        SizedBox(width: 4.w),
        Text(
          value,
          style: AppTextStyles.body13.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class ComparisonView extends StatelessWidget {
  final Property currentProperty;
  final List<Property> compareProperties;
  final VoidCallback onBack;

  const ComparisonView({
    super.key,
    required this.currentProperty,
    required this.compareProperties,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final properties = [currentProperty, ...compareProperties];

    return Column(
      children: [
        SizedBox(height: 10.h),

        Container(
          width: 45.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(30),
          ),
        ),

        Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Property Comparison".tr,
                  style: AppTextStyles.title14.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(onPressed: onBack, icon: const Icon(Icons.close)),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  /// HEADER
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titleColumn(),
                      ...properties.map((e) => _propertyColumn(e)),
                    ],
                  ),

                  Divider(),

                  _row(
                    "Price".tr,
                    properties,
                    (e) => "${"QAR".tr} ${e.price.toStringAsFixed(0)}",
                  ),

                  _row("Purpose".tr, properties, (e) => e.purpose.tr),

                  _row("Property Type".tr, properties, (e) => e.type.title.tr),

                  _row(
                    "Location".tr,
                    properties,
                    (e) => "${e.areaName}, ${e.municipality.name}",
                  ),

                  _row("Bedrooms".tr, properties, (e) => "${e.bedrooms}"),

                  _row("Bathrooms".tr, properties, (e) => "${e.bathrooms}"),

                  _row("Area".tr, properties, (e) => "${e.area} ${"sqft".tr}"),

                  _row("Furnishing".tr, properties, (e) => e.furnishing.title.tr),

                  _row(
                    "Price Negotiable".tr,
                    properties,
                    (e) => e.priceNegotiable ? "Yes".tr : "No".tr,
                  ),

                  _row(
                    "Contact Verified".tr,
                    properties,
                    (e) => e.contactVerified ? "Yes".tr : "No".tr,
                  ),

                  _row("Status".tr, properties, (e) => e.status),

                  _row(
                    "Amenities".tr,
                    properties,
                    (e) => e.amenities.isEmpty
                        ? "-"
                        : e.amenities.map((a) => a.title).join(", "),
                  ),

                  _row(
                    "Nearby Places".tr,
                    properties,
                    (e) => e.nearbyTags.isEmpty
                        ? "-"
                        : e.nearbyTags.map((t) => t.title).join(", "),
                  ),

                  _row(
                    "Other Features".tr,
                    properties,
                    (e) => e.otherFeatures.isEmpty ? "-" : e.otherFeatures,
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),

        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: SizedBox(
              width: double.infinity,
              height: 42.h,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  "Change Selection".tr,
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

Widget _titleColumn() {
  return SizedBox(width: 110.w);
}


  Widget _propertyColumn(Property property) {
    final image = property.sortedPhotos.isNotEmpty
        ? property.sortedPhotos.first.url
        : "";

    return Container(
    width: 220.w,
      padding: EdgeInsets.only(left: 12.w),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: image.isEmpty
                ? Container(height: 100.h, color: Colors.grey.shade200)
                : Image.network(
                    image,
                    height: 100.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),

          SizedBox(height: 10.h),

          Text(
            property.propertyName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body12.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

Widget _row(
  String title,
  List<Property> properties,
  String Function(Property) value,
) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
    ),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 110.w,
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 14.h,
            ),
            color: const Color(0xffFAFAFA),
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: AppTextStyles.body13.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          ...properties.map(
            (property) => Container(
              width: 220.w,
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: Text(
                value(property),
                style: AppTextStyles.body13,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}}