import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/compare_bottomsheet.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';



class CompareCard extends StatelessWidget {
  final Property property;

  const CompareCard({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15.r,
            backgroundColor: AppColors.primary.withOpacity(.1),
            child: Icon(
              Icons.compare_arrows_rounded,
              color: AppColors.primary,
              size: 15.sp,
            ),
          ),

          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Compare Properties".tr,
                  style: AppTextStyles.title14.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Compare this property with similar listings".tr,
                  style: AppTextStyles.body12.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CompareBottomSheet(
                  currentProperty: property,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              "Compare".tr,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}