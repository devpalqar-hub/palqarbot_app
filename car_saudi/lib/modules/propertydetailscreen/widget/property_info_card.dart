import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';

class PropertyInfoCard extends StatelessWidget {
  final Property property;

  const PropertyInfoCard({super.key, required this.property});

  static const Color primary = Color(0xFFA60F46);
  static const Color textDark = Color(0xFF1F2937);
  static const Color greyText = Color(0xFF777777);
  static const Color borderColor = Color(0xFFE7E7E7);

  @override
  Widget build(BuildContext context) {
    final String propertyType = property.type.title
        .replaceAll("_", " ")
        .toLowerCase()
        .split(" ")
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(" ");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),

        // =========================================================
        // FOR SALE PILL
        // =========================================================
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: primary.withOpacity(.65), width: 1),
          ),
          child: Text(
            "For Sale".tr,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),

        SizedBox(height: 10.h),

        // =========================================================
        // PROPERTY TITLE
        // =========================================================
        Text(
          property.propertyName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15.sp,
            height: 1.15,
            fontWeight: FontWeight.w500,
            color: textDark,
            letterSpacing: -.25,
          ),
        ),

        SizedBox(height: 8.h),

        // =========================================================
        // LOCATION + VERIFIED
        // =========================================================
        Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 18.sp,
              color: const Color(0xFF888888),
            ),

            SizedBox(width: 8.w),

            Expanded(
              child: Text(
                "${property.areaName}, ${property.municipality.name}, ${property.country}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(255, 110, 109, 109),
                ),
              ),
            ),

            SizedBox(width: 5.w),
            if (property.priceNegotiable)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 14.sp,
                      color: Colors.green,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "Negotiable".tr,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        SizedBox(height: 12.h),

        // =========================================================
        // PROPERTY INFORMATION CARD
        // =========================================================
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            children: [
              // ================= FIRST ROW =================
              SizedBox(
                height: 43.h,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          "${"ID #".tr}${_shortId(property.id)}",
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                      ),
                    ),

                    _verticalDivider(),

                    Expanded(
                      child: _infoItem(
                        icon: Icons.near_me_outlined,
                        text: "1.2 km ${"away".tr}",
                      ),
                    ),

                    _verticalDivider(),

                    Expanded(
                      child: _infoItem(
                        icon: Icons.square_foot_outlined,
                        text: "${property.area} ${"sqm".tr}",
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, thickness: 1, color: borderColor),

              // ================= SECOND ROW =================
              SizedBox(
                height: 43.h,
                child: Row(
                  children: [
                    Expanded(
                      child: _infoItem(
                        icon: Icons.bed_outlined,
                        text: "${property.bedrooms} ${"Beds".tr}",
                      ),
                    ),

                    _verticalDivider(),

                    Expanded(
                      child: _infoItem(
                        icon: Icons.bathtub_outlined,
                        text: "${property.bathrooms} ${"Baths".tr}",
                      ),
                    ),

                    _verticalDivider(),

                    Expanded(
                      child: _infoItem(
                        icon: Icons.home_work_outlined,
                        text: propertyType.tr,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _shortId(dynamic id) {
    final value = id?.toString() ?? "";

    if (value.isEmpty) {
      return "-";
    }

    return value.length > 8
        ? value.substring(0, 8).toUpperCase()
        : value.toUpperCase();
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 26.h, color: const Color(0xFFE3E3E3));
  }

  Widget _infoItem({required IconData icon, required String text}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp, color: const Color(0xFF858585)),

          SizedBox(width: 7.w),

          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w400,
                color: greyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
