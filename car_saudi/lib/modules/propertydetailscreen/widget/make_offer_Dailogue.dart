import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../Core/constants/app_colors.dart';
import '../../../Core/theme/app_textstyles.dart';
import '../../chats/service/chat_controller.dart';
import '../../chats/views/chat_startscreen.dart';
import '../../propertylist/model/myproperty_model.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class MakeOfferBottomSheet extends StatefulWidget {
  final Property property;

  const MakeOfferBottomSheet({super.key, required this.property});

  @override
  State<MakeOfferBottomSheet> createState() => _MakeOfferBottomSheetState();
}

class _MakeOfferBottomSheetState extends State<MakeOfferBottomSheet> {
  late final TextEditingController offerController;

  String currency = "QAR";

  @override
  void initState() {
    super.initState();

    offerController = TextEditingController(
      text: widget.property.price.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    offerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffFAFAFA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ==========================================
          // DRAG HANDLE
          // ==========================================
          SizedBox(height: 10.h),

          Container(
            width: 42.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xffD5D5D5),
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),

          // ==========================================
          // HEADER
          // ==========================================
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 10.w, 12.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Make an Offer".tr,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff1F1F1F),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: Get.back,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 22.sp,
                    color: const Color(0xff333333),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xffEEEEEE)),

          // ==========================================
          // SCROLLABLE CONTENT
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================
                  // SECTION 1
                  // ==================================
                  _sectionTitle(
                    "Property Price".tr,
                    subtitle:
                        "Review the listed price before making your offer".tr,
                    step: "1",
                  ),

                  SizedBox(height: 14.h),

                  // ==================================
                  // LISTED PRICE CARD
                  // ==================================
                  _buildListedPriceCard(),

                  SizedBox(height: 22.h),

                  // ==================================
                  // SECTION 2
                  // ==================================
                  _sectionTitle(
                    "Your Offer".tr,
                    subtitle: "Enter the amount you would like to offer".tr,
                    step: "2",
                  ),

                  SizedBox(height: 14.h),

                  // ==================================
                  // OFFER FIELD
                  // ==================================
                  _buildOfferField(),

                  SizedBox(height: 16.h),

                  // ==================================
                  // INFO BOX
                  // ==================================
                  _buildOfferInfo(),
                ],
              ),
            ),
          ),

          // ==========================================
          // FIXED BOTTOM BAR
          // ==========================================
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ================================================
  // SECTION TITLE
  // ================================================

  Widget _sectionTitle(
    String title, {
    required String subtitle,
    required String step,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 25.w,
          height: 25.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            step,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        SizedBox(width: 10.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff222222),
                ),
              ),

              SizedBox(height: 3.h),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  color: const Color(0xff888888),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================================================
  // LISTED PRICE
  // ================================================

  Widget _buildListedPriceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xffEAEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.07),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              Icons.home_work_outlined,
              color: AppColors.primary,
              size: 21.sp,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Listed Price".tr,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: const Color(0xff777777),
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  "${"QAR".tr} ${_formatPrice(widget.property.price)}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.06),
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Text(
              "LISTED".tr,
              style: TextStyle(
                fontSize: 7.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================
  // OFFER FIELD
  // ================================================

  Widget _buildOfferField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Offer Amount".tr,
          style: AppTextStyles.body13.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xff333333),
          ),
        ),

        SizedBox(height: 7.h),

        Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xffE5E5E5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: offerController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff222222),
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter amount".tr,
                    hintStyle: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xff999999),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 15.h,
                    ),
                  ),
                ),
              ),

              Container(height: 30.h, width: 1, color: const Color(0xffE5E5E5)),

              Padding(
                padding: EdgeInsets.only(left: 10.w, right: 10.w),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currency,
                    borderRadius: BorderRadius.circular(12.r),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    items: [
                      DropdownMenuItem(value: "QAR", child: Text("QAR".tr)),
                      DropdownMenuItem(value: "USD", child: Text("USD".tr)),
                      DropdownMenuItem(value: "AED", child: Text("AED".tr)),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        currency = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================================================
  // OFFER INFO
  // ================================================

  Widget _buildOfferInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.045),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primary.withOpacity(.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 17.sp,
            color: AppColors.primary,
          ),

          SizedBox(width: 9.w),

          Expanded(
            child: Text(
              "Your offer will be sent directly to the property owner. You can continue the conversation through chat"
                  .tr,
              style: TextStyle(
                fontSize: 9.5.sp,
                height: 1.45,
                color: const Color(0xff666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================
  // BOTTOM BAR
  // ================================================

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 11.h, 16.w, 10.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffEEEEEE))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ======================================
            // CHAT SELLER
            // ======================================
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: OutlinedButton(
                  onPressed: _openChat,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 16.sp),

                      SizedBox(width: 7.w),

                      Text(
                        "Chat Seller".tr,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: 10.w),

            // ======================================
            // SEND OFFER
            // ======================================
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _sendOffer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Send Offer".tr,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(width: 7.w),

                      Icon(Icons.send_rounded, size: 15.sp),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================
  // CHAT SELLER
  // ================================================

  void _openChat() {
    Get.back();

    if (Get.isRegistered<ChatController>()) {
      Get.delete<ChatController>();
    }

    Get.put(ChatController(listingId: widget.property.id!));

    Get.to(() => ChatStartScreen(property: widget.property));
  }

  // ================================================
  // SEND OFFER
  // ================================================

  void _sendOffer() {
    final String offer = offerController.text.trim();

    if (offer.isEmpty) {
      AppToast.show(msg: "Please enter your offer amount.".tr);

      return;
    }

    final double? amount = double.tryParse(offer);

    if (amount == null || amount <= 0) {
      AppToast.show(msg: "Please enter a valid offer amount.".tr);

      return;
    }

    Get.back();

    if (Get.isRegistered<ChatController>()) {
      Get.delete<ChatController>();
    }

    Get.put(ChatController(listingId: widget.property.id!));

    Get.to(
      () => ChatStartScreen(
        property: widget.property,
        initialMessage: "ready_to_buy_property".trParams({
          "currency": currency,
          "amount": offerController.text.trim(),
        }),
      ),
    );
  }

  // ================================================
  // FORMAT PRICE
  // ================================================

  String _formatPrice(num? price) {
    if (price == null) {
      return "0";
    }

    return price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ",");
  }
}
