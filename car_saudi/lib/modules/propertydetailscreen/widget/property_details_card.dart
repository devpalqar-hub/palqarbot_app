import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';

class PropertyDetailsCard extends StatelessWidget {
  final Property property;

  const PropertyDetailsCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final details = [
      {
        "icon": Icons.square_foot_outlined,
        "title": "Built-up Area".tr,
        "value": "${property.area} ${"sqm".tr}",
      },
      {
        "icon": Icons.crop_square_outlined,
        "title": "Floor".tr,
        "value": "${property.floorNumber}/${property.totalFloors}",
      },
      {
        "icon": Icons.king_bed_outlined,
        "title": "Bedrooms".tr,
        "value": property.bedrooms.toString(),
      },
      {
        "icon": Icons.bathtub_outlined,
        "title": "Bathrooms".tr,
        "value": property.bathrooms.toString(),
      },
      {
        "icon": Icons.weekend_outlined,
        "title": "Living Rooms".tr,
        "value": property.livingRooms.toString(),
      },
      {
        "icon": Icons.directions_car_outlined,
        "title": "Parking".tr,
        "value": property.parkingSpaces.toString(),
      },
     {
  "icon": Icons.chair_outlined,
  "title": "Furnishing".tr,
  "value": property.furnishing.title.tr,
},
    {
  "icon": Icons.home_work_outlined,
  "title": "Property Type".tr,
  "value": property.type.title.tr,
},
      {
        "icon": Icons.sell_outlined,
        "title": "Purpose".tr,
        "value": property.purpose == "SALE" ? "For Sale".tr : "For Rent".tr,
      },
      {
        "icon": Icons.calendar_today_outlined,
        "title": "Year Built".tr,
        "value": property.yearBuilt?.toString() ?? "-",
      },
      {
        "icon": Icons.schedule_outlined,
        "title": "Listed On".tr,
        "value": DateFormat("dd MMM yyyy").format(property.createdAt),
      },
    ];
    return GestureDetector(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xffECECEC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Property Details".tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xff1F2937),
              ),
            ),

            SizedBox(height: 18.h),

            ...details.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(
                      item["icon"] as IconData,
                      color: const Color(0xff3D3D3D),
                      size: 16.sp,
                    ),

                    SizedBox(width: 14.w),

                    Expanded(
                      child: Text(
                        item["title"].toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff222222),
                        ),
                      ),
                    ),

                    Text(
                      item["value"].toString(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff666666),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
