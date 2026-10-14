import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/utils/app_transitions.dart';
import 'package:villas_qatar/modules/PlansandFeatures/model/myfeatured_property.dart';
import 'package:villas_qatar/modules/PlansandFeatures/services/FeaturedPropertiesController.dart';
import 'package:villas_qatar/modules/PlansandFeatures/services/receipt_pdf_service.dart';
import 'package:villas_qatar/modules/propertydetailscreen/propertydetailscreen.dart';
import 'package:villas_qatar/Core/utils/app_toast.dart';

class MyFeaturedPropertiesScreen extends StatefulWidget {
  const MyFeaturedPropertiesScreen({
    super.key,
  });

  @override
  State<MyFeaturedPropertiesScreen> createState() =>
      _MyFeaturedPropertiesScreenState();
}

class _MyFeaturedPropertiesScreenState
    extends State<MyFeaturedPropertiesScreen> {
  late final FeaturedPropertiesController controller;

  final TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    controller =
        Get.isRegistered<FeaturedPropertiesController>()
            ? Get.find<FeaturedPropertiesController>()
            : Get.put(
                FeaturedPropertiesController(),
              );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        controller.getMyFeaturedProperties();
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        
        title: Text(
          'My Featured'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF202020),
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: GetBuilder<FeaturedPropertiesController>(
        builder: (controller) {
          final List<MyFeaturedProperty> entries =
              controller.filteredMyFeaturedProperties;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh:
                controller.refreshMyFeaturedProperties,
            child: CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ==================================================
                // SEARCH + HEADER
                // ==================================================

                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      10.h,
                      16.w,
                      18.h,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ==========================================
                        // SEARCH
                        // ==========================================

                        TextField(
                          controller: searchController,
                          onChanged: controller
                              .searchMyFeaturedProperties,
                          textInputAction:
                              TextInputAction.search,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color:
                                const Color(0xFF222222),
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Search featured properties'.tr,
                               
                            hintStyle: TextStyle(
                              fontSize: 13.sp,
                              color:
                                  Colors.grey.shade500,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              size: 21.sp,
                              color:
                                  Colors.grey.shade500,
                            ),

                            suffixIcon: controller
                                    .myFeaturedPropertiesSearch
                                    .isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      searchController
                                          .clear();

                                      controller
                                          .clearMyFeaturedPropertiesSearch();
                                    },
                                    icon: Icon(
                                      Icons.close_rounded,
                                      size: 19.sp,
                                      color: Colors
                                          .grey.shade600,
                                    ),
                                  )
                                : null,

                            filled: true,
                            fillColor:
                                const Color(0xFFF7F7F9),

                            contentPadding:
                                EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),

                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                10.r,
                              ),
                              borderSide:
                                  BorderSide.none,
                            ),

                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                10.r,
                              ),
                              borderSide: BorderSide(
                                color:
                                    Colors.grey.shade200,
                              ),
                            ),

                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12.r,
                              ),
                              borderSide:
                                  const BorderSide(
                                color:
                                    AppColors.primary,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 18.h),

                        // ==========================================
                        // TITLE + COUNT
                        // ==========================================

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    'Featured Plans'.tr,

                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight:
                                          FontWeight.w500,
                                      color:
                                          const Color(
                                        0xFF202020,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 3.h),

                                  Text(
                                    'Manage your active and past featured property plans'.tr,

                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: Colors
                                          .grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (!controller
                                .isMyFeaturedPropertiesLoading)
                              Container(
                                padding:
                                    EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: AppColors
                                      .primary
                                      .withOpacity(.07),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20.r,
                                  ),
                                ),
                                child: Text(
                                  '${entries.length} '
                                  '${entries.length == 1 ? 'Property'.tr : 'Properties'.tr}',
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    fontWeight:
                                        FontWeight.w600,
                                    color:
                                        AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // LOADING
                // ==================================================

                if (controller
                        .isMyFeaturedPropertiesLoading &&
                    controller
                        .myFeaturedProperties.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildLoading(),
                  )

                // ==================================================
                // ERROR
                // ==================================================

                else if (controller
                        .myFeaturedPropertiesError
                        .isNotEmpty &&
                    controller
                        .myFeaturedProperties.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child:
                        _buildError(controller),
                  )

                // ==================================================
                // EMPTY
                // ==================================================

                else if (entries.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child:
                        _buildEmpty(controller),
                  )

                // ==================================================
                // LIST
                // ==================================================

                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      16.h,
                      16.w,
                      30.h,
                    ),
                    sliver: SliverList(
                      delegate:
                          SliverChildBuilderDelegate(
                        (
                          context,
                          index,
                        ) {
                          final MyFeaturedProperty
                              entry =
                              entries[index];

                          return Padding(
                            padding:
                                EdgeInsets.only(
                              bottom: 14.h,
                            ),
                            child:
                                _FeaturedEntryCard(
                              entry: entry,
                            ),
                          );
                        },
                        childCount:
                            entries.length,
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
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: AppColors.primary,
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
    FeaturedPropertiesController controller,
  ) {
    return Center(
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color:
                    AppColors.primary.withOpacity(.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 32.sp,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: 18.h),

            Text(
              'Unable to load featured properties'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF222222),
              ),
            ),

            SizedBox(height: 7.h),

            Text(
              controller.myFeaturedPropertiesError,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),

            SizedBox(height: 18.h),

            ElevatedButton(
              onPressed:
                  controller.refreshMyFeaturedProperties,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Try Again'.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty(
    FeaturedPropertiesController controller,
  ) {
    final bool searching = controller
        .myFeaturedPropertiesSearch.isNotEmpty;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76.w,
              height: 76.w,
              decoration: BoxDecoration(
                color:
                    AppColors.primary.withOpacity(.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                searching
                    ? Icons.search_off_rounded
                    : Icons
                        .workspace_premium_outlined,
                size: 34.sp,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: 17.h),

            Text(
              searching
                  ? 'No matching properties found'.tr
                  : 'No featured properties available'
                      .tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF222222),
              ),
            ),

            SizedBox(height: 7.h),

            Text(
              searching
                  ? 'Try searching with another property name'
                      .tr
                  : 'Your featured properties will appear here'
                      .tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.5,
                color: Colors.grey.shade500,
              ),
            ),

            if (searching) ...[
              SizedBox(height: 14.h),

              TextButton(
                onPressed: () {
                  searchController.clear();

                  controller
                      .clearMyFeaturedPropertiesSearch();
                },
                child: Text(
                  'Clear Search'.tr,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FEATURED ENTRY CARD
//
// ONE CARD PER FEATURED-PROPERTY PURCHASE:
// PLAN NAME + STATUS, PROPERTY NAME LINK, THEN
// LOCATION / START DATE / END DATE / AMOUNT PAID ROWS.
// ============================================================

class _FeaturedEntryCard extends StatefulWidget {
  final MyFeaturedProperty entry;

  const _FeaturedEntryCard({
    required this.entry,
  });

  @override
  State<_FeaturedEntryCard> createState() =>
      _FeaturedEntryCardState();
}

class _FeaturedEntryCardState extends State<_FeaturedEntryCard> {
  bool _isDownloadingReceipt = false;

  MyFeaturedProperty get entry => widget.entry;

  // ============================================================
  // DOWNLOAD RECEIPT
  //
  // GENERATES THE RECEIPT PDF AND OPENS THE SHARE SHEET SO THE
  // USER CAN SAVE / SEND THE FILE.
  // ============================================================

  Future<void> _downloadReceipt() async {
    if (_isDownloadingReceipt) {
      return;
    }

    setState(() {
      _isDownloadingReceipt = true;
    });

    try {
      final bytes = await ReceiptPdfService.build(entry);

      final Directory dir = await getTemporaryDirectory();

      final String fileName =
          'VillasQatar_Receipt_${entry.receiptNumber.replaceAll('#', '')}.pdf';

      final File file = File('${dir.path}/$fileName');

      await file.writeAsBytes(bytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(file.path, mimeType: 'application/pdf'),
          ],
          subject: 'Villas Qatar Payment Receipt'.tr,
        ),
      );
    } catch (_) {
      if (mounted) {
        AppToast.show(
          msg: 'Unable to generate receipt. Please try again'.tr,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingReceipt = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = entry.listing;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFEBEBEF),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // PLAN NAME + STATUS
            // ==========================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    entry.plan.name.isNotEmpty
                        ? entry.plan.name
                        : 'Plan'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF202020),
                    ),
                  ),
                ),

                SizedBox(width: 8.w),

                _statusBadge(entry),
              ],
            ),

            SizedBox(height: 8.h),

            // ==========================================
            // PROPERTY NAME (TAPPABLE -> DETAIL PAGE)
            // ==========================================

            InkWell(
              onTap: entry.listingId.isEmpty
                  ? null
                  : () {
                      Get.to(
                        () => PropertyDetailsScreen(
                          propertyId: entry.listingId,
                        ),
                        transition: AppTransitions.forward,
                      );
                    },
              child: Row(
                children: [
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 13.sp,
                    color: AppColors.primary,
                  ),

                  SizedBox(width: 4.w),

                  Expanded(
                    child: Text(
                      listing.propertyName.isNotEmpty
                          ? listing.propertyName
                          : 'Property'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            Divider(
              height: 1,
              thickness: 1,
              color: const Color(0xFFEBEBEF),
            ),

            SizedBox(height: 10.h),

            // ==========================================
            // LOCATION / START / END / AMOUNT ROWS
            // ==========================================

            _infoRow(
              'Location'.tr,
              entry.locationLabel.isNotEmpty
                  ? entry.locationLabel
                  : '-',
            ),

            SizedBox(height: 8.h),

            _infoRow(
              'Start Date'.tr,
              entry.formattedStartDate,
            ),

            SizedBox(height: 8.h),

            _infoRow(
              'End Date'.tr,
              entry.formattedEndDate,
            ),

            SizedBox(height: 8.h),

            _infoRow(
              'Amount Paid'.tr,
              entry.formattedPaidAmount,
              valueColor: AppColors.primary,
            ),

            if (entry.isCurrentlyActive) ...[
              SizedBox(height: 8.h),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  entry.remainingDays > 0
                      ? '@count days left'.trParams({'count': '${entry.remainingDays}'})
                      : 'Ends today'.tr,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],

            SizedBox(height: 14.h),

            Divider(
              height: 1,
              thickness: 1,
              color: const Color(0xFFEBEBEF),
            ),

            SizedBox(height: 12.h),

            // ==========================================
            // DOWNLOAD RECEIPT
            // ==========================================

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isDownloadingReceipt
                    ? null
                    : _downloadReceipt,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF202020),
                  side: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                icon: _isDownloadingReceipt
                    ? SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        Icons.download_rounded,
                        size: 16.sp,
                      ),
                label: Text(
                  'Download Receipt'.tr,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LABEL (LEFT) / VALUE (RIGHT) ROW
  // ==========================================

  Widget _infoRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            color: Colors.grey.shade600,
          ),
        ),

        SizedBox(width: 8.w),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF202020),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(MyFeaturedProperty entry) {
    String text;
    Color color;

    if (entry.isExpired) {
      text = 'Expired'.tr;
      color = Colors.grey;
    } else if (entry.isCurrentlyActive) {
      text = 'Active'.tr;
      color = const Color(0xFF258A57);
    } else if (entry.isFailed) {
      text = 'Failed'.tr;
      color = Colors.red;
    } else if (entry.isPaid) {
      text = 'Paid'.tr;
      color = const Color(0xFF258A57);
    } else {
      text = entry.paymentStatusLabel.isNotEmpty
          ? entry.paymentStatusLabel
          : 'Pending'.tr;

      color = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text.tr,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}