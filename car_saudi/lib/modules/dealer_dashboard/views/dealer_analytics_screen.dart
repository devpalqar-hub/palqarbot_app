import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/motion/animated_counter.dart';
import 'package:villas_qatar/Core/widgets/motion/app_shimmer.dart';
import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';
import 'package:villas_qatar/Core/widgets/motion/staggered_entrance_column.dart';
import 'package:villas_qatar/modules/dealer_dashboard/model/dealer_analytics_model.dart';
import 'package:villas_qatar/modules/dealer_dashboard/service/dealer_analytics_controller.dart';
import 'package:villas_qatar/modules/dealer_dashboard/widgets/dealer_filter_sheet.dart';
import 'package:villas_qatar/modules/dealer_dashboard/widgets/trend_chart.dart';
import 'package:villas_qatar/modules/onboard/controller/auth_controller.dart';
import 'package:villas_qatar/modules/onboard/views/welcome_screen.dart';
import 'package:villas_qatar/modules/propertydetailscreen/propertydetailscreen.dart';

/// The entire dealer portal — one screen, reached from "Login as Dealer".
/// Pulls its data live from GET /api/dealers/analytics/dashboard (stats,
/// trend graph, top listings) and GET /api/dealer-subscriptions/my (the
/// subscription card). Tapping a listing card opens the same
/// [PropertyDetailsScreen] the buyer/renter side uses.
class DealerAnalyticsScreen extends StatefulWidget {
  const DealerAnalyticsScreen({super.key});

  @override
  State<DealerAnalyticsScreen> createState() => _DealerAnalyticsScreenState();
}

class _DealerAnalyticsScreenState extends State<DealerAnalyticsScreen> {
  static const _gold = Color(0xFFC9A227);
  static const _goldLight = Color(0xFFF4E4B8);
  static const _green = Color(0xFF1F9D63);
  static const _greenSoft = Color(0xFFE4F7ED);
  static const _red = Color(0xFFD64545);
  static const _redSoft = Color(0xFFFCE9E9);
  static const _amber = Color(0xFFDA9A1F);
  static const _amberSoft = Color(0xFFFBF1DC);
  static const _blue = Color(0xFF3B7DD8);
  static const _blueSoft = Color(0xFFE9F1FC);
  static const _grey = Color(0xFF7A6570);
  static const _greySoft = Color(0xFFEDE7E9);
  static const _ink = Color(0xFF2B1620);
  static const _inkSoft = Color(0xFF7A6570);
  static const _line = Color(0xFFF1E1E6);

  static final _currency = NumberFormat.decimalPattern('en_US');

  late final DealerAnalyticsController controller;
  static const _staffColors = [AppColors.primary, _gold, _blue, _green, _red];

  @override
  void initState() {
    super.initState();
    controller = Get.put(DealerAnalyticsController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F8),
      body: SafeArea(
        bottom: false,
        child: GetBuilder<DealerAnalyticsController>(
          builder: (controller) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await Future.wait([
                  controller.fetchDashboard(),
                  controller.fetchSubscriptions(),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    SizedBox(height: 14.h),
                    _titleBlock(),
                    SizedBox(height: 14.h),
                    _filterRow(),
                    SizedBox(height: 14.h),
                    if (controller.isLoading && controller.data == null)
                      _loadingState()
                    else if (controller.error != null &&
                        controller.data == null)
                      _errorState(controller.error!)
                    else if (controller.data != null)
                      _content(controller.data!),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _loadingState() {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: double.infinity,
            height: 130.h,
            borderRadius: BorderRadius.circular(20.r),
          ),
          SizedBox(height: 18.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 1.40,
            children: List.generate(
              4,
              (_) => ShimmerBox(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
          SizedBox(height: 18.h),
          ShimmerBox(
            width: double.infinity,
            height: 170.h,
            borderRadius: BorderRadius.circular(18.r),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 36.sp, color: _inkSoft),
          SizedBox(height: 10.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body13.copyWith(color: _inkSoft),
          ),
          SizedBox(height: 14.h),
          PressableScale(
            child: ElevatedButton(
              onPressed: controller.fetchDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                "Retry".tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(DealerAnalyticsResponse data) {
    return StaggeredEntranceColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subscriptionCard(),

        Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: _sectionTitle("Overview".tr, "This period".tr),
        ),
        _statGrid(data.overview),

        _sectionTitle("Performance Trend".tr, controller.granularity.tr),
        _chartCard(data.graph),
        SizedBox(height: 15.h),
        _sectionTitle("Top Listings".tr, ""),
        if (data.topListings.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: Text(
                "No listings in this period".tr,
                style: AppTextStyles.body13.copyWith(color: _inkSoft),
              ),
            ),
          )
        else
          Column(children: data.topListings.map(_listingCard).toList()),
      ],
    );
  }

  // ---------------------------------------------------------------- header

  Widget _header() {
    final profile = StorageService.getProfile();
    final name = profile?['name'] ?? '';
    final initials = name.isNotEmpty
        ? name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((e) => e[0])
              .join()
              .toUpperCase()
        : "D";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ClipPath(
              clipper: _LogoClipper(),
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_gold, const Color(0xFFA9791C)],
                  ),
                ),
              ),
            ),
            SizedBox(width: 9.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Villas Qatar".tr,
                  style: AppTextStyles.title16.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  "DEALER PORTAL".tr,
                  style: TextStyle(
                    fontSize: 8.sp,
                    letterSpacing: 1.5,
                    color: _inkSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: _showAccountSheet,
          child: Container(
            width: 38.w,
            height: 38.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTextStyles.medium13.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showAccountSheet() {
    final profile = StorageService.getProfile();

    final String name = profile?['name']?.toString().trim().isNotEmpty == true
        ? profile!['name'].toString()
        : "Dealer".tr;

    final String? email = profile?['email']?.toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Drag handle
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),

              SizedBox(height: 20.h),

              /// Profile header
              Row(
                children: [
                  Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person_outline_rounded,
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
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title16.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF222222),
                          ),
                        ),

                        if (email != null && email.isNotEmpty) ...[
                          SizedBox(height: 3.h),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body12.copyWith(
                              color: const Color(0xFF8A8A8A),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              /// Divider
              Container(height: 1, color: const Color(0xFFEDEDED)),

              SizedBox(height: 8.h),

              /// Logout
              InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () async {
                  Navigator.pop(context);

                  await Get.find<AuthController>().logout();

                  Get.offAll(() => WelcomeScreen());
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 2.w,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.logout_rounded,
                          size: 18.sp,
                          color: const Color(0xFFD64545),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Text(
                          "Log out".tr,
                          style: AppTextStyles.medium14.copyWith(
                            color: const Color(0xFFD64545),
                          ),
                        ),
                      ),

                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20.sp,
                        color: const Color(0xFFB0B0B0),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleBlock() {
    final profile = StorageService.getProfile();
    final name = profile?['name'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Analytics".tr,
          style: AppTextStyles.title18.copyWith(fontSize: 22.sp, color: _ink),
        ),
        SizedBox(height: 2.h),
        Text.rich(
          TextSpan(
            text: "${"Performance overview for".tr} ",
            style: AppTextStyles.body12.copyWith(color: _inkSoft),
            children: [
              TextSpan(
                text: (name != null && name.toString().isNotEmpty)
                    ? name.toString()
                    : "your agency".tr,
                style: AppTextStyles.medium13.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterRow() {
    final fmt = DateFormat('MMM d, yyyy');
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: () => showDealerFilterSheet(context, controller),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _line),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "${fmt.format(controller.startDate)} – ${fmt.format(controller.endDate)}",
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.medium13.copyWith(
                        color: _ink,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ),
                  Text(
                    controller.granularity[0].toUpperCase() +
                        controller.granularity.substring(1),
                    style: AppTextStyles.body12.copyWith(color: _inkSoft),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        PressableScale(
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: () => showDealerFilterSheet(context, controller),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14.r),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.tune_rounded, color: Colors.white, size: 16.sp),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ subscription

  Widget _subscriptionCard() {
    final sub = controller.activeSubscription;
    final overviewSub = controller.data?.overview.subscription;

    final planName =
        sub?.plan?.name ?? overviewSub?.planName ?? "No active plan".tr;
    final maxListings = sub?.plan?.maxListings ?? overviewSub?.maxListings ?? 0;
    final endDate = sub?.endDate ?? overviewSub?.endDate;
    final daysRemaining = endDate != null
        ? endDate.difference(DateTime.now()).inDays.clamp(0, 100000)
        : (overviewSub?.daysRemaining ?? 0);
    final validityDays = sub?.plan?.validityDays ?? 0;
    final featuredLeft =
        controller.data?.overview.quota.remainingFreeFeatured ?? 0;

    final progress = validityDays > 0
        ? (1 - (daysRemaining / validityDays)).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName,
                      style: AppTextStyles.title16.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      (overviewSub?.hasActivePlan ?? sub != null)
                          ? "Active subscription".tr
                          : "Inactive".tr,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: Colors.white.withOpacity(.75),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  "${"$daysRemaining".tr} ${"DAYS LEFT".tr}",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3D2C05),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              height: 6.h,
              color: Colors.white.withOpacity(.22),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(color: _gold),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _subMeta("Max listings".tr, "$maxListings"),
              _subMeta("Featured left".tr, "$featuredLeft"),
              _subMeta(
                "Ends".tr,
                endDate != null ? DateFormat('MMM d').format(endDate) : "—",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _subMeta(String label, String value) {
    return RichText(
      text: TextSpan(
        text: "$label ",
        style: TextStyle(
          fontSize: 11.5.sp,
          color: Colors.white.withOpacity(.85),
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String trailing) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h, bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.title16.copyWith(fontSize: 15.sp, color: _ink),
          ),
          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: AppTextStyles.body12.copyWith(color: _inkSoft),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ stats

  Widget _statGrid(DealerOverview o) {
    final viewsTrend = o.engagement.totalViews > 0
        ? "${((o.engagement.periodViews / o.engagement.totalViews) * 100).round()}%"
        : null;

    final stats = <Widget>[
      _statCard(
        icon: Icons.house_rounded,
        iconBg: AppColors.primaryLight,
        iconColor: AppColors.primary,
        value: o.listings.total,
        label: "Total Listings".tr,
        foot:
            "${o.listings.open} ${"Open".tr} · ${o.listings.sold} ${"Sold".tr} · ${o.listings.rejected} ${"Rejected".tr}",
      ),
      _statCard(
        icon: Icons.remove_red_eye_rounded,
        iconBg: _goldLight,
        iconColor: const Color(0xFF8A6A0B),
        value: o.engagement.totalViews,
        label: "Total Views".tr,
        foot: "${o.engagement.periodViews} ${"in this period".tr}",
        trend: viewsTrend,
      ),
      _statCard(
        icon: Icons.bar_chart_rounded,
        iconBg: _blueSoft,
        iconColor: _blue,
        value: o.engagement.totalImpressions,
        label: "Impressions".tr,
        foot:
            "${o.engagement.totalReach} ${"reach".tr} · ${o.engagement.periodImpressions} ${"this period".tr}",
      ),
      _statCard(
        icon: Icons.forum_outlined,
        iconBg: _greenSoft,
        iconColor: _green,
        value: o.chats.totalConversations,
        label: "Conversations".tr,
        foot: "${o.chats.totalUsersStartedChat} ${"unique users chatted".tr}",
      ),
      _statCard(
        icon: Icons.sell_rounded,
        iconBg: const Color(0xFFE4F7EF),
        iconColor: const Color(0xFF25A85D),
        value: o.sales.soldCount,
        label: "Units Sold".tr,
        foot: o.sales.soldCount == 0
            ? "No sales this period".tr
            : "${"QAR".tr} ${_currency.format(o.sales.soldValue)} ${"total".tr}",
      ),
      _statCard(
        icon: Icons.event_available_rounded,
        iconBg: AppColors.primaryLight,
        iconColor: AppColors.primary,
        value: o.visits.total,
        label: "Site Visits".tr,
        foot:
            "${o.visits.pending} ${"pending".tr} · ${o.visits.accepted} ${"accepted".tr}",
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 10.h,
      childAspectRatio: 1.40,
      children: stats,
    );
  }

  Widget _statCard({
    IconData? icon,
    Widget? iconWidget,
    required Color iconBg,
    Color? iconColor,
    required int value,
    required String label,
    required String foot,
    String? trend,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                alignment: Alignment.center,
                child: iconWidget ?? Icon(icon, size: 13.sp, color: iconColor),
              ),
              if (trend != null)
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 10.sp,
                      color: _green,
                    ),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: _green,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 4.h),
          AnimatedCounter(
            value: value,
            style: AppTextStyles.title18.copyWith(fontSize: 20.sp, color: _ink),
          ),
          Text(
            label,
            style: AppTextStyles.body13.copyWith(
              color: _inkSoft,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            foot,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9.5.sp, color: _inkSoft),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ chart

  Widget _chartCard(List<DealerGraphPoint> series) {
    if (series.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Center(
          child: Text(
            "No trend data for this period".tr,
            style: AppTextStyles.body13.copyWith(color: _inkSoft),
          ),
        ),
      );
    }

    final dayFmt = DateFormat('MM-dd');
    final labelIdx = <int>{
      0,
      if (series.length > 2) (series.length / 3).floor(),
      if (series.length > 2) (series.length * 2 / 3).floor(),
      series.length - 1,
    }.toList()..sort();

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _legend(AppColors.primary, "Views".tr),
              SizedBox(width: 14.w),
              _legend(_gold, "Chats".tr),
              SizedBox(width: 14.w),
              _legend(_blue, "Visits".tr),
            ],
          ),
          SizedBox(height: 6.h),
          SizedBox(
            height: 130.h,
            width: double.infinity,
            child: CustomPaint(
              painter: TrendChartPainter(
                series: series
                    .map((s) => TrendPoint(s.views, s.chats, s.visits))
                    .toList(),
                lineColor: AppColors.primary,
                chatColor: _gold,
                visitColor: _blue,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labelIdx
                  .map(
                    (i) => Text(
                      dayFmt.format(series[i].period),
                      style: TextStyle(fontSize: 9.sp, color: _inkSoft),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5.sp,
            color: _inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------- team

  Widget _teamStrip(List<DealerStaffMember> team) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: team.length,
        separatorBuilder: (_, _) => SizedBox(width: 10.w),
        itemBuilder: (_, i) {
          final s = team[i];
          final initials = s.name.trim().isNotEmpty
              ? s.name
                    .trim()
                    .split(RegExp(r'\s+'))
                    .take(2)
                    .map((e) => e[0])
                    .join()
                    .toUpperCase()
              : "?";
          final color = _staffColors[i % _staffColors.length];

          return Container(
            width: 96.w,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: AppTextStyles.medium14.copyWith(
                      color: Colors.white,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  s.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium13.copyWith(
                    fontSize: 11.5.sp,
                    color: _ink,
                  ),
                ),
                Text(
                  s.position,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5.sp, color: _inkSoft),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------- listings

  (Color, Color) _statusColors(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'OPEN':
        return (_green, _greenSoft);
      case 'SOLD':
        return (_blue, _blueSoft);
      case 'REJECTED':
        return (_red, _redSoft);
      case 'PENDING':
        return (_amber, _amberSoft);
      default:
        return (_grey, _greySoft);
    }
  }

  IconData _typeIcon(String? typeTitle) {
    switch (typeTitle?.toLowerCase()) {
      case 'villa':
        return Icons.holiday_village_rounded;
      case 'apartment':
        return Icons.apartment_rounded;
      case 'townhouse':
        return Icons.house_siding_rounded;
      case 'penthouse':
        return Icons.location_city_rounded;
      case 'land':
      case 'plot':
        return Icons.terrain_rounded;
      default:
        return Icons.home_work_rounded;
    }
  }

  Widget _listingCard(DealerTopListing l) {
    final (statusColor, statusBg) = _statusColors(l.status);
    final isSale = l.purpose.toUpperCase() == 'SALE';

    return PressableScale(
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _line, width: 0.8),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Get.to(() => PropertyDetailsScreen(propertyId: l.id)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
              child: Column(
                children: [
                  // ================= TOP =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Property icon
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(11.r),
                        ),
                        child: Icon(
                          _typeIcon(l.type?.title),
                          color: AppColors.primary,
                          size: 19.sp,
                        ),
                      ),

                      SizedBox(width: 10.w),

                      // Name + reference
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.propertyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.medium14.copyWith(
                                fontSize: 13.sp,
                                color: _ink,
                              ),
                            ),

                            SizedBox(height: 2.h),

                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    l.referenceCode,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 9.5.sp,
                                      color: _inkSoft,
                                    ),
                                  ),
                                ),

                                if ((l.type?.title ?? '').isNotEmpty) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                    ),
                                    child: Container(
                                      width: 3.w,
                                      height: 3.w,
                                      decoration: BoxDecoration(
                                        color: _inkSoft,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      l.type!.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9.5.sp,
                                        color: _inkSoft,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 6.w),

                      // Status + arrow
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              l.status.tr,
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),

                          SizedBox(height: 3.h),

                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16.sp,
                            color: _inkSoft,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // ================= PRICE + PURPOSE =================
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSale ? _goldLight : _blueSoft,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          l.purpose.tr,
                          style: TextStyle(
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.w700,
                            color: isSale ? const Color(0xFF8A6A0B) : _blue,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        "${"QAR".tr} ${_currency.format(l.price)}",
                        style: AppTextStyles.title16.copyWith(
                          fontSize: 13.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // ================= STATS =================
                  Container(
                    padding: EdgeInsets.only(top: 7.h),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: _line, width: 0.7)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _compactStat(
                            Icons.remove_red_eye_outlined,
                            l.viewsCount,
                            "Views".tr,
                          ),
                        ),

                        _statDivider(),

                        Expanded(
                          child: _compactStat(
                            Icons.group_outlined,
                            l.reachCount,
                            "Reach".tr,
                          ),
                        ),

                        _statDivider(),

                        Expanded(
                          child: _compactStat(
                            Icons.chat_bubble_outline_rounded,
                            l.conversationsCount,
                            "Chats".tr,
                          ),
                        ),

                        _statDivider(),

                        Expanded(
                          child: _compactStat(
                            Icons.event_outlined,
                            l.visitsCount,
                            "Visits".tr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _compactStat(IconData icon, int value, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 13.sp, color: _inkSoft),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            Text(
              label.tr,
              style: TextStyle(fontSize: 8.sp, color: _inkSoft),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statChip({
    required IconData icon,
    required int value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.primary),
        SizedBox(height: 4.h),
        Text(
          "$value",
          style: AppTextStyles.medium14.copyWith(fontSize: 13.sp, color: _ink),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: TextStyle(fontSize: 9.sp, color: _inkSoft),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 32.h, color: _line);
  }
}

/// Six-point star/badge clip used for the brand mark.
class _LogoClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.35)
      ..lineTo(w * 0.8, h)
      ..lineTo(w * 0.5, h * 0.75)
      ..lineTo(w * 0.2, h)
      ..lineTo(0, h * 0.35)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
