import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/Core/widgets/motion/fade_slide_in.dart';

import 'package:villas_qatar/modules/PlansandFeatures/model/featured_property_model.dart';
import 'package:villas_qatar/modules/PlansandFeatures/services/FeaturedPropertiesController.dart';
import 'package:villas_qatar/modules/home/widgets/property_card.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/boost_plan_bottomsheet.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/bottom_actioncard.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_content_sections.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_header_widgets.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_hero_gallery.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_listed_by_card.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_states.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_tokens.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_top_bar.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/property_insights_bottomsheet.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/propertylist/service/myproperties_listcontroller.dart';
import 'package:villas_qatar/modules/propertylist/views/add_listproperty.dart';

import 'package:villas_qatar/modules/searchscreen/service/searchlist_screen.dart';
import 'package:villas_qatar/modules/support/service/support_ticket_controller.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class PropertyDetailsScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  late final PropertySearchController controller;

  late final FeaturedPropertiesController featuredController;

  final ScrollController featuredScrollController = ScrollController();
  late final String propertyId;

  /// Page scroll position - drives the top bar's glass -> solid transition
  /// without rebuilding the whole page on every scroll tick.
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();

    controller = Get.find<PropertySearchController>();
    featuredController = Get.isRegistered<FeaturedPropertiesController>()
        ? Get.find<FeaturedPropertiesController>()
        : Get.put(FeaturedPropertiesController());

    propertyId = widget.propertyId;

    debugPrint("DETAIL SCREEN PROPERTY ID: $propertyId");

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        _scrollOffset.value = _scrollController.offset;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String id = propertyId.trim();

      if (id.isEmpty) {
        debugPrint("ERROR: Property ID is empty");
      } else {
        controller.fetchPropertyDetails(id);
      }

      // featuredController.fetchFeaturedProperties(
      //   location: FeaturedLocation.propertyDetailPage,
      //   limit: 5,
      // );
    });
  }

  @override
  void dispose() {
    featuredScrollController.dispose();
    _scrollController.dispose();
    _scrollOffset.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PropertySearchController>(
      builder: (controller) {
        if (controller.isDetailsLoading) {
          return const PdLoadingSkeleton();
        }

        if (controller.selectedProperty == null) {
          return const PdNotFoundState();
        }

        final Property property = controller.selectedProperty!;

        final String issue =
            (property.latestReview?.message.trim().isNotEmpty ?? false)
            ? property.latestReview!.message
            : (property.rejectionReason?.trim().isNotEmpty ?? false)
            ? property.rejectionReason!
            : "No review message available".tr;

        final String loggedInUserId = StorageService.getUserId();

        final String propertyOwnerId = property.createdBy.id.toString().trim();

        final bool isMyProperty =
            loggedInUserId.isNotEmpty &&
            propertyOwnerId.isNotEmpty &&
            loggedInUserId == propertyOwnerId;

        final double topInset = MediaQuery.paddingOf(context).top;
        final double heroHeight = 340.h + topInset;
        final double solidFrom = heroHeight - topInset - 56 - 40.h;

        // Every section is listed here in reading order; sections with
        // nothing to show are simply left out so spacing stays even.
        final List<Widget> sections = [
          if (isMyProperty && property.status.toUpperCase() == "REJECTED")
            PdRejectionBanner(
              issue: issue,
              onEdit: () {
                Get.to(
                  () =>
                      ListYourPropertyScreen(property: property, isEdit: true),
                );
              },
            ),
          PdHeadline(property: property),
          PdPriceConsole(
            property: property,
            isMyProperty: isMyProperty,
            onInsights: () => _onViewInsights(property),
            onBoost: () => _onBoostProperty(property),
          ),
          PdStatsStrip(property: property),
          if (property.description.trim().isNotEmpty)
            PdOverviewSection(property: property),
          if (property.amenities.isNotEmpty || property.nearbyTags.isNotEmpty)
            PdFeaturesSection(property: property),
          PdSpecsSection(property: property),
          if (property.otherFeatures.trim().isNotEmpty)
            PdOtherFeaturesSection(property: property),
          PdLocationSection(property: property),
          PdListedByCard(property: property, isMyProperty: isMyProperty),
          PdCompareSection(property: property),
        ];

        return Scaffold(
          backgroundColor: PD.canvas,

          bottomNavigationBar: _buildBottomSection(
            property: property,
            isMyProperty: isMyProperty,
          ),

          // Light status-bar icons over the photo, dark ones once the top
          // bar has turned solid white.
          body: ValueListenableBuilder<double>(
            valueListenable: _scrollOffset,
            builder: (BuildContext context, double offset, Widget? page) {
              final bool barIsSolid = offset > solidFrom + 35;

              return AnnotatedRegion<SystemUiOverlayStyle>(
                value:
                    (barIsSolid
                            ? SystemUiOverlayStyle.dark
                            : SystemUiOverlayStyle.light)
                        .copyWith(statusBarColor: Colors.transparent),
                child: page!,
              );
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PdHeroGallery(property: property, height: heroHeight),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 28.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < sections.length; i++)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: i == 0 ? 0 : 14.h,
                                ),
                                child: FadeSlideIn(
                                  delay: Duration(
                                    milliseconds: 50 * (i > 6 ? 6 : i),
                                  ),
                                  child: sections[i],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PdTopBar(
                    scrollOffset: _scrollOffset,
                    solidFrom: solidFrom,
                    property: property,
                    isMyProperty: isMyProperty,
                    onReport: () => _showReportListingSheet(property),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection({
    required Property property,
    required bool isMyProperty,
  }) {
    /// OTHER USER'S PROPERTY
    if (!isMyProperty) {
      return BottomActionCard(property: property);
    }

    /// Check whether property is already sold
    final bool isSold = property.status.trim().toUpperCase() == "SOLD";

    return PdBottomBarShell(
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: DecoratedBox(
          decoration: BoxDecoration(
            /// Normal = brand gradient, Sold = red
            gradient: isSold ? null : AppColors.ctaGradient,
            color: isSold ? const Color(0xFFD32F2F) : null,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: (isSold ? const Color(0xFFD32F2F) : AppColors.primary)
                    .withValues(alpha: .40),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            /// Disable button after SOLD
            onPressed: isSold ? null : () => _onMarkAsSold(property),

            style: ElevatedButton.styleFrom(
              /// Transparent so the DecoratedBox gradient shows through -
              /// including when disabled (Flutter would otherwise grey it).
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSold ? Icons.check_circle_rounded : Icons.sell_outlined,
                  size: 19.sp,
                ),

                SizedBox(width: 8.w),

                Text(
                  isSold ? "Sold".tr : "Mark as Sold".tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onMarkAsSold(dynamic property) {
    final String propertyId = property.id?.toString().trim() ?? "";

    if (propertyId.isEmpty) {
      AppToast.show(msg: "Property ID is missing..".tr);
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ICON
              Container(
                width: 58.w,
                height: 58.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.sell_outlined,
                    color: AppColors.primary,
                    size: 27.sp,
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              /// TITLE
              Text(
                "Mark as Sold".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F1F1F),
                ),
              ),

              SizedBox(height: 9.h),

              /// DESCRIPTION
              Text(
                "Are you sure you want to mark this property as sold?".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF777777),
                  height: 1.5,
                ),
              ),

              SizedBox(height: 6.h),

              /// INFO MESSAGE
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 10.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 17.sp,
                      color: const Color(0xFF777777),
                    ),

                    SizedBox(width: 8.w),

                    Expanded(
                      child: Text(
                        "This property will be updated as sold and will no longer be available as an active listing"
                            .tr,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF666666),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 22.h),

              Row(
                children: [
                  /// CANCEL
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 46.h,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF444444),
                          side: const BorderSide(color: Color(0xFFE2E2E2)),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          "Cancel".tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  /// MARK AS SOLD
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 46.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();

                          final MyPropertyController myPropertyController =
                              Get.isRegistered<MyPropertyController>()
                              ? Get.find<MyPropertyController>()
                              : Get.put(MyPropertyController());

                          final bool success = await myPropertyController
                              .markAsSold(propertyId);

                          if (success) {
                            await controller.fetchPropertyDetails(propertyId);

                            AppToast.show(
                              msg: "Property marked as sold successfully".tr,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.green.shade700,
                              textColor: Colors.white,
                              fontSize: 14.sp,
                            );
                          } else {
                            AppToast.show(
                              msg:
                                  myPropertyController
                                      .markAsSoldError
                                      .isNotEmpty
                                  ? myPropertyController.markAsSoldError
                                  : "Unable to mark property as sold".tr,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red.shade700,
                              textColor: Colors.white,
                              fontSize: 14.sp,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 17.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              "Mark as Sold".tr,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
      barrierDismissible: false,
    );
  }

  void _onBoostProperty(dynamic property) {
    final String id = property.id?.toString().trim() ?? '';
    if (id.isEmpty) {
      AppToast.show(msg: "Property ID is missing.".tr);
      return;
    }

    Get.bottomSheet(
      BoostPlanBottomSheet(propertyId: id),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.45),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _onViewInsights(Property property) {
    final String id = property.id.trim();

    Get.bottomSheet(
      PropertyInsightsBottomSheet(propertyId: id, insights: property.insights),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.45),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> _showReportListingSheet(Property property) async {
    final String listingId = property.id?.toString().trim() ?? '';

    /// CURRENT LOGGED-IN USER ID
    final String reportedUserId = StorageService.getUserId().trim();

    debugPrint("========== REPORT LISTING ==========");
    debugPrint("LISTING ID: $listingId");
    debugPrint("REPORTED USER ID: $reportedUserId");

    if (listingId.isEmpty) {
      AppToast.show(msg: "Property information is not available.".tr);
      return;
    }

    if (reportedUserId.isEmpty) {
      AppToast.show(
        msg: "Logged-in user information is not available.".tr,
      );
      return;
    }

    // Continue existing code...
    final SupportTicketController supportController =
        Get.isRegistered<SupportTicketController>()
        ? Get.find<SupportTicketController>()
        : Get.put(SupportTicketController(), permanent: false);

    final TextEditingController detailsController = TextEditingController();

    String? selectedReason;
    bool isSubmitting = false;

    final List<String> reasons = [
      "Incorrect listing information".tr,
      "Misleading or fake listing".tr,
      "Property is no longer available".tr,
      "Inappropriate content".tr,
      "Suspected scam or fraud".tr,
      "Other".tr,
    ];

    bool reportSubmitted = false;
    String? submitError;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.45),

      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final double keyboardHeight = MediaQuery.viewInsetsOf(
              context,
            ).bottom;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .88,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(22.r),
                  ),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ============================================
                    // HANDLE
                    // ============================================
                    SizedBox(height: 10.h),

                    Container(
                      width: 38.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D8D8),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),

                    // ============================================
                    // HEADER
                    // ============================================
                    Padding(
                      padding: EdgeInsets.fromLTRB(18.w, 12.h, 8.w, 10.h),
                      child: Row(
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.flag_outlined,
                              size: 20.sp,
                              color: const Color(0xFFD64545),
                            ),
                          ),

                          SizedBox(width: 11.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Report listing".tr,
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF222222),
                                  ),
                                ),

                                SizedBox(height: 2.h),

                                Text(
                                  "Tell us what's wrong with this property.".tr,
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    color: const Color(0xFF777777),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: isSubmitting
                                ? null
                                : () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();

                                    Navigator.of(sheetContext).pop();
                                  },
                            icon: Icon(
                              Icons.close_rounded,
                              size: 22.sp,
                              color: const Color(0xFF555555),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: Colors.grey.shade200),

                    // ============================================
                    // CONTENT
                    // ============================================
                    Flexible(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,

                        padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Why are you reporting this listing?".tr,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF292929),
                              ),
                            ),

                            SizedBox(height: 4.h),

                            Text(
                              "Choose the reason that best describes the issue."
                                  .tr,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: const Color(0xFF888888),
                              ),
                            ),

                            SizedBox(height: 14.h),

                            // ====================================
                            // REASONS
                            // ====================================
                            ...reasons.map((String reason) {
                              final bool isSelected = selectedReason == reason;

                              return Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: InkWell(
                                  onTap: isSubmitting
                                      ? null
                                      : () {
                                          setSheetState(() {
                                            selectedReason = reason;
                                          });
                                        },
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 13.w,
                                      vertical: 11.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(.05)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : const Color(0xFFE5E5E5),
                                        width: isSelected ? 1.2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            reason,
                                            style: TextStyle(
                                              fontSize: 11.5.sp,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: const Color(0xFF333333),
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 10.w),

                                        Icon(
                                          isSelected
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_off,
                                          size: 20.sp,
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),

                            SizedBox(height: 10.h),

                            // ====================================
                            // ADDITIONAL DETAILS
                            // ====================================
                            Row(
                              children: [
                                Text(
                                  "Additional details".tr,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF292929),
                                  ),
                                ),

                                SizedBox(width: 5.w),

                                Text(
                                  "(Optional)".tr,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8.h),

                            // ====================================
                            // TEXT FIELD
                            //
                            // NO CUSTOM FOCUS NODE
                            // ====================================
                            TextField(
                              controller: detailsController,

                              enabled: !isSubmitting,

                              minLines: 3,
                              maxLines: 5,
                              maxLength: 500,

                              textCapitalization: TextCapitalization.sentences,

                              keyboardType: TextInputType.multiline,

                              textInputAction: TextInputAction.newline,

                              decoration: InputDecoration(
                                hintText:
                                    "Provide additional information that may help us review this listing."
                                        .tr,

                                hintStyle: TextStyle(
                                  fontSize: 10.5.sp,
                                  height: 1.4,
                                  color: Colors.grey.shade500,
                                ),

                                filled: true,

                                fillColor: const Color(0xFFFAFAFA),

                                counterStyle: TextStyle(
                                  fontSize: 9.sp,
                                  color: Colors.grey.shade500,
                                ),

                                contentPadding: EdgeInsets.all(13.w),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E5E5),
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 1.2,
                                  ),
                                ),

                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E5E5),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 8.h),

                            // ====================================
                            // INFO
                            // ====================================
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(11.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(9.r),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 16.sp,
                                    color: const Color(0xFF777777),
                                  ),

                                  SizedBox(width: 8.w),

                                  Expanded(
                                    child: Text(
                                      "Reports are reviewed by our support team."
                                          .tr,
                                      style: TextStyle(
                                        fontSize: 9.5.sp,
                                        height: 1.45,
                                        color: const Color(0xFF777777),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ============================================
                    // SUBMIT BUTTON
                    // ============================================
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(18.w, 11.h, 18.w, 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 46.h,
                        child: ElevatedButton(
                          onPressed: selectedReason == null || isSubmitting
                              ? null
                              : () async {
                                  // ==========================
                                  // REMOVE KEYBOARD
                                  // ==========================

                                  FocusManager.instance.primaryFocus?.unfocus();

                                  final String subject = selectedReason!;

                                  final String details = detailsController.text
                                      .trim();

                                  final String message = details.isNotEmpty
                                      ? details
                                      : subject;

                                  setSheetState(() {
                                    isSubmitting = true;
                                  });

                                  try {
                                    final result = await supportController
                                        .createTicket(
                                          category:
                                              SupportCategory.reportListing,
                                          subject: subject,
                                          message: message,
                                          listingId: listingId,
                                          reportedUserId: reportedUserId,
                                        );

                                    if (!sheetContext.mounted) {
                                      return;
                                    }

                                    if (result != null) {
                                      reportSubmitted = true;

                                      Navigator.of(sheetContext).pop();

                                      return;
                                    }

                                    submitError =
                                        supportController.createError.isNotEmpty
                                        ? supportController.createError
                                        : "Unable to submit report".tr;

                                    if (sheetContext.mounted) {
                                      setSheetState(() {
                                        isSubmitting = false;
                                      });
                                    }
                                  } catch (e) {
                                    submitError = e.toString().replaceFirst(
                                      'Exception: '.tr,
                                      '',
                                    );

                                    if (sheetContext.mounted) {
                                      setSheetState(() {
                                        isSubmitting = false;
                                      });
                                    }
                                  }
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,

                            disabledBackgroundColor: AppColors.primary
                                .withOpacity(.35),

                            foregroundColor: Colors.white,

                            disabledForegroundColor: Colors.white,

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),

                          child: isSubmitting
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Submit Report".tr,
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // ============================================================
    // IMPORTANT:
    // At this point bottom sheet is closed.
    //
    // Do NOT manually dispose a FocusNode because there isn't one.
    // ============================================================

    if (!mounted) {
      return;
    }

    // Give Flutter one frame to completely remove
    // the bottom-sheet route / keyboard dependencies.
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (!mounted) {
      return;
    }

    if (reportSubmitted) {
      AppToast.show(
        msg: "Thank you. Our support team will review this listing.".tr,
        backgroundColor: Colors.green.shade700,
        textColor: Colors.white,
      );
    } else if (submitError != null && submitError!.isNotEmpty) {
      AppToast.show(
        msg: submitError!,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }

    // Do not manually dispose the TextEditingController here.
    // It is local to this short-lived modal and avoiding disposal
    // prevents pending EditableText callbacks from accessing a
    // disposed controller during route teardown.
  }

  // ============================================================
  // REPORT REASON TILE
  // ============================================================

  Widget _buildReportReason({
    required String title,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE5E5E5),
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20.sp,
                color: selected ? AppColors.primary : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // THIS closes _PropertyDetailsScreenState
}
