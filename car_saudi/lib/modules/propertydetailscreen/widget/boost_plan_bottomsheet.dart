import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/utils/stripe_checkout_helper.dart';
import 'package:villas_qatar/modules/PlansandFeatures/model/featured_palnmodel.dart';
import 'package:villas_qatar/modules/PlansandFeatures/services/FeaturedPropertiesController.dart';
import 'package:villas_qatar/modules/PlansandFeatures/services/plan_controller.dart';
import 'package:villas_qatar/modules/propertylist/service/myproperties_listcontroller.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class BoostPlanBottomSheet extends StatefulWidget {
  final String propertyId;

  const BoostPlanBottomSheet({super.key, required this.propertyId});

  @override
  State<BoostPlanBottomSheet> createState() => _BoostPlanBottomSheetState();
}

class _BoostPlanBottomSheetState extends State<BoostPlanBottomSheet> {
  static const Color primaryColor = Color(0xff9E123F);

  late final FeaturedPlanController planController;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Guards against double-tapping "Continue" while a checkout is
  // already in flight - without this, a fast double tap fires two
  // POST /api/featured/checkout calls and, once both get paid,
  // produces two duplicate entries in "My Featured Properties" for
  // the same purchase.
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();

    planController = Get.isRegistered<FeaturedPlanController>()
        ? Get.find<FeaturedPlanController>()
        : Get.put(FeaturedPlanController());

    // If your FeaturedPlanController already
    // fetches plans inside onInit(), this is enough.
    //
    // Otherwise call your existing fetch method:
    //
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) {
    //     planController.fetchPlans();
    //   },
    // );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: BoxDecoration(
        color: const Color(0xffFAFAFA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // =====================================================
          // DRAG HANDLE
          // =====================================================
          SizedBox(height: 10.h),

          Container(
            width: 42.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xffD5D5D5),
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),

          // =====================================================
          // HEADER
          // =====================================================
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 10.w, 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Boost Property".tr,
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

          // =====================================================
          // FIXED CONTENT
          // =====================================================
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =============================================
                  // SECTION TITLE
                  // =============================================
                  _sectionTitle(
                    "Choose Boost Plan".tr,
                    subtitle: "Select how you want to promote your listing".tr,
                    step: "1",
                  ),

                  SizedBox(height: 14.h),

                  // =============================================
                  // SEARCH FIELD
                  // =============================================
                  _buildSearchField(),

                  SizedBox(height: 14.h),

                  // =============================================
                  // PLAN LIST
                  // ONLY THIS AREA SCROLLS
                  // =============================================
                  SizedBox(
                    height: 300.h,
                    child: GetBuilder<FeaturedPlanController>(
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

                        // Search locally through
                        // already loaded plans.
                        final query = searchQuery.trim().toLowerCase();

                        final filteredPlans = controller.plans.where((plan) {
                          if (query.isEmpty) {
                            return true;
                          }

                          final name = plan.name.toLowerCase();

                          final location = plan.location.toLowerCase();

                          final duration = plan.formattedDuration.toLowerCase();

                          final price = plan.formattedPrice.toLowerCase();

                          return name.contains(query) ||
                              location.contains(query) ||
                              duration.contains(query) ||
                              price.contains(query);
                        }).toList();

                        if (filteredPlans.isEmpty) {
                          return _buildNoSearchResults();
                        }

                        return Scrollbar(
                          thumbVisibility: filteredPlans.length > 3,
                          child: ListView.separated(
                            padding: EdgeInsets.only(right: 2.w, bottom: 4.h),
                            physics: const BouncingScrollPhysics(),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: filteredPlans.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10.h),
                            itemBuilder: (context, index) {
                              final plan = filteredPlans[index];

                              return _buildPlanCard(
                                plan: plan,
                                controller: controller,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // =============================================
                  // FIXED SECURE PAYMENT TEXT
                  // =============================================
                  _buildSecurePaymentInfo(),
                ],
              ),
            ),
          ),

          // =====================================================
          // FIXED BOTTOM BAR
          // =====================================================
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================
  Widget _buildSearchField() {
    return Container(
      height: 46.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xffE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,

        textInputAction: TextInputAction.search,

        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xff222222),
        ),

        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },

        decoration: InputDecoration(
          hintText: "Search boost plans".tr,

          hintStyle: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xff9A9A9A),
          ),

          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.sp,
            color: const Color(0xff777777),
          ),

          suffixIcon: searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    searchController.clear();

                    setState(() {
                      searchQuery = '';
                    });
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: const Color(0xff777777),
                  ),
                )
              : null,

          contentPadding: EdgeInsets.symmetric(vertical: 13.h),

          border: InputBorder.none,

          enabledBorder: InputBorder.none,

          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 23.sp,
                color: primaryColor,
              ),
            ),

            SizedBox(height: 10.h),

            Text(
              "No plans found".tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xff222222),
              ),
            ),

            SizedBox(height: 4.h),

            Text(
              "Try searching with another keyword".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5.sp,
                color: const Color(0xff888888),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
  // PLAN CARD
  // SAME UI AS YOUR BOOST SCREEN
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
  // SAME DESIGN AS EXISTING SCREEN
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
                    onPressed: _isProcessingPayment
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
                    child: _isProcessingPayment
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
  // LOADING
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
  // CONTINUE
  // PROPERTY ID COMES DIRECTLY FROM DETAILS PAGE
  // ============================================================
  //
  // POST /api/featured/checkout, then pay via Stripe's native
  // PaymentSheet (preferred) or the webview-hosted checkout page
  // fallback - same [StripeCheckoutHelper] used by the standalone
  // boost screen and the PENDING_PAYMENT "Pay" flow.

  Future<void> _continueToPayment(FeaturedPlanModel plan) async {
    if (_isProcessingPayment) {
      return;
    }

    final String listingId = widget.propertyId.trim();

    if (listingId.isEmpty) {
      AppToast.show(msg: "Property ID is missing.".tr);

      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    final String planId = plan.id;

    debugPrint("========== BOOST CHECKOUT ==========");

    debugPrint("Listing ID: $listingId");

    debugPrint("Plan ID: $planId");

    debugPrint("Plan Name: ${plan.name}");

    debugPrint("Price: ${plan.formattedPrice}");

    debugPrint("Duration: ${plan.formattedDuration}");

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
          // Close the sheet first - calling Get.back() after the
          // snackbar risked the snackbar's own overlay route eating
          // the pop instead of the bottom sheet's route.
          Get.back();

          AppToast.show(
            msg: "${plan.name} has been activated for your property.".tr,
          );

          // Refresh the controllers that show boost/featured state so
          // the "My Features" list and this property's card reflect
          // the purchase immediately instead of on next app open.

          if (Get.isRegistered<MyPropertyController>()) {
            Get.find<MyPropertyController>().fetchProperties(showLoader: false);
          }

          break;

        case StripePaymentOutcome.cancelled:
          AppToast.show(msg: "You can try again anytime.".tr);

          break;
      }
    } catch (e) {
      AppToast.show(msg: e.toString().replaceFirst("Exception: ", ""));
    } finally {
      // The sheet may already be closed/disposed by now on the
      // success path (Get.back() above) - only touch state if it's
      // still mounted.
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }
}
