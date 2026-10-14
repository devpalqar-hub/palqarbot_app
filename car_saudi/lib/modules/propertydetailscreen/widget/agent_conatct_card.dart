import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/modules/dealers/view/dealer_detail_screen.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/sellerpropertyscreen/views/seller_property_screen.dart';

class AgentContactCard extends StatelessWidget {
  final Property property;
  const AgentContactCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return InkWell(
       borderRadius: BorderRadius.circular(16.r),
  onTap: () {
    final bool isDealer =
        property.createdBy.role.toUpperCase() == "DEALER";

    if (isDealer) {
      debugPrint("Dealer tapped");
      Get.to(
        () => const DealerDetailsScreen(),
        arguments: property.createdBy.id,
      );
    } else {
      debugPrint("Seller tapped");
      Get.to(
        () => SellerPropertiesScreen(
          sellerId: property.createdBy.id,
          sellerName: property.createdBy.name,
        ),
      );
    }
  },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
       decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
         border: Border.all(color: const Color(0xffECECEC)),
        
        boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
        ],
      ),
       
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
      // Avatar — real photo when the dealer has one, default avatar otherwise.
      Builder(
        builder: (context) {
          final String coverImage =
              property.createdBy.dealerProfile?.coverImage ?? "";

          if (coverImage.isEmpty) {
            return CircleAvatar(
              radius: 30.r,
              backgroundColor: const Color(0xffF3F4F6),
              backgroundImage: const AssetImage("assets/agent.png"),
            );
          }

          return CircleAvatar(
            radius: 30.r,
            backgroundColor: const Color(0xffF3F4F6),
            foregroundImage: NetworkImage(coverImage),
            // If the network image fails to load, fall back to the
            // default avatar instead of showing a broken image.
            onForegroundImageError: (_, __) {},
            child: const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage("assets/agent.png"),
            ),
          );
        },
      ),
      
      SizedBox(width: 14.w),
      
      // Details
      Expanded(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
      Text(
        property.createdBy.name.isNotEmpty
            ? property.createdBy.name
            : "Property Owner".tr,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xff202124),
        ),
      ),
      
      SizedBox(height: 4.h),
      
      Text(
        property.createdBy.role.toUpperCase() == "DEALER"
            ? "Dealer".tr
            : "Property Owner".tr,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
      
        
      
      if (property.contactVerified)
       
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_rounded,
                color: Colors.green,
                size: 14.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                "Verified Contact".tr,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      
      if (property.createdBy.role.toUpperCase() == "DEALER") ...[
        SizedBox(height: 5.h),
        Row(
          children: [
            Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 14.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              "4.9",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
            ),
            Text(
              " (150 Reviews)".tr,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
        ],
      ),
      ),
      
      SizedBox(width: 12.w),
      
      // Actions
      Row(
        children: [
          GestureDetector(
            onTap: () => _makeCall(property.contactPhone),
            child: _actionButton(
              color: AppColors.primary,
              icon: const Icon(
                Icons.call_outlined,
                color: Colors.white,
              ),
              label: "Call".tr,
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () {
              _trackWhatsappClick(property.id);
              _openWhatsApp(property.contactWhatsapp);
            },
            child: _actionButton(
              color: const Color(0xff25D366),
              icon: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.white,
              ),
              label: "WhatsApp".tr,
            ),
          ),
        ],
      ),
        ],
      )
        
      ),
    );
  }

  Widget _actionButton({
    required Color color,
    required Widget icon,
    required String label,
    Border? border,
  }) {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border,
          ),
          child: Center(child: icon),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xff333333),
          ),
        ),
      ],
    );
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final formattedPhone = phone.replaceAll("+", "");

    final uri = Uri.parse("https://wa.me/$formattedPhone");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ============================================================
  // TRACK WHATSAPP CLICK
  //
  // FIRE-AND-FORGET ANALYTICS PING — MUST NEVER BLOCK OR BREAK
  // THE WHATSAPP LAUNCH FLOW IF IT FAILS.
  //
  // POST /api/listings/:listingId/track/whatsapp-click
  // ============================================================
 Future<void> _trackWhatsappClick(String listingId) async {
  final endpoint = ApiEndpoints.listingWhatsappClick(listingId);
  try {
    final response = await ApiHandler.post(endpoint);
    if (response is Map<String, dynamic>) {
    }
  } catch (e, stackTrace) {
  }
}
}
