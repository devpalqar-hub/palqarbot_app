import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';

class OverviewCard extends StatefulWidget {
  final Property property;

  const OverviewCard({
    super.key,
    required this.property,
  });

  @override
  State<OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends State<OverviewCard> {
  bool expanded = false;

  static const Color primary = Color(0xFFA60F46);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16.w,
        15.h,
        16.w,
        15.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE7E7E7),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overview".tr,
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.1,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),

          SizedBox(height: 9.h),

          Text(
            widget.property.description,
            maxLines: expanded ? null : 3,
            overflow:
                expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5.sp,
              height: 1.45,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF707070),
            ),
          ),

          SizedBox(height: 4.h),

          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                setState(() {
                  expanded = !expanded;
                });
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 3.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      expanded ? "Read less".tr : "Read more".tr,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),

                    SizedBox(width: 7.w),

                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}