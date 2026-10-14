import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/modules/support/views/support_ticketdetail_screen.dart';
import 'package:villas_qatar/modules/support/model/support_ticket_model.dart';
import 'package:villas_qatar/modules/support/service/support_ticket_controller.dart';

class MyTicketScreen extends StatefulWidget {
  const MyTicketScreen({super.key});

  @override
  State<MyTicketScreen> createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen> {
  late final SupportTicketController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<SupportTicketController>()
        ? Get.find<SupportTicketController>()
        : Get.put(SupportTicketController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTickets(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "My Tickets".tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF222222),
          ),
        ),
      ),

      body: GetBuilder<SupportTicketController>(
        builder: (controller) {
          // ====================================================
          // LOADING
          // ====================================================

          if (controller.isLoading && controller.tickets.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            );
          }

          // ====================================================
          // ERROR
          // ====================================================

          if (controller.error.isNotEmpty && controller.tickets.isEmpty) {
            return _buildErrorState(controller);
          }

          // ====================================================
          // EMPTY
          // ====================================================

          if (controller.tickets.isEmpty) {
            return _buildEmptyState();
          }

          // ====================================================
          // LIST
          // ====================================================

          return RefreshIndicator(
            color: AppColors.primary,

            onRefresh: () {
              return controller.refreshTickets();
            },

            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 30.h),

              itemCount:
                  controller.tickets.length + (controller.hasMore ? 1 : 0),

              separatorBuilder: (context, index) {
                return SizedBox(height: 10.h);
              },

              itemBuilder: (context, index) {
                // ==============================================
                // LOAD MORE
                // ==============================================

                if (index == controller.tickets.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.loadMore();
                  });

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }

                final SupportTicket ticket = controller.tickets[index];

                return _buildTicketCard(ticket);
              },
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // TICKET CARD
  // ============================================================

  Widget _buildTicketCard(SupportTicket ticket) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),

        onTap: () {
          Get.to(() => SupportTicketDetailsScreen(ticketId: ticket.id));
        },

        child: Container(
          width: double.infinity,

          padding: EdgeInsets.all(15.w),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(14.r),

            border: Border.all(color: AppColors.fieldBorder.withOpacity(.8)),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.025),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ================================================
              // ICON
              // ================================================
              Container(
                width: 44.w,
                height: 44.w,

                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.07),

                  borderRadius: BorderRadius.circular(11.r),
                ),

                child: Icon(
                  _categoryIcon(ticket.category),
                  color: AppColors.primary,
                  size: 21.sp,
                ),
              ),

              SizedBox(width: 12.w),

              // ================================================
              // CONTENT
              // ================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ticket.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF252525),
                            ),
                          ),
                        ),

                        SizedBox(width: 8.w),

                        _statusBadge(ticket.status),
                      ],
                    ),

                    SizedBox(height: 7.h),

                    Text(
                      _categoryLabel(ticket.category),
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 14.sp,
                          color: Colors.grey.shade500,
                        ),

                        SizedBox(width: 5.w),

                        Text(
                          "${ticket.repliesCount} "
                          "${ticket.repliesCount == 1 ? 'Reply'.tr : 'Replies'.tr}",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const Spacer(),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13.sp,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(String status) {
    final String value = status.toUpperCase();

    Color color;

    switch (value) {
      case "OPEN":
        color = Colors.orange;
        break;

      case "IN_PROGRESS":
        color = Colors.blue;
        break;

      case "RESOLVED":
      case "CLOSED":
        color = Colors.green;
        break;

      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),

      decoration: BoxDecoration(
        color: color.withOpacity(.08),

        borderRadius: BorderRadius.circular(20.r),
      ),

      child: Text(
        _formatStatus(status),
        style: TextStyle(
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    return status
        .replaceAll("_", " ")
        .toLowerCase()
        .split(" ")
        .map(
          (word) => word.isEmpty
              ? word
              : "${word[0].toUpperCase()}${word.substring(1)}",
        )
        .join(" ").tr;
  }

  String _categoryLabel(String category) {
    switch (category) {
      case "GENERAL":
        return "General Support".tr;

      case "PAYMENT":
        return "Payment Issue".tr;

      case "REPORT_USER":
        return "Reported User".tr;

      case "REPORT_LISTING":
        return "Reported Listing".tr;

      default:
        return category;
    }
  }
  IconData _categoryIcon(String category) {
    switch (category) {
      case "PAYMENT":
        return Icons.account_balance_wallet_outlined;

      case "REPORT_USER":
        return Icons.person_off_outlined;

      case "REPORT_LISTING":
        return Icons.flag_outlined;

      default:
        return Icons.help_outline_rounded;
    }
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 70.w,
              height: 70.w,

              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.07),

                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.confirmation_number_outlined,
                color: AppColors.primary,
                size: 32.sp,
              ),
            ),

            SizedBox(height: 18.h),

            Text(
              "No Support Tickets".tr,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),

            SizedBox(height: 7.h),

            Text(
              "Your submitted support requests will appear here.".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState(SupportTicketController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.primary,
              size: 42.sp,
            ),

            SizedBox(height: 12.h),

            Text(
              controller.error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
            ),

            SizedBox(height: 16.h),

            ElevatedButton(
              onPressed: () {
                controller.retry();
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,

                foregroundColor: Colors.white,

                elevation: 0,
              ),

              child:  Text("Retry".tr),
            ),
          ],
        ),
      ),
    );
  }
}
