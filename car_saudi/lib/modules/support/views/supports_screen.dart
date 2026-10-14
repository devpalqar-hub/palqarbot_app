import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/modules/support/views/my_tickets_screen.dart';
import 'package:villas_qatar/modules/support/service/support_ticket_controller.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  SupportCategory selectedCategory = SupportCategory.general;

  SupportTicketController get controller =>
      Get.isRegistered<SupportTicketController>()
      ? Get.find<SupportTicketController>()
      : Get.put(SupportTicketController());

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar:AppBar(
  backgroundColor: AppColors.background,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,


  title: Text(
    "Support".tr,
    style: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF222222),
    ),
  ),

  actions: [
    IconButton(
      tooltip: "My Tickets".tr,
      onPressed: () {
        Get.to(
          () => const MyTicketScreen(),
        );
      },
      icon: Icon(
        Icons.receipt_long_outlined,
        size: 22.sp,
        color: AppColors.primary,
      ),
    ),

    SizedBox(width: 6.w),
  ],
),
      body: GetBuilder<SupportTicketController>(
        init: controller,
        builder: (supportController) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // HEADER
                // =================================================
                _buildHeader(),

                SizedBox(height: 26.h),

                _sectionLabel("What can we help you with?".tr),

                SizedBox(height: 12.h),

                // =================================================
                // GENERAL SUPPORT
                // =================================================
                _categoryTile(
                  icon: Icons.help_outline_rounded,
                  title: "General Support".tr,
                  subtitle: "Questions, account help or any general issue.".tr,
                  category: SupportCategory.general,
                ),

                SizedBox(height: 10.h),

                // =================================================
                // PAYMENT SUPPORT
                // =================================================
                _categoryTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Payment Issue".tr,
                  subtitle:
                      "Payment, billing, transaction or subscription issues.".tr,
                  category: SupportCategory.payment,
                ),

                SizedBox(height: 26.h),

                _sectionLabel("Tell us about the issue".tr),

                SizedBox(height: 12.h),

                // =================================================
                // FORM
                // =================================================
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.fieldBorder.withOpacity(.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.025),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Subject".tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      TextField(
                        controller: subjectController,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF222222),
                        ),
                        decoration: _inputDecoration(
                          hint: selectedCategory == SupportCategory.payment
                              ? "e.g. Payment failed".tr
                              : "Briefly describe your issue".tr,
                          icon: Icons.title_rounded,
                        ),
                      ),

                      SizedBox(height: 18.h),

                      Text(
                        "Description".tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      TextField(
                        controller: messageController,
                        maxLines: 5,
                        maxLength: 500,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.45,
                          color: const Color(0xFF222222),
                        ),
                        decoration: _inputDecoration(
                          hint: selectedCategory == SupportCategory.payment
                              ? "Explain the payment issue, transaction details, or what went wrong...".tr
                              : "Tell us what happened and how we can help...".tr,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 22.h),

                // =================================================
                // INFO
                // =================================================
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(13.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(.08),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 18.sp,
                      ),

                      SizedBox(width: 10.w),

                      Expanded(
                        child: Text(
                          "Please provide enough details so our support team can understand and resolve your issue.".tr,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            height: 1.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 22.h),

                // =================================================
                // SUBMIT
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: supportController.isCreating
                        ? null
                        : () => _submitSupport(supportController),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(
                        .5,
                      ),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                    ),
                    child: supportController.isCreating
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 17.sp),
                              SizedBox(width: 8.w),
                              Text(
                                "Submit Request".tr,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.08),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 27.sp,
              color: AppColors.primary,
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How can we help?".tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF222222),
                  ),
                ),

                SizedBox(height: 5.h),

                Text(
                  "Send us your issue and our support team will assist you.".tr,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    height: 1.45,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY TILE
  // ============================================================

  Widget _categoryTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required SupportCategory category,
  }) {
    final bool selected = selectedCategory == category;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(13.r),
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(.055)
                : Colors.white,
            borderRadius: BorderRadius.circular(13.r),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.fieldBorder,
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 21.sp),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF292929),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10.sp,
                        height: 1.35,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 20.sp,
                color: selected ? AppColors.primary : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 10.5.sp, color: Colors.grey.shade500),

      prefixIcon: icon != null
          ? Icon(icon, size: 18.sp, color: Colors.grey.shade500)
          : null,

      filled: true,
      fillColor: const Color(0xFFFAFAFA),

      contentPadding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 13.h),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.2),
      ),
    );
  }

  // ============================================================
  // SECTION LABEL
  // ============================================================

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 3.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submitSupport(SupportTicketController supportController) async {
    final String subject = subjectController.text.trim();

    final String message = messageController.text.trim();

    // ============================================================
    // SUBJECT VALIDATION
    // ============================================================

    if (subject.isEmpty) {
      AppToast.show(
        msg: "Please enter a subject for your request.".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // ============================================================
    // MESSAGE VALIDATION
    // ============================================================

    if (message.isEmpty) {
      AppToast.show(
        msg: "Please describe the issue.".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // ============================================================
    // GET CURRENT USER ID
    // ============================================================

    final String currentUserId = _getCurrentUserIdFromToken();

    debugPrint("========== SUPPORT SUBMIT ==========");
    debugPrint("CATEGORY: ${selectedCategory.apiValue}");
    debugPrint("CURRENT USER ID: $currentUserId");
    debugPrint("SUBJECT: $subject");
    debugPrint("MESSAGE: $message");

    // ============================================================
    // USER ID VALIDATION
    // ============================================================

    if (currentUserId.isEmpty) {
      AppToast.show(
        msg: "Unable to identify the logged-in user.".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // ============================================================
    // CREATE SUPPORT TICKET
    // ============================================================

    final result = await supportController.createTicket(
      category: selectedCategory,
      subject: subject,
      message: message,
      reportedUserId: currentUserId,
    );

    // ============================================================
    // SUCCESS
    // ============================================================

    if (result != null) {
      if (!mounted) return;

      subjectController.clear();
      messageController.clear();

      setState(() {
        selectedCategory = SupportCategory.general;
      });

      AppToast.show(
        msg: "Your support request has been submitted successfully.".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
    // ============================================================
    // ERROR
    // ============================================================
    else {
      AppToast.show(
        msg: supportController.createError.isNotEmpty
            ? supportController.createError
            : "Unable to submit. Please try again.".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  String _getCurrentUserIdFromToken() {
    try {
      final String? token = StorageService.getToken();

      if (token == null || token.trim().isEmpty) {
        debugPrint("JWT TOKEN IS EMPTY");
        return "";
      }

      final List<String> parts = token.split('.');

      if (parts.length != 3) {
        debugPrint("INVALID JWT TOKEN");
        return "";
      }

      final String normalizedPayload = base64Url.normalize(parts[1]);

      final String decodedPayload = utf8.decode(
        base64Url.decode(normalizedPayload),
      );

      final Map<String, dynamic> payload = jsonDecode(decodedPayload);

      debugPrint("========== JWT PAYLOAD ==========");
      debugPrint("PAYLOAD: $payload");

      final String userId =
          (payload["userId"] ?? payload["id"] ?? payload["sub"] ?? "")
              .toString()
              .trim();

      debugPrint("CURRENT USER ID: $userId");

      return userId;
    } catch (e) {
      debugPrint("JWT DECODE ERROR: $e");
      return "";
    }
  }
}
