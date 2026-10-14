import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/modules/support/model/support_ticket_details.dart';
import 'package:villas_qatar/modules/support/service/support_ticket_controller.dart';

class SupportTicketDetailsScreen extends StatefulWidget {
  final String ticketId;

  const SupportTicketDetailsScreen({super.key, required this.ticketId});

  @override
  State<SupportTicketDetailsScreen> createState() =>
      _SupportTicketDetailsScreenState();
}

class _SupportTicketDetailsScreenState
    extends State<SupportTicketDetailsScreen> {
  late final SupportTicketController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<SupportTicketController>()
        ? Get.find<SupportTicketController>()
        : Get.put(SupportTicketController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTicketDetails(widget.ticketId);
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

        leading: IconButton(
          onPressed: () => Get.back(),

          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: AppColors.primary,
          ),
        ),

        title: Text(
          "Ticket Details".tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF222222),
          ),
        ),
      ),

      body: GetBuilder<SupportTicketController>(
        builder: (controller) {
          if (controller.isTicketDetailsLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            );
          }

          if (controller.ticketDetailsError.isNotEmpty &&
              controller.selectedTicket == null) {
            return _errorView(controller);
          }

          final SupportTicketDetails? ticket = controller.selectedTicket;

          if (ticket == null) {
            return const SizedBox();
          }

          return RefreshIndicator(
            color: AppColors.primary,

            onRefresh: () async {
              await controller.fetchTicketDetails(widget.ticketId);
            },

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 30.h),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _ticketHeader(ticket),

                  SizedBox(height: 18.h),

                  /// TICKET INFORMATION
                  _sectionTitle("Ticket Information".tr),
                  SizedBox(height: 10.h),
                  _ticketInformationCard(ticket),

                  SizedBox(height: 22.h),

                  /// SUBMITTER
                  _sectionTitle("Submitted By".tr),
                  SizedBox(height: 10.h),
                  _submitterCard(ticket),

                  /// ASSIGNED TO - only when available
                  if (ticket.assignedTo != null) ...[
                    SizedBox(height: 22.h),
                    _sectionTitle("Assigned To".tr),
                    SizedBox(height: 10.h),
                    _assignedToCard(ticket),
                  ],

                  SizedBox(height: 22.h),

                  /// ORIGINAL REQUEST
                  _sectionTitle("Your Request".tr),
                  SizedBox(height: 10.h),
                  _messageCard(ticket),

                  SizedBox(height: 24.h),

                  /// REPLIES HEADER
                  Row(
                    children: [
                      _sectionTitle("Support Replies".tr),
                      const Spacer(),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.07),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          "${ticket.replies.length} "
                          "${ticket.replies.length == 1 ? 'Reply'.tr : 'Replies'.tr}",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  if (ticket.replies.isEmpty)
                    _noReplies()
                  else
                    ...ticket.replies.map((reply) => _replyCard(reply)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _ticketHeader(SupportTicketDetails ticket) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(15.r),

        border: Border.all(color: AppColors.fieldBorder.withOpacity(.8)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,

                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.07),

                  borderRadius: BorderRadius.circular(11.r),
                ),

                child: Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      ticket.subject,

                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF252525),
                      ),
                    ),

                    SizedBox(height: 5.h),

                    Text(
                      _categoryLabel(ticket.category),

                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(ticket.status),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORIGINAL MESSAGE
  // ============================================================

  Widget _messageCard(SupportTicketDetails ticket) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(15.w),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(13.r),

        border: Border.all(color: AppColors.fieldBorder.withOpacity(.8)),
      ),

      child: Text(
        ticket.message.isNotEmpty ? ticket.message : "No description provided.".tr,

        style: TextStyle(
          fontSize: 12.sp,
          height: 1.55,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  // ============================================================
  // ADMIN REPLY
  Widget _replyCard(SupportTicketReply reply) {
    final String authorName = reply.author?.name?.trim().isNotEmpty == true
        ? reply.author!.name!
        : reply.isAdmin
        ? "Support Team".tr
        : "User".tr;

    final String? email = reply.author?.email?.trim().isNotEmpty == true
        ? reply.author!.email
        : null;

    final String role = reply.author?.role.replaceAll("_", " ") ?? "";

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: reply.isAdmin
            ? AppColors.primary.withOpacity(.035)
            : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: reply.isAdmin
              ? AppColors.primary.withOpacity(.13)
              : AppColors.fieldBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.primary.withOpacity(.09),
                child: Icon(
                  reply.isAdmin
                      ? Icons.support_agent_rounded
                      : Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 18.sp,
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            authorName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        if (reply.isAdmin) ...[
                          SizedBox(width: 6.w),

                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(.09),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              "Support".tr,
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (email != null) ...[
                      SizedBox(height: 2.h),

                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],

                    if (role.isNotEmpty) ...[
                      SizedBox(height: 2.h),

                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (reply.createdAt != null)
                Text(
                  _formatDateTime(reply.createdAt),
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),

          SizedBox(height: 13.h),

          Divider(height: 1, color: Colors.grey.shade200),

          SizedBox(height: 12.h),

          Text(
            reply.message,
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.55,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // NO REPLIES
  // ============================================================

  Widget _noReplies() {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(13.r),

        border: Border.all(color: AppColors.fieldBorder),
      ),

      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 30.sp,
            color: Colors.grey.shade400,
          ),

          SizedBox(height: 10.h),

          Text(
            "No replies yet".tr,

            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 5.h),

          Text(
            "Our support team will respond here.".tr,

            textAlign: TextAlign.center,

            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,

      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;

    switch (status.toUpperCase()) {
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),

      decoration: BoxDecoration(
        color: color.withOpacity(.08),

        borderRadius: BorderRadius.circular(20.r),
      ),

      child: Text(
        status.replaceAll("_", " "),

        style: TextStyle(
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
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

  Widget _errorView(SupportTicketController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 42.sp,
              color: AppColors.primary,
            ),

            SizedBox(height: 12.h),

            Text(controller.ticketDetailsError, textAlign: TextAlign.center),

            SizedBox(height: 15.h),

            ElevatedButton(
              onPressed: () {
                controller.fetchTicketDetails(widget.ticketId);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,

                foregroundColor: Colors.white,
              ),

              child: Text("Retry".tr),
            ),
          ],
        ),
      ),
    );
  }
}

String _categoryLabel(String category) {
  switch (category.toUpperCase()) {
    case "GENERAL":
      return "General Support".tr;

    case "PAYMENT":
      return "Payment Issue".tr;

    case "REPORT_USER":
      return "Reported User".tr;

    case "REPORT_LISTING":
      return "Reported Listing".tr;

    default:
      return category
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
}

Widget _ticketInformationCard(SupportTicketDetails ticket) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.fieldBorder.withOpacity(.8)),
    ),
    child: Column(
      children: [
        _detailRow(
          icon: Icons.confirmation_number_outlined,
          label: "Ticket ID".tr,
          value: ticket.id,
        ),

        _divider(),

        _detailRow(
          icon: Icons.category_outlined,
          label: "Category".tr,
          value: _categoryLabel(ticket.category),
        ),

        _divider(),

        _detailRow(
          icon: Icons.info_outline_rounded,
          label: "Status".tr,
          value: ticket.status.replaceAll("_", " "),
        ),

        if (ticket.listingId != null &&
            ticket.listingId!.trim().isNotEmpty) ...[
          _divider(),
          _detailRow(
            icon: Icons.home_work_outlined,
            label: "Listing ID".tr,
            value: ticket.listingId!,
          ),
        ],

        if (ticket.reportedUserId != null &&
            ticket.reportedUserId!.trim().isNotEmpty) ...[
          _divider(),
          _detailRow(
            icon: Icons.person_off_outlined,
            label: "Reported User ID".tr,
            value: ticket.reportedUserId!,
          ),
        ],

        // if (ticket.referenceId != null &&
        //     ticket.referenceId!.trim().isNotEmpty) ...[
        //   _divider(),
        //   _detailRow(
        //     icon: Icons.link_rounded,
        //     label: "Reference ID",
        //     value: ticket.referenceId!,
        //   ),
        // ],
        _divider(),

        _detailRow(
          icon: Icons.calendar_today_outlined,
          label: "Created".tr,
          value: _formatDateTime(ticket.createdAt),
        ),

        _divider(),

        _detailRow(
          icon: Icons.update_rounded,
          label: "Last Updated".tr,
          value: _formatDateTime(ticket.updatedAt),
        ),
      ],
    ),
  );
}

Widget _detailRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(.06),
          borderRadius: BorderRadius.circular(9.r),
        ),
        child: Icon(icon, size: 17.sp, color: AppColors.primary),
      ),

      SizedBox(width: 11.w),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 3.h),

            Text(
              value.isNotEmpty ? value : "Not available".tr,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF303030),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _divider() {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    child: Divider(height: 1, thickness: .7, color: Colors.grey.shade200),
  );
}

String _formatDateTime(DateTime? date) {
  if (date == null) {
    return "Not available".tr;
  }

  final local = date.toLocal();

  return DateFormat('dd MMM yyyy • hh:mm a').format(local);
}

Widget _assignedToCard(SupportTicketDetails ticket) {
  final assigned = ticket.assignedTo;

  if (assigned == null) {
    return const SizedBox.shrink();
  }

  final String name = assigned.name?.trim().isNotEmpty == true
      ? assigned.name!
      : "Support Agent".tr;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(15.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.fieldBorder.withOpacity(.8)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 21.r,
          backgroundColor: AppColors.primary.withOpacity(.08),
          child: Icon(
            Icons.support_agent_rounded,
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
                name,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
              ),

              if (assigned.email?.trim().isNotEmpty == true) ...[
                SizedBox(height: 3.h),
                Text(
                  assigned.email!,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],

              SizedBox(height: 3.h),

              Text(
                assigned.role.replaceAll("_", " "),
                style: TextStyle(
                  fontSize: 9.5.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _submitterCard(SupportTicketDetails ticket) {
  final submitter = ticket.submitter;

  if (submitter == null) {
    return _emptyInfoCard("Submitter information is not available.".tr);
  }

  final String name = submitter.name?.trim().isNotEmpty == true
      ? submitter.name!
      : "User".tr;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(15.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.fieldBorder.withOpacity(.8)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 21.r,
              backgroundColor: AppColors.primary.withOpacity(.08),
              child: Icon(
                Icons.person_outline_rounded,
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
                    name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Text(
                    submitter.role.replaceAll("_", " "),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 14.h),

        _smallInfoRow("User ID".tr, submitter.id),

        if (submitter.email?.trim().isNotEmpty == true) ...[
          SizedBox(height: 9.h),
          _smallInfoRow("Email".tr, submitter.email!),
        ],
      ],
    ),
  );
}

Widget _smallInfoRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 72.w,
        child: Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
        ),
      ),

      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 10.5.sp,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

Widget _emptyInfoCard(String text) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(15.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13.r),
      border: Border.all(color: AppColors.fieldBorder),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
    ),
  );
}
