import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/core/constants/app_colors.dart';
import 'package:villas_qatar/modules/home/service/UtilsController.dart';
import 'package:villas_qatar/modules/propertylist/service/myproperties_listcontroller.dart';

void showFilterBottomSheet(BuildContext context) {
  final controller = Get.find<MyPropertyController>();

  String? purpose = controller.purpose;
  String? propertyType = controller.type;
  String? furnishing = controller.furnishingStatus;

  final minPriceCtrl = TextEditingController(
    text: controller.minPrice?.toString() ?? "",
  );

  final maxPriceCtrl = TextEditingController(
    text: controller.maxPrice?.toString() ?? "",
  );

  final minBedroomCtrl = TextEditingController(
    text: controller.minBedrooms?.toString() ?? "",
  );

  final maxBedroomCtrl = TextEditingController(
    text: controller.maxBedrooms?.toString() ?? "",
  );

  final minBathCtrl = TextEditingController(
    text: controller.minBathrooms?.toString() ?? "",
  );

  final maxBathCtrl = TextEditingController(
    text: controller.maxBathrooms?.toString() ?? "",
  );

  final minAreaCtrl = TextEditingController(
    text: controller.minArea?.toString() ?? "",
  );

  final maxAreaCtrl = TextEditingController(
    text: controller.maxArea?.toString() ?? "",
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .50,
              ),

              decoration: BoxDecoration(
                color: const Color(0xffF8F9FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),

              child: Column(
                children: [
                  ///==========================================
                  /// DRAG HANDLE
                  ///==========================================
                  Padding(
                    padding: EdgeInsets.only(top: 14.h),
                    child: Center(
                      child: Container(
                        width: 44.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                  ),

                  ///==========================================
                  /// HEADER
                  ///==========================================
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 5.h),
                    child: Row(
                      children: [
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(.08),
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
                                style: AppTextStyles.title14.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              SizedBox(height: 3.h),

                              Text(
                                "Refine your search results".tr,
                                style: AppTextStyles.body12.copyWith(
                                  color: AppColors.hintGrey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        InkWell(
                          borderRadius: BorderRadius.circular(30.r),
                          onTap: () => Get.back(),
                          child: Container(
                            width: 35.w,
                            height: 35.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: AppColors.fieldBorder),
                            ),
                            child: Icon(Icons.close_rounded, size: 15.sp),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: AppColors.fieldBorder),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 5.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.h),

                          sectionTitle("Furnishing".tr),

                          card(
                            // Furnishing options come from the same
                            // /api/listings/options list the Search screen
                            // uses — no hardcoded status names here.
                            child: GetBuilder<Utilscontroller>(
                              init: Get.isRegistered<Utilscontroller>()
                                  ? Get.find<Utilscontroller>()
                                  : Get.put(Utilscontroller(), permanent: true),
                              builder: (utils) => Wrap(
                                spacing: 10.w,
                                runSpacing: 10.h,
                                children: utils.furnishingOptions.map((option) {
                                  return chip(
                                    title: option.title.tr,
                                    selected: furnishing == option.title,
                                    onTap: () {
                                      setState(() {
                                        furnishing = furnishing == option.title
                                            ? null
                                            : option.title;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          ///=========================================================
                          /// NEGOTIABLE
                          ///=========================================================

                          ///=========================================================
                          /// SORT BY
                          ///=========================================================
                          // sectionTitle("Sort By"),

                          // card(
                          //   child: Wrap(
                          //     spacing: 10.w,
                          //     runSpacing: 10.h,
                          //     children: [
                          //       chip(
                          //         title: "Newest",
                          //         selected: sortBy == "createdAt",
                          //         onTap: () {
                          //           setState(() {
                          //             sortBy = "createdAt";
                          //           });
                          //         },
                          //       ),

                          //       chip(
                          //         title: "Price",
                          //         selected: sortBy == "price",
                          //         onTap: () {
                          //           setState(() {
                          //             sortBy = "price";
                          //           });
                          //         },
                          //       ),

                          //       chip(
                          //         title: "Area",
                          //         selected: sortBy == "area",
                          //         onTap: () {
                          //           setState(() {
                          //             sortBy = "area";
                          //           });
                          //         },
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          ///=========================================================
                          /// PRICE RANGE
                          ///=========================================================
                          sectionTitle("Price Range".tr),

                          card(
                            child: Row(
                              children: [
                                field(
                                  "Min Price".tr,
                                  Icons.currency_exchange,
                                  minPriceCtrl,
                                ),

                                SizedBox(width: 12.w),

                                field(
                                  "Max Price".tr,
                                  Icons.currency_exchange,
                                  maxPriceCtrl,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 15.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: AppColors.fieldBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50.h,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: () {
                                purpose = null;
                                propertyType = null;
                                furnishing = null;

                                minPriceCtrl.clear();
                                maxPriceCtrl.clear();

                                minBedroomCtrl.clear();
                                maxBedroomCtrl.clear();

                                minBathCtrl.clear();
                                maxBathCtrl.clear();

                                minAreaCtrl.clear();
                                maxAreaCtrl.clear();

                                controller.applyFilters();

                                Get.back();
                              },
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
                            height: 50.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: () {
                                controller.applyFilters(
                                  purpose: purpose,
                                  type: propertyType,

                                  minPrice: double.tryParse(minPriceCtrl.text),

                                  maxPrice: double.tryParse(maxPriceCtrl.text),

                                  minBedrooms: int.tryParse(
                                    minBedroomCtrl.text,
                                  ),

                                  maxBedrooms: int.tryParse(
                                    maxBedroomCtrl.text,
                                  ),

                                  minBathrooms: int.tryParse(minBathCtrl.text),

                                  maxBathrooms: int.tryParse(maxBathCtrl.text),

                                  minArea: double.tryParse(minAreaCtrl.text),

                                  maxArea: double.tryParse(maxAreaCtrl.text),

                                  furnishingStatus: furnishing,
                                );

                                Get.back();
                              },
                              child: Text(
                                "Apply Filters".tr,
                                style: AppTextStyles.body14.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget field(String hint, IconData icon, TextEditingController controller) {
  return Expanded(
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: AppTextStyles.body13.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,

        hintStyle: AppTextStyles.body12.copyWith(color: AppColors.hintGrey),

        prefixIcon: Icon(icon, size: 18.sp, color: AppColors.primary),

        filled: true,
        fillColor: Colors.white,

        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.fieldBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    ),
  );
}

Widget sectionTitle(String title) {
  return Padding(
    padding: EdgeInsets.only(bottom: 10.h, top: 2.h),
    child: Text(
      title,
      style: AppTextStyles.title14.copyWith(fontWeight: FontWeight.w500),
    ),
  );
}

Widget card({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 5.w),

    child: child,
  );
}

Widget chip({
  required String title,
  required bool selected,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),

        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 11.h),

        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(.08) : Colors.white,

          borderRadius: BorderRadius.circular(12.r),

          border: Border.all(
            color: selected ? AppColors.primary : AppColors.fieldBorder,
          ),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.grey.shade400,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, size: 10.sp, color: Colors.white)
                  : null,
            ),

            SizedBox(width: 10.w),

            Text(
              title,
              style: AppTextStyles.body13.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
