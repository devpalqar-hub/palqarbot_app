import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:villas_qatar/Core/constants/app_colors.dart';

import 'package:villas_qatar/modules/visits/model/visit_model.dart';
import 'package:villas_qatar/modules/visits/service/visit_controller.dart';

class VisitListScreen extends StatefulWidget {
  const VisitListScreen({super.key});

  @override
  State<VisitListScreen> createState() => _VisitListScreenState();
}

class _VisitListScreenState extends State<VisitListScreen> {
  late final VisitController visitController;

  int selectedTab = 0;

  @override
  void initState() {
    super.initState();

    visitController = Get.isRegistered<VisitController>()
        ? Get.find<VisitController>()
        : Get.put(VisitController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      visitController.fetchOwnerVisits();
      visitController.fetchVisitorVisits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Column(
            children: [
              _buildTopBar(),

              SizedBox(height: 4.h),

              _buildTabs(),

              SizedBox(height: 12.h),

              Expanded(
                child: GetBuilder<VisitController>(
                  builder: (controller) {
                    if (selectedTab == 0) {
                      return _buildOwnerVisits(controller);
                    }

                    return _buildVisitorVisits(controller);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 16.w, 8.h),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () {
              Get.back();
            },
          ),

          Expanded(
            child: Text(
              "My Visits".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          // IconButton(
          //   icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          //   onPressed: () {
          //     if (selectedTab == 0) {
          //       visitController.fetchOwnerVisits();
          //     } else {
          //       visitController.fetchVisitorVisits();
          //     }
          //   },
          // ),
        ],
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xffF1F1F1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            _tabButton(title: "Visit Requests".tr, index: 0),
            _tabButton(title: "My Visits".tr, index: 1),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({required String title, required int index}) {
    final bool selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });

          if (index == 0 && visitController.ownerVisits.isEmpty) {
            visitController.fetchOwnerVisits();
          }

          if (index == 1 && visitController.visitorVisits.isEmpty) {
            visitController.fetchVisitorVisits();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.primary : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OWNER VISITS
  // ============================================================

  Widget _buildOwnerVisits(VisitController controller) {
    if (controller.isOwnerVisitsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (controller.ownerVisits.isEmpty) {
      return _emptyView(
        icon: Icons.event_busy_outlined,
        title: "No visit requests".tr,
        subtitle: "Visit requests for your properties will appear here".tr,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        return controller.fetchOwnerVisits();
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
        itemCount: controller.ownerVisits.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final VisitModel visit = controller.ownerVisits[index];

          return _ownerVisitCard(controller, visit);
        },
      ),
    );
  }

  // ============================================================
  // VISITOR VISITS
  // ============================================================

  Widget _buildVisitorVisits(VisitController controller) {
    if (controller.isVisitorVisitsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (controller.visitorVisits.isEmpty) {
      return _emptyView(
        icon: Icons.calendar_month_outlined,
        title: "No scheduled visits".tr,
        subtitle: "Properties you schedule for a visit will appear here".tr,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        return controller.fetchVisitorVisits();
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
        itemCount: controller.visitorVisits.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final VisitModel visit = controller.visitorVisits[index];

          return _visitorVisitCard(visit);
        },
      ),
    );
  }

  // ============================================================
  // OWNER VISIT CARD
  // ============================================================
  // ============================================================
  // OWNER VISIT CARD - COMPACT
  // ============================================================

  Widget _ownerVisitCard(VisitController controller, VisitModel visit) {
    final listing = visit.listing;
    final visitor = visit.visitor;

    final String? imageUrl = listing != null && listing.photos.isNotEmpty
        ? listing.photos.first.url
        : null;

    final DateTime? localDate = visit.scheduledAt?.toLocal();

    final String date = localDate != null
        ? DateFormat("dd MMM yyyy").format(localDate)
        : "Date not available".tr;

    final String time = localDate != null
        ? DateFormat("hh:mm a").format(localDate)
        : "";

    final bool isPending = visit.status.toUpperCase() == "PENDING".tr;

    final String visitorName = visitor?.name?.trim().isNotEmpty == true
        ? visitor!.name!.trim()
        : visitor?.phone ?? visitor?.email ?? "Visitor".tr;

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ======================================================
          // PROPERTY DETAILS
          // ======================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _propertyImage(imageUrl),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PROPERTY NAME + STATUS
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            listing?.propertyName?.trim().isNotEmpty == true
                                ? listing!.propertyName
                                : "Property".tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff222222),
                            ),
                          ),
                        ),

                        SizedBox(width: 6.w),

                        _statusBadge(visit.status),
                      ],
                    ),

                    SizedBox(height: 5.h),

                    // LOCATION
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12.sp,
                          color: Colors.grey.shade500,
                        ),

                        SizedBox(width: 3.w),

                        Expanded(
                          child: Text(
                            _locationText(listing),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 7.h),

                    // DATE + TIME
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11.sp,
                          color: AppColors.primary,
                        ),

                        SizedBox(width: 4.w),

                        Flexible(
                          child: Text(
                            date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff555555),
                            ),
                          ),
                        ),

                        if (time.isNotEmpty) ...[
                          SizedBox(width: 7.w),

                          Container(
                            width: 3.w,
                            height: 3.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),

                          SizedBox(width: 7.w),

                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 9.h),

          Divider(height: 1, color: Colors.grey.shade200),

          SizedBox(height: 8.h),

          // ======================================================
          // VISITOR + ACCEPT
          // ======================================================
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.07),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 15.sp,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(width: 7.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Requested by".tr,
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),

                    SizedBox(height: 1.h),

                    Text(
                      visitorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff333333),
                      ),
                    ),
                  ],
                ),
              ),

              if (isPending) ...[
                SizedBox(width: 8.w),

                SizedBox(
                  height: 32.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 13.w),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: controller.isAccepting
                        ? null
                        : () {
                            _confirmAccept(controller, visit);
                          },
                    child: controller.isAccepting
                        ? SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Accept".tr,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),

          // ======================================================
          // OPTIONAL NOTES
          // ======================================================
          if (visit.notes.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xffFAFAFA),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 12.sp,
                    color: Colors.grey.shade500,
                  ),

                  SizedBox(width: 5.w),

                  Expanded(
                    child: Text(
                      visit.notes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // VISITOR VISIT CARD - COMPACT
  // ============================================================

  Widget _visitorVisitCard(VisitModel visit) {
    final listing = visit.listing;
    final owner = visit.owner;

    final String? imageUrl = listing != null && listing.photos.isNotEmpty
        ? listing.photos.first.url
        : null;

    final DateTime? localDate = visit.scheduledAt?.toLocal();

    final String date = localDate != null
        ? DateFormat("dd MMM yyyy").format(localDate)
        : "Date not available".tr;

    final String time = localDate != null
        ? DateFormat("hh:mm a").format(localDate)
        : "";

    final String ownerName = owner?.name?.trim().isNotEmpty == true
        ? owner!.name!.trim()
        : owner?.phone ?? "Owner".tr;

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ======================================================
          // PROPERTY
          // ======================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _propertyImage(imageUrl),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PROPERTY NAME + STATUS
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            listing?.propertyName?.trim().isNotEmpty == true
                                ? listing!.propertyName
                                : "Property".tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff222222),
                            ),
                          ),
                        ),

                        SizedBox(width: 6.w),

                        _statusBadge(visit.status),
                      ],
                    ),

                    SizedBox(height: 5.h),

                    // LOCATION
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12.sp,
                          color: Colors.grey.shade500,
                        ),

                        SizedBox(width: 3.w),

                        Expanded(
                          child: Text(
                            _locationText(listing),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 7.h),

                    // DATE / TIME
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11.sp,
                          color: AppColors.primary,
                        ),

                        SizedBox(width: 4.w),

                        Flexible(
                          child: Text(
                            date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff555555),
                            ),
                          ),
                        ),

                        if (time.isNotEmpty) ...[
                          SizedBox(width: 7.w),

                          Container(
                            width: 3.w,
                            height: 3.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),

                          SizedBox(width: 7.w),

                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 9.h),

          Divider(height: 1, color: Colors.grey.shade200),

          SizedBox(height: 8.h),

          // ======================================================
          // OWNER
          // ======================================================
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.07),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 15.sp,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(width: 7.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Property owner".tr,
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),

                    SizedBox(height: 1.h),

                    Text(
                      ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff333333),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 12.sp,
                      color: AppColors.primary,
                    ),

                    SizedBox(width: 4.w),

                    Text(
                      "Scheduled".tr,
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ======================================================
          // NOTES
          // ======================================================
          if (visit.notes.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xffFAFAFA),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 12.sp,
                    color: Colors.grey.shade500,
                  ),

                  SizedBox(width: 5.w),

                  Expanded(
                    child: Text(
                      visit.notes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SMALL STANDARD PROPERTY IMAGE
  // ============================================================

  Widget _propertyImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9.r),
      child: SizedBox(
        width: 68.w,
        height: 68.h,
        child: imageUrl != null && imageUrl.trim().isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _fallbackImage();
                },
              )
            : _fallbackImage(),
      ),
    );
  }

  Widget _fallbackImage() {
    return Image.asset("assets/villa.jpg", fit: BoxFit.cover);
  }

  // ============================================================
  // STATUS
  // ============================================================
  Widget _statusBadge(String status) {
    final normalized = status.toUpperCase();

    Color background;
    Color foreground;

    switch (normalized) {
      case "ACCEPTED":
      case "CONFIRMED":
        background = Colors.green.withOpacity(.10);
        foreground = Colors.green.shade700;
        break;

      case "REJECTED":
      case "CANCELLED":
        background = Colors.red.withOpacity(.08);
        foreground = Colors.red.shade700;
        break;

      case "COMPLETED":
        background = Colors.blue.withOpacity(.08);
        foreground = Colors.blue.shade700;
        break;

      default:
        background = Colors.orange.withOpacity(.10);
        foreground = Colors.orange.shade800;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          fontSize: 7.5.sp,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return "Pending".tr;

    return status
        .toLowerCase()
        .split("_")
        .map(
          (word) => word.isEmpty
              ? ""
              : "${word[0].toUpperCase()}${word.substring(1)}",
        )
        .join(" ").tr;
  }

  // ============================================================
  // LOCATION
  // ============================================================

  String _locationText(VisitListing? listing) {
    if (listing == null) {
      return "Location not available".tr;
    }

    final parts = [
      listing.areaName,
      listing.municipality,
    ].where((e) => e.trim().isNotEmpty).toList();

    if (parts.isEmpty) {
      return listing.addressLine1.isNotEmpty
          ? listing.addressLine1
          : "Location not available".tr;
    }

    return parts.join(", ");
  }

  void _confirmAccept(VisitController controller, VisitModel visit) {
    final localDate = visit.scheduledAt?.toLocal();

    final dateTimeText = localDate != null
        ? DateFormat("dd MMM yyyy • hh:mm a").format(localDate)
        : "";

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 26.w),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// TOP CLOSE BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(50.r),
                    onTap: () {
                      /// Only close dialog
                      Get.back();
                    },
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),

              /// ICON
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primary,
                  size: 27.sp,
                ),
              ),

              SizedBox(height: 16.h),

              /// TITLE
              Text(
                "Visit Request".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF222222),
                ),
              ),

              SizedBox(height: 8.h),

              /// DESCRIPTION
              Text(
                dateTimeText.isEmpty
                    ? "Would you like to accept or reject this visit request?".tr
                    : "The visit is scheduled for $dateTimeText. Would you like to accept or reject this request?".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: const Color(0xFF777777),
                ),
              ),

              SizedBox(height: 24.h),

              /// ACCEPT + REJECT
              Row(
                children: [
                  /// REJECT
                  Expanded(
                    child: SizedBox(
                      height: 46.h,
                      child: OutlinedButton(
                        onPressed: () async {
                          /// Close dialog
                          Get.back();

                          /// Reject / Close visit API
                          final success = await controller.rejectVisit(
                            visitId: visit.id,
                          );

                          if (success) {
                            /// Controller already
                            /// refreshes owner visits.
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD32F2F),
                          side: const BorderSide(color: Color(0xFFD32F2F)),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          "Reject".tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  /// ACCEPT
                  Expanded(
                    child: SizedBox(
                      height: 46.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          /// Close dialog
                          Get.back();

                          final success = await controller.acceptVisit(
                            visitId: visit.id,
                          );

                          if (success) {
                            /// Controller already
                            /// refreshes owner visits.
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          "Accept".tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      /// User can also tap outside to close.
      /// Change to false if you only want X to close.
      barrierDismissible: true,
    );
  }

  Widget _emptyView({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        if (selectedTab == 0) {
          return visitController.fetchOwnerVisits();
        }

        return visitController.fetchVisitorVisits();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 450.h,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 35.w),
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
                      child: Icon(icon, size: 30.sp, color: AppColors.primary),
                    ),

                    SizedBox(height: 18.h),

                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 7.h),

                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.5,
                        color: Colors.grey.shade600,
                      ),
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
