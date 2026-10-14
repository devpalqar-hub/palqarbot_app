import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/utils/stripe_checkout_helper.dart';
import 'package:villas_qatar/modules/PlansandFeatures/model/featured_palnmodel.dart';
import 'package:villas_qatar/modules/PlansandFeatures/services/plan_controller.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/propertylist/service/myproperties_listcontroller.dart';
import 'package:villas_qatar/modules/searchscreen/service/searchlist_screen.dart';
import 'package:villas_qatar/Core/utils/app_toast.dart';

class BoostPropertyScreen extends StatefulWidget {
  const BoostPropertyScreen({super.key});

  @override
  State<BoostPropertyScreen> createState() => _BoostPropertyScreenState();
}

class _BoostPropertyScreenState extends State<BoostPropertyScreen> {
  static const Color primaryColor = Color(0xff9E123F);

  static const Color backgroundColor = Color(0xffFAFAFA);

  late final FeaturedPlanController planController;

  late final MyPropertyController propertyController;

  Property? selectedProperty;

  @override
  void initState() {
    super.initState();

    // BOOST PLANS
    planController = Get.isRegistered<FeaturedPlanController>()
        ? Get.find<FeaturedPlanController>()
        : Get.put(FeaturedPlanController());

    // MY PROPERTIES
    propertyController = Get.isRegistered<MyPropertyController>()
        ? Get.find<MyPropertyController>()
        : Get.put(MyPropertyController());

    // Fetch all user's properties
    WidgetsBinding.instance.addPostFrameCallback((_) {
      propertyController.fetchProperties();
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,

        leadingWidth: 56.w,

        leading: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: IconButton(
            onPressed: Get.back,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 19.sp,
              color: const Color(0xff222222),
            ),
          ),
        ),

        title: Text(
          "Boost Property".tr,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xff1F1F1F),
          ),
        ),

        centerTitle: true,

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xffEEEEEE)),
        ),
      ),

      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),

                    SizedBox(height: 24.h),

                    _sectionTitle(
                      "Select Property".tr,
                      subtitle: "Choose the property you want to promote".tr,
                      step: "1",
                    ),

                    SizedBox(height: 12.h),

                    _buildMyProperties(),

                    SizedBox(height: 26.h),

                    _sectionTitle(
                      "Choose Boost Plan".tr,
                      subtitle: "Select how you want to promote your listing".tr,
                      step: "2",
                    ),

                    SizedBox(height: 12.h),

                    GetBuilder<FeaturedPlanController>(
                      builder: (controller) {
                        if (controller.isLoading) {
                          return _buildLoadingBox("Loading boost plans...".tr);
                        }

                        if (controller.error.isNotEmpty) {
                          return _buildPlanError(controller);
                        }

                        if (controller.plans.isEmpty) {
                          return _buildEmptyPlans();
                        }

                        return Column(
                          children: List.generate(controller.plans.length, (
                            index,
                          ) {
                            final plan = controller.plans[index];

                            return Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: _buildPlanCard(
                                plan: plan,
                                controller: controller,
                              ),
                            );
                          }),
                        );
                      },
                    ),

                    SizedBox(height: 8.h),

                    _buildSecurePaymentInfo(),
                  ],
                ),
              ),
            ),

            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xffECECEC)),
      ),

      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,

            decoration: BoxDecoration(
              color: primaryColor.withOpacity(.08),
              borderRadius: BorderRadius.circular(12.r),
            ),

            child: Icon(
              Icons.rocket_launch_rounded,
              color: primaryColor,
              size: 22.sp,
            ),
          ),

          SizedBox(width: 13.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reach more buyers".tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff222222),
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  "Boost your property to increase visibility and get more enquiries."
                      .tr,
                  style: TextStyle(
                    fontSize: 10.sp,
                    height: 1.45,
                    color: const Color(0xff777777),
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
  // SECTION TITLE
  // ============================================================
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
            color: primaryColor,
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

  // ============================================================
  // MY PROPERTIES
  // ============================================================
  Widget _buildMyProperties() {
    return GetBuilder<MyPropertyController>(
      builder: (controller) {
        if (controller.isLoading && controller.properties.isEmpty) {
          return _buildLoadingBox("Loading your properties...".tr);
        }

        if (controller.error.isNotEmpty && controller.properties.isEmpty) {
          return _buildMessageBox(
            icon: Icons.error_outline_rounded,
            title: "Couldn't load properties".tr,
            message: "Please check your connection and try again.".tr,
            buttonText: "Try Again".tr,
            onPressed: controller.fetchProperties,
          );
        }

        if (controller.properties.isEmpty) {
          return _buildMessageBox(
            icon: Icons.home_work_outlined,
            title: "No properties found".tr,
            message: "Add a property before creating a boost.".tr,
          );
        }

        final properties = controller.properties;

        selectedProperty ??= properties.first;

        return Column(
          children: [
            ...List.generate(properties.length, (index) {
              final property = properties[index];

              final selected = selectedProperty?.id == property.id;

              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),

                child: _buildCompactPropertyCard(
                  property: property,
                  selected: selected,

                  onTap: () {
                    setState(() {
                      selectedProperty = property;
                    });
                  },
                ),
              );
            }),

            if (controller.hasMore)
              SizedBox(
                width: double.infinity,
                height: 42.h,

                child: OutlinedButton(
                  onPressed: controller.isLoadingMore
                      ? null
                      : () {
                          controller.fetchProperties(loadMore: true);
                        },

                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,

                    side: BorderSide(color: primaryColor.withOpacity(.3)),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                  ),

                  child: controller.isLoadingMore
                      ? SizedBox(
                          width: 17.w,
                          height: 17.w,

                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        )
                      : Text(
                          "Load more properties".tr,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCompactPropertyCard({
    required Property property,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final String imageUrl = _getPropertyImage(property);

    final String propertyName = property.propertyName?.toString() ?? "Property".tr;

    final String location = _getPropertyLocation(property);

    final String price = _getPropertyPrice(property);

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          width: double.infinity,

          padding: EdgeInsets.all(9.w),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(14.r),

            border: Border.all(
              color: selected ? primaryColor : const Color(0xffEAEAEA),
              width: selected ? 1.4 : 1,
            ),
          ),

          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),

                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 66.w,
                        height: 66.w,
                        fit: BoxFit.cover,

                        errorBuilder: (_, __, ___) => _smallPlaceholder(),
                      )
                    : _smallPlaceholder(),
              ),

              SizedBox(width: 11.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      propertyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff222222),
                      ),
                    ),

                    SizedBox(height: 5.h),

                    if (location.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.sp,
                            color: const Color(0xff888888),
                          ),

                          SizedBox(width: 3.w),

                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: TextStyle(
                                fontSize: 9.sp,
                                color: const Color(0xff777777),
                              ),
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 7.h),

                    Text(
                      price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              AnimatedContainer(
                duration: const Duration(milliseconds: 180),

                width: 24.w,
                height: 24.w,

                decoration: BoxDecoration(
                  color: selected ? primaryColor : Colors.white,

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: selected ? primaryColor : const Color(0xffCCCCCC),
                    width: 1.3,
                  ),
                ),

                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        size: 14.sp,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallPlaceholder() {
    return Container(
      width: 66.w,
      height: 66.w,

      color: const Color(0xffF2F2F2),

      alignment: Alignment.center,

      child: Icon(
        Icons.home_work_outlined,
        size: 23.sp,
        color: const Color(0xffBBBBBB),
      ),
    );
  }

  // ============================================================
  // PROPERTY HELPERS
  // ============================================================

  String _getPropertyImage(dynamic property) {
    try {
      if (property.images != null && property.images.isNotEmpty) {
        final dynamic first = property.images.first;

        /// If images is List<String>
        if (first is String) {
          return first;
        }

        /// If image object contains url.
        try {
          return first.url?.toString() ?? "";
        } catch (_) {
          return first.toString();
        }
      }
    } catch (_) {}

    return "";
  }

  String _getPropertyLocation(dynamic property) {
    try {
      final dynamic value = property.location;

      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final dynamic value = property.address;

      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    } catch (_) {}

    return "";
  }

  String _getPropertyPrice(dynamic property) {
    try {
      final dynamic value = property.price;

      if (value != null) {
        return "${"QAR".tr} $value";
      }
    } catch (_) {}

    return "Price not available".tr;
  }

  // ============================================================
  // COMPACT PLAN CARD
  // ============================================================
  Widget _buildPlanCard({
    required FeaturedPlanModel plan,
    required FeaturedPlanController controller,
  }) {
    final bool selected = controller.isPlanSelected(plan);

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: () {
          controller.selectPlan(plan);
        },

        borderRadius: BorderRadius.circular(14.r),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          width: double.infinity,

          padding: EdgeInsets.all(12.w),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(14.r),

            border: Border.all(
              color: selected ? primaryColor : const Color(0xffEAEAEA),
              width: selected ? 1.4 : 1,
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,

                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(.07),

                  borderRadius: BorderRadius.circular(11.r),
                ),

                child: Icon(
                  _getPlanIcon(plan),
                  color: primaryColor,
                  size: 20.sp,
                ),
              ),

              SizedBox(width: 11.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.name,

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff222222),
                            ),
                          ),
                        ),

                        if (plan.isHomePage)
                          Container(
                            margin: EdgeInsets.only(left: 6.w),

                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 3.h,
                            ),

                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(.07),

                              borderRadius: BorderRadius.circular(6.r),
                            ),

                            child: Text(
                              "POPULAR".tr,
                              style: TextStyle(
                                fontSize: 6.5.sp,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 6.h),

                    Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 12.sp,
                          color: const Color(0xff888888),
                        ),

                        SizedBox(width: 4.w),

                        Text(
                          plan.formattedDuration,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: const Color(0xff777777),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10.w),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.formattedPrice,

                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),

                  SizedBox(height: 7.h),

                  Container(
                    width: 22.w,
                    height: 22.w,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: selected ? primaryColor : Colors.white,

                      border: Border.all(
                        color: selected
                            ? primaryColor
                            : const Color(0xffCCCCCC),
                      ),
                    ),

                    child: selected
                        ? Icon(
                            Icons.check_rounded,
                            size: 13.sp,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPlanIcon(FeaturedPlanModel plan) {
    if (plan.location.toUpperCase() == "HOME_PAGE") {
      return Icons.home_rounded;
    }

    if (plan.durationDays >= 14) {
      return Icons.diamond_outlined;
    }

    if (plan.durationDays >= 7) {
      return Icons.workspace_premium_outlined;
    }

    return Icons.rocket_launch_outlined;
  }

  // ============================================================
  // PLAN ERROR
  // ============================================================

  Widget _buildPlanError(FeaturedPlanController controller) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12.r),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, color: primaryColor, size: 28.sp),

          SizedBox(height: 8.h),

          Text(
            "Unable to load boost plans".tr,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          ),

          SizedBox(height: 4.h),

          Text(
            controller.error,
            textAlign: TextAlign.center,

            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
          ),

          SizedBox(height: 10.h),

          OutlinedButton(
            onPressed: () {
              controller.retry();
            },
            child: Text("Try Again".tr),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY PLANS
  // ============================================================

  Widget _buildEmptyPlans() {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 16.w),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12.r),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          Icon(Icons.rocket_launch_outlined, size: 30.sp, color: Colors.grey),

          SizedBox(height: 8.h),

          Text(
            "No boost plans available".tr,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 3.h),

          Text(
            "Please check again later.".tr,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECURE PAYMENT
  // ============================================================
  Widget _buildSecurePaymentInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 13.sp,
            color: const Color(0xff777777),
          ),

          SizedBox(width: 5.w),

          Text(
            "Secure payment powered by Stripe".tr,
            style: TextStyle(fontSize: 9.sp, color: const Color(0xff777777)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _buildBottomBar() {
    return GetBuilder<FeaturedPlanController>(
      builder: (controller) {
        final FeaturedPlanModel? plan = controller.selectedPlan;

        if (controller.isLoading || plan == null) {
          return const SizedBox.shrink();
        }

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
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total".tr,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: const Color(0xff777777),
                        ),
                      ),

                      SizedBox(height: 2.h),

                      Text(
                        plan.formattedPrice,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),

                      Text(
                        plan.formattedDuration,
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: const Color(0xff888888),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 16.w),

                SizedBox(
                  height: 48.h,
                  width: 190.w,

                  child: ElevatedButton(
                    onPressed: controller.isCheckoutLoading
                        ? null
                        : () {
                            _continueToPayment(plan);
                          },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,

                      foregroundColor: Colors.white,

                      disabledBackgroundColor: primaryColor.withOpacity(.6),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),

                    child: controller.isCheckoutLoading
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Continue".tr,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              SizedBox(width: 7.w),

                              Icon(Icons.arrow_forward_rounded, size: 17.sp),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CONTINUE TO PAYMENT
  // ============================================================
  Widget _buildLoadingBox(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xffEAEAEA)),
      ),

      child: Column(
        children: [
          SizedBox(
            width: 22.w,
            height: 22.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: primaryColor,
            ),
          ),

          SizedBox(height: 10.h),

          Text(
            message,
            style: TextStyle(fontSize: 10.sp, color: const Color(0xff777777)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBox({
    required IconData icon,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(20.w),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xffEAEAEA)),
      ),

      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 28.sp),

          SizedBox(height: 9.h),

          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff222222),
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5.sp,
              height: 1.4,
              color: const Color(0xff777777),
            ),
          ),

          if (buttonText != null && onPressed != null) ...[
            SizedBox(height: 12.h),

            OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor.withOpacity(.3)),
              ),
              child: Text(buttonText),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _continueToPayment(FeaturedPlanModel plan) async {
    if (selectedProperty == null) {
      AppToast.show(
        msg: "Please select a property to boost".tr,
      );

      return;
    }

    final String listingId = selectedProperty!.id.toString();

    final String planId = plan.id;

    debugPrint("========== BOOST CHECKOUT ==========");

    debugPrint("Listing ID: $listingId");

    debugPrint("Plan ID: $planId");

    debugPrint("Plan Name: ${plan.name}");

    debugPrint("Price: ${plan.formattedPrice}");

    debugPrint("Duration: ${plan.formattedDuration}");

    /// Stripe API request:
    ///
    /// POST /api/featured/checkout
    ///
    /// BODY:
    ///
    /// {
    ///   "listingId": listingId,
    ///   "planId": planId
    /// }

    try {
      final BoostCheckoutSession session = await planController.checkout(
        listingId: listingId,
        planId: planId,
      );

      final StripePaymentOutcome outcome = await StripeCheckoutHelper.pay(
        clientSecret: session.paymentIntentClientSecret,
      );

      switch (outcome) {
        case StripePaymentOutcome.success:
          AppToast.show(
            msg: "${plan.name} has been activated for your property.".tr,
          );

          Get.back();

          break;

        case StripePaymentOutcome.cancelled:
          AppToast.show(
            msg: "You can try again anytime.".tr,
          );

          break;
      }
    } catch (e) {
      AppToast.show(
        msg: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }
}
