import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/modules/home/service/UtilsController.dart';
import 'package:villas_qatar/modules/searchscreen/service/searchlist_screen.dart';

class PropertyCategorySection extends StatelessWidget {
  PropertyCategorySection({super.key, required this.controller});

  final PropertySearchController controller;

  @override
  @override
  Widget build(BuildContext context) {
    return GetBuilder<Utilscontroller>(
      builder: (utils) {
        return GetBuilder<PropertySearchController>(
          builder: (_) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Property Categories".tr,
                  style: AppTextStyles.title14.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 14.h),

                SizedBox(
                  height: 70.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: utils.listingTypes.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (_, index) {
                      final item = utils.listingTypes[index];

                      final bool selected = controller.filter.type == item.id;

                      return InkWell(
                        borderRadius: BorderRadius.circular(10.r),
                        onTap: () {
                          controller.applyFilters(type: item.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 65.w,
                          height: 70.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : const Color(0xffE6E9EF),
                              width: selected ? 1.2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                item.image ?? "",
                                width: 24.w,
                                height: 22.w,
                                fit: BoxFit.contain,

                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.home_work_outlined, size: 20.sp),
                              ),

                              SizedBox(height: 6.h),

                              Text(
                                item.title.tr,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body12.copyWith(
                                  fontSize: 9.sp,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String title;
  final String? image;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.title,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 62.w,
              height: 62.w,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x14000000),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: image != null && image!.isNotEmpty
                    ? Image.network(
                        image!,
                        width: 30.w,
                        height: 30.w,
                        fit: BoxFit.contain,
                        color: selected ? Colors.white : AppColors.primary,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.home_work_outlined,
                          size: 28.sp,
                          color: selected ? Colors.white : AppColors.primary,
                        ),
                      )
                    : Icon(
                        Icons.home_work_outlined,
                        size: 28.sp,
                        color: selected ? Colors.white : AppColors.primary,
                      ),
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              title.tr,
              style: AppTextStyles.body12.copyWith(
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                color: selected ? AppColors.primary : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
