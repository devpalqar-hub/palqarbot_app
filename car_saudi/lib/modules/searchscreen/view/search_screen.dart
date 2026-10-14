import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/app_logo.dart';
import 'package:villas_qatar/modules/searchscreen/service/searchlist_screen.dart';
import 'package:villas_qatar/modules/searchscreen/widgets/properties_section.dart';
import 'package:villas_qatar/modules/searchscreen/widgets/search_filtercard.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final PropertySearchController controller =
      Get.isRegistered<PropertySearchController>()
      ? Get.find<PropertySearchController>()
      : Get.put(PropertySearchController(), permanent: true);

  /// Start fetching the next page once this close to the end of the list.
  static const double _loadMoreThreshold = 300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 15.w,
        title: Image.asset(AppLogo.path, width: 140.w, fit: BoxFit.contain),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(height: 1.h, color: AppColors.warmBorder),
        ),
      ),
      body: SafeArea(
        child: GetBuilder<PropertySearchController>(
          builder: (controller) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.refreshProperties,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  final bool isMainList =
                      notification.depth == 0 &&
                      notification.metrics.axis == Axis.vertical;

                  if (isMainList &&
                      (notification is ScrollUpdateNotification ||
                          notification is ScrollEndNotification) &&
                      notification.metrics.extentAfter < _loadMoreThreshold) {
                    controller.fetchProperties(loadMore: true);
                  }

                  return false;
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SizedBox(height: 16.h),
                            // const _Hero(),
                            SearchFilterCard(controller: controller),
                            // SizedBox(height: 24.h),
                            // ResultsHeader(controller: controller),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 24.h),
                      sliver: PropertyResultsSliver(controller: controller),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Page title with the skyline sitting beside it (never behind the text).
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88.h,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Properties".tr,
                  style: AppTextStyles.title14.copyWith(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xff1A1A1A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Find your perfect home in Qatar".tr,
                  style: AppTextStyles.body14.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Opacity(
            opacity: 0.6,
            child: Image.asset(
              "assets/build.png",
              width: 110.w,
              height: 88.h,
              fit: BoxFit.contain,
              alignment: AlignmentDirectional.centerEnd,
            ),
          ),
        ],
      ),
    );
  }
}
