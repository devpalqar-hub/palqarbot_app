import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/utils/app_transitions.dart';
import 'package:villas_qatar/Core/utils/stripe_checkout_helper.dart';
import 'package:villas_qatar/modules/propertydetailscreen/propertydetailscreen.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/propertylist/service/myproperties_listcontroller.dart';
import 'package:villas_qatar/modules/propertylist/widgets/filter_bottomsheet.dart';
import 'package:villas_qatar/modules/searchscreen/service/searchlist_screen.dart';

import 'add_listproperty.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final MyPropertyController controller =
      Get.isRegistered<MyPropertyController>()
      ? Get.find<MyPropertyController>()
      : Get.put(MyPropertyController());
  final ScrollController scrollController = ScrollController();

  String activeFilter = "All";

  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller.fetchProperties();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadingMore &&
          controller.hasMore) {
        controller.fetchProperties(loadMore: true);
      }
    });

    searchCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: GetBuilder<MyPropertyController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Property> listings = List.from(controller.properties);

          if (searchCtrl.text.trim().isNotEmpty) {
            final q = searchCtrl.text.trim().toLowerCase();

            listings = listings.where((e) {
              return e.propertyName.toLowerCase().contains(q) ||
                  e.areaName.toLowerCase().contains(q);
            }).toList();
          }

          /// FILTER

          // Compare against the untranslated key — `activeFilter` stores the
          // canonical filter value, not display text, so it must never be
          // compared against a `.tr`'d (locale-dependent) string.
          if (activeFilter != "All") {
            listings = listings.where((e) {
              return e.status.toLowerCase() == activeFilter.toLowerCase();
            }).toList();
          }

          return SafeArea(
            child: Column(
              children: [
                _buildTopBar(),

                _buildSearchBar(),

                const SizedBox(height: 4),

                Expanded(
                  child: listings.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: controller.refreshProperties,

                          child: listings.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(height: 120),
                                    _EmptyState(),
                                  ],
                                )
                              : ListView.separated(
                                  controller: scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),

                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    8,
                                    20,
                                    90,
                                  ),

                                  itemCount:
                                      listings.length +
                                      (controller.hasMore ? 1 : 0),

                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),

                                  itemBuilder: (context, index) {
                                    if (index == listings.length) {
                                      return const Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    return _PropertyCard(
                                      listing: listings[index],
                                      onTap: () async {
                                        final searchController =
                                            Get.isRegistered<
                                                    PropertySearchController>()
                                                ? Get.find<
                                                    PropertySearchController>()
                                                : Get.put(
                                                    PropertySearchController(),
                                                    permanent: true,
                                                  );

                                        await searchController
                                            .fetchPropertyDetails(
                                              listings[index].id,
                                            );

                                        Get.to(
                                          () => PropertyDetailsScreen(
                                            propertyId: listings[index].id,
                                          ),
                                          transition: AppTransitions.forward,
                                        );
                                      },
                                      onEdit: () {
                                        Get.to(
                                          () => ListYourPropertyScreen(
                                            property: listings[index],
                                            isEdit: true,
                                          ),
                                          transition: AppTransitions.forward,
                                        );
                                      },
                                      isPaying:
                                          controller.activatingPropertyId ==
                                          listings[index].id,
                                      onPay: () =>
                                          _handlePay(listings[index]),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(
            () => const ListYourPropertyScreen(),
            transition: AppTransitions.forward,
            duration: const Duration(milliseconds: 850),
            curve: Curves.easeOutCubic,
          );
        },

        backgroundColor: AppColors.primary,

        icon: const Icon(Icons.add, color: Colors.white),

        label: Text(
          "List Property".tr,
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          // Opened as a pushed screen (there is no bottom bar to leave by),
          // so it needs its own way back. Keeps the title centred by taking
          // the same width as the filter button on the other side.
          if (Navigator.of(context).canPop())
            IconButton(
              icon: const BackButtonIcon(),
              color: Colors.black87,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: Get.back,
            )
          else
            const SizedBox(width: 48),

          Expanded(
            child: Text(
              "My Properties".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primary),
            onPressed: () {
              showFilterBottomSheet(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Container(
        height: 42, // Reduce height (try 40-44)
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: TextField(
          controller: searchCtrl,
          onChanged: (_) => setState(() {}),
          style: TextStyle(fontSize: 12, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Search by property name or location'.tr,
            hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 12),
            prefixIcon: Icon(Icons.search, color: AppColors.hintGrey, size: 18),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ),
    );
  }

  /// ==========================================================
  /// PAY (PENDING_PAYMENT -> go live)
  /// ==========================================================
  ///
  /// POST /api/listings/make-payment. If free quota is available the
  /// backend activates the listing immediately at no charge.
  /// Otherwise it returns a Stripe PaymentIntent/Checkout Session,
  /// which [StripeCheckoutHelper] pays via the native PaymentSheet
  /// (preferred) or a webview fallback - same helper the featured/
  /// boost checkout flow uses.
  Future<void> _handlePay(Property listing) async {
    try {
      final result = await controller.makePayment(
        listing.id,
        successUrl: "villasqatar://listings/payment-success",
        failedUrl: "villasqatar://listings/payment-failed",
      );

      if (result.activated) {
        AppToast.show(
          msg: "${listing.propertyName} is now live.".tr,
        );
        return;
      }

      final StripePaymentOutcome outcome = await StripeCheckoutHelper.pay(
        clientSecret: result.paymentIntentClientSecret,
      );

      switch (outcome) {
        case StripePaymentOutcome.success:
          AppToast.show(
            msg: "${listing.propertyName} has been activated.".tr,
          );
          await controller.fetchProperties(showLoader: false);
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.pinkBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No properties found'.tr,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different search or filter, or list a new property'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.hintGrey, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Property listing;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onPay;
  final bool isPaying;

  const _PropertyCard({
    required this.listing,
    required this.onTap,
    required this.onEdit,
    this.onPay,
    this.isPaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(),
                const SizedBox(width: 12),
                Expanded(child: _buildInfo()),
              ],
            ),

            

            SizedBox(height: 10.h),
            Divider(height: 1, color: AppColors.fieldBorder),
            SizedBox(height: 5.h),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: listing.photos.isNotEmpty
              ? Image.network(
                  (listing.photos
                          .where((photo) => photo.sortOrder == 0)
                          .isNotEmpty
                      ? listing.photos
                            .firstWhere((photo) => photo.sortOrder == 0)
                            .url
                      : listing.photos.first.url),
                  width: 80.w,
                  height: 80.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return _placeholder();
                  },
                )
              : _placeholder(),
        ),

        Positioned(
          left: 6,
          bottom: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_camera, size: 10, color: Colors.white),
                const SizedBox(width: 3),
                Text(
                  "${listing.photos.length}",
                  style: TextStyle(color: Colors.white, fontSize: 8.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.home, color: Colors.white),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                listing.propertyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: Colors.black87,
                ),
              ),
            ),

            if (listing.status.toUpperCase() == "REJECTED")
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () => _showRejectedDialog(listing, onEdit),
              ),

            _StatusBadge(status: listing.status),
          ],
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 13,
              color: AppColors.hintGrey,
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                "${listing.areaName}, ${listing.municipality}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.hintGrey, fontSize: 10),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          "${"QAR".tr} ${_formatPrice(listing.price)}"
          "${listing.purpose == "RENT" ? " / month".tr : ""}",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  //------------------------------------------------------------------
  // DESCRIPTION (rendered from the quill rich-text HTML)
  //------------------------------------------------------------------

  /// Plain-text preview of [listing.description] with HTML tags stripped,
  /// used for the truncated in-card preview.
  String get _plainDescription => listing.description
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description".tr,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          _plainDescription,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.hintGrey, fontSize: 11),
        ),
        GestureDetector(
          onTap: () => _showDescriptionSheet(context),
          child: Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: Text(
              "Read more".tr,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 10.5.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDescriptionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DescriptionSheet(
        title: listing.propertyName,
        html: listing.description,
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (listing.bedrooms > 0) ...[
          _statIcon(Icons.bed_outlined, "${listing.bedrooms} ${"Beds".tr}"),
          const SizedBox(width: 16),
        ],

        _statIcon(Icons.bathtub_outlined, "${listing.bathrooms} ${"Baths".tr}"),

        const SizedBox(width: 16),

        _statIcon(
          Icons.square_foot_outlined,
          "${listing.area.toInt()} ${"sqft".tr}",
        ),

        const Spacer(),

        if (listing.status.toUpperCase() == "PENDING_PAYMENT") _payButton(),
      ],
    );
  }

  Widget _payButton() {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: isPaying ? null : onPay,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isPaying
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                "Pay".tr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _statIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.labelGrey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.labelGrey),
        ),
      ],
    );
  }

  String _formatPrice(num price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ",");
  }
}

void _showRejectedDialog(Property listing, VoidCallback onEdit) {
  final review = listing.latestReview;

  Get.dialog(
    Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.report_problem_outlined,
                color: Colors.red,
                size: 30,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              "Listing Rejected".tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            Text(
              "Please review the issue below and update your listing before submitting it again."
                  .tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xffFFF5F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xffF7D4D4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 18),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Issue".tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          listing.rejectionReason?.isNotEmpty == true
                              ? listing.rejectionReason!
                              : review?.message ?? "-",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (review != null) ...[
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF8F8F8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      review.reviewedBy.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: Text("Close".tr),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      onEdit();
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text("Edit & Resubmit".tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

//===============================================================
// STATUS BADGE (Active / Draft / Sold) — same pill language as
// the WhatsApp Verified banner (colored bg + colored text)
// =================================================================
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (status.toUpperCase()) {
      case "ACTIVE":
      case "APPROVED":
        bg = const Color(0xffEAF8EF);
        fg = Colors.green;
        label = "Active";
        break;

      case "PENDING":
        bg = const Color(0xffFFF8E7);
        fg = Colors.orange;
        label = "Pending";
        break;
      case "PENDING_PAYMENT":
        bg = const Color(0xffFFF8E7);
        fg = Colors.orange;
        label = "Payment Pending";
        break;
      case "RESUBMITTED":
        bg = const Color(0xffFFF8E7);
        fg = Colors.orange;
        label = "Resubmitted";
        break;

      case "REJECTED":
        bg = const Color(0xffFFECEC);
        fg = Colors.red;
        label = "Rejected";
        break;

      case "INACTIVE":
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
        label = "Inactive";
        break;

      case "SOLD":
        bg = Colors.blue.shade50;
        fg = Colors.blue;
        label = "Sold";
        break;

      default:
        bg = Colors.grey.shade100;
        fg = Colors.black;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.tr,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

// =================================================================
// FOR SALE / FOR RENT TAG
// =================================================================
class _ForTag extends StatelessWidget {
  final Property property;

  const _ForTag({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final bool isSale = property.purpose.toUpperCase() == "SALE";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.pinkBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSale ? Icons.sell_outlined : Icons.vpn_key_outlined,
            size: 11,
            color: AppColors.primary,
          ),
          const SizedBox(width: 3),
          Text(
            isSale ? "For Sale".tr : "For Rent".tr,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // your existing empty state UI
          ],
        ),
      ),
    );
  }
}

//======================================================
// DESCRIPTION SHEET — renders the listing's rich-text
// description (HTML from the quill editor) read-only,
// using quill_html_editor.
//======================================================
class _DescriptionSheet extends StatefulWidget {
  final String title;
  final String html;

  const _DescriptionSheet({required this.title, required this.html});

  @override
  State<_DescriptionSheet> createState() => _DescriptionSheetState();
}

class _DescriptionSheetState extends State<_DescriptionSheet> {
  final QuillEditorController _controller = QuillEditorController();
  double _editorHeight = 120.h;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .75,
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4.h),
            Text(
              "Description".tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.hintGrey,
              ),
            ),
            SizedBox(height: 10.h),
            Flexible(
              child: SingleChildScrollView(
                child: QuillHtmlEditor(
                  controller: _controller,
                  text: widget.html,
                  isEnabled: false,
                  minHeight: _editorHeight,
                  padding: EdgeInsets.zero,
                  hintText: '',
                  backgroundColor: Colors.white,
                  loadingBuilder: (_) => SizedBox(
                    height: _editorHeight,
                    child: const Center(
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  onEditorResized: (height) {
                    if (mounted && height != _editorHeight) {
                      setState(() => _editorHeight = height);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
