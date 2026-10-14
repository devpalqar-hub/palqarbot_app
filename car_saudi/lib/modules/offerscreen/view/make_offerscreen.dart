import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/modules/chats/views/chatscreen.dart';
import 'package:villas_qatar/modules/chats/service/chat_controller.dart';
import 'package:villas_qatar/modules/chats/views/chat_startscreen.dart';

import 'package:villas_qatar/modules/offerscreen/service/offer_controller.dart';
import 'package:villas_qatar/modules/offerscreen/widget/offer_sucessdailogue.dart';
import 'package:villas_qatar/modules/offerscreen/widget/property_summarycard.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_textstyles.dart';

class MakeOfferScreen extends StatefulWidget {
  final Property property;

  const MakeOfferScreen({super.key, required this.property});

  @override
  State<MakeOfferScreen> createState() => _MakeOfferScreenState();
}

class _MakeOfferScreenState extends State<MakeOfferScreen> {
  late final MakeOfferController controller;
  late final TextEditingController offerController;

  String currency = "QAR";

  @override
  void initState() {
    super.initState();

    controller = Get.put(MakeOfferController());

    offerController = TextEditingController(
      text: widget.property.price?.toString() ?? "",
    );
  }

  @override
  void dispose() {
    offerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCFCFC),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Image.asset(
                "assets/bg2.png",
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),

                  ///================ App Bar ===================
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () => Get.back(),
                        child: SizedBox(
                          width: 38.w,
                          height: 38.w,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Text(
                            "Make an Offer".tr,
                            style: AppTextStyles.title18.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 38.w),
                    ],
                  ),

                  SizedBox(height: 18.h),

                  ///================ Property Card ===================
                  PropertySummaryCard(property: widget.property),

                  SizedBox(height: 18.h),

                  ///================ Title ===================
                  Text(
                    "Your Offer Details".tr,
                    style: AppTextStyles.title16.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  ///================ Offer Amount ===================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 62.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffE8E8E8)),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Offer Amount".tr,
                                style: AppTextStyles.body13.copyWith(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              Expanded(
                                child: TextField(
                                  controller: offerController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: AppTextStyles.title14.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      ///================ Currency ===================
                      Expanded(
                        child: Container(
                          height: 62.h,
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffE8E8E8)),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Currency".tr,
                                style: AppTextStyles.body13.copyWith(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: currency,
                                  isExpanded: true,
                                  isDense: true,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18.sp,
                                  ),
                                  style: AppTextStyles.title14.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: "QAR",
                                      child: Text("QAR".tr),
                                    ),
                                    DropdownMenuItem(
                                      value: "USD",
                                      child: Text("USD".tr),
                                    ),
                                    DropdownMenuItem(
                                      value: "AED",
                                      child: Text("AED".tr),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        currency = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  ///================ Seller Actions ===================
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52.h,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (Get.isRegistered<ChatController>()) {
                                Get.delete<ChatController>();
                              }
                              Get.put(
                                ChatController(listingId: widget.property.id!),
                              );

                              Get.to(
                                () => ChatStartScreen(
                                  property: widget.property,
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 20.sp,
                            ),
                            label: Text(
                              "Chat with Seller".tr,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.medium14.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),
                      Expanded(
                        child: SizedBox(
                          height: 52.h,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (Get.isRegistered<ChatController>()) {
                                Get.delete<ChatController>();
                              }

                              Get.put(
                                ChatController(listingId: widget.property.id!),
                              );

                              Get.to(
                                () => ChatStartScreen(
                                  property: widget.property,
                                  initialMessage:
                                      "I'm ready to buy this property for QAR @amount"
                                          .trParams({
                                            'amount': offerController.text,
                                          }),
                                ),
                              );
                            },
                            icon: Icon(Icons.send_rounded, size: 18.sp),
                            label: Text(
                              "Send".tr,
                              style: AppTextStyles.medium14.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 28.h),

                  ///================ Submit Button ===================
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const OfferSuccessDialog(),
                        );
                      },
                      child: Text(
                        "Submit Offer".tr,
                        style: AppTextStyles.bold16.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 120.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
