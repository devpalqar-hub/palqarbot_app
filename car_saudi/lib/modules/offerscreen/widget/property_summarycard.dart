import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';

class PropertySummaryCard extends StatelessWidget {
  final Property property;

  const PropertySummaryCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final image = property.photos.isNotEmpty ? property.photos.first.url : "";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xffECECEC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Property Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    width: 110.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      "assets/villa.jpg",
                      width: 110.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    "assets/villa.jpg",
                    width: 110.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                  ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Property Name
                Text(
                  property.propertyName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body13.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: 6.h),

                /// Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 15.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        "${property.areaName}, ${property.municipality}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body13.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                /// Price
                Text(
                  "${"QAR".tr} ${NumberFormat('#,##0').format(property.price)}",
                  style: AppTextStyles.title16.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 10.h),

                Row(
                  children: [
                    _feature(Icons.bed_outlined, property.bedrooms.toString()),

                    SizedBox(width: 14.w),

                    _feature(
                      Icons.bathtub_outlined,
                      property.bathrooms.toString(),
                    ),

                    SizedBox(width: 14.w),

                    _feature(
                      Icons.square_foot_outlined,
                      "${property.area.toStringAsFixed(0)} ${"sqm".tr}",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 15.sp, color: Colors.grey.shade600),
        SizedBox(width: 4.w),
        Text(
          value,
          style: AppTextStyles.body13.copyWith(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
