import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/modules/propertydetailscreen/propertydetailscreen.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/searchscreen/service/searchlist_screen.dart';
import 'package:villas_qatar/modules/sellerpropertyscreen/widget/seller_property_card.dart';

class SellerPropertiesScreen extends StatefulWidget {
  final String sellerId;
  final String sellerName;

  const SellerPropertiesScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  State<SellerPropertiesScreen> createState() => _SellerPropertiesScreenState();
}

class _SellerPropertiesScreenState extends State<SellerPropertiesScreen> {
  late final PropertySearchController controller;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    controller = Get.isRegistered<PropertySearchController>()
        ? Get.find<PropertySearchController>()
        : Get.put(PropertySearchController(), permanent: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // A seller's page lists every listing, so drop any Buy/Rent choice
      // left over from the Search screen.
      controller.applyFilters(createdById: widget.sellerId, purpose: '');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// The seller's listings arrive a page at a time; fetch the next page as
  /// the user nears the end so every property ends up in the list.
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      controller.fetchProperties(loadMore: true);
    }
  }

  // --------------------------------------------------------------------
  // Dynamic seller location — derived from the seller's own listings
  // (municipality name + country) instead of a hardcoded "Doha, Qatar"
  // string. Returns "" when nothing is available so the UI can hide
  // the location row entirely instead of showing a stray ", ".
  // --------------------------------------------------------------------
  String _sellerLocation(List<Property> properties) {
    final withArea = properties.where(
      (e) => e.municipality.name.trim().isNotEmpty,
    );

    if (withArea.isEmpty) return "";

    final municipality = withArea.first.municipality.name;
    final country = withArea.first.country.trim();

    return country.isEmpty ? municipality : "$municipality, $country";
  }

  // --------------------------------------------------------------------
  // Dynamic seller verification — a seller is treated as verified when
  // at least one of their listings has a verified contact, instead of
  // always showing a hardcoded "Verified Seller" badge.
  // --------------------------------------------------------------------
  bool _sellerVerified(List<Property> properties) {
    return properties.any((e) => e.contactVerified);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PropertySearchController>(
      builder: (controller) {
        final properties = controller.properties;

        final saleCount = properties.where((e) => e.purpose == "SALE").length;

        final rentCount = properties.where((e) => e.purpose == "RENT").length;

        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            surfaceTintColor: Colors.white,
            title: Text(
              "Seller Properties".tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _SellerHeader(
                  sellerName: widget.sellerName,
                  location: _sellerLocation(properties),
                  verified: _sellerVerified(properties),
                  // Total across every page, not just the ones loaded so far.
                  propertyCount: controller.meta?.total ?? properties.length,
                  saleCount: saleCount,
                  rentCount: rentCount,
                ),
              ),

              if (properties.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text("No Properties Found".tr)),
                )
              else ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                  sliver: SliverToBoxAdapter(
                    child: Text("Properties".tr, style: AppTextStyles.title16),
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final property = properties[index];

                      return SellerPropertyCard(
                        property: property,
                        onTap: () {
                          Get.to(
                            () =>
                                PropertyDetailsScreen(propertyId: property.id),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 500),
                          );
                        },
                      );
                    }, childCount: properties.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 13.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: .65,
                    ),
                  ),
                ),

                if (controller.isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else if (!controller.hasMore)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                    sliver: const SliverToBoxAdapter(
                      child: _NoMoreProperties(),
                    ),
                  ),
              ],

              SliverToBoxAdapter(child: SizedBox(height: 30.h)),
            ],
          ),
        );
      },
    );
  }
}

class _NoMoreProperties extends StatelessWidget {
  const _NoMoreProperties();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withOpacity(.4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_work_outlined,
              color: AppColors.primary,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("No more properties".tr, style: AppTextStyles.title14),
                SizedBox(height: 2.h),
                Text(
                  "This seller has no more properties to show".tr,
                  style: AppTextStyles.body13.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerHeader extends StatelessWidget {
  const _SellerHeader({
    required this.sellerName,
    required this.location,
    required this.verified,
    required this.propertyCount,
    required this.saleCount,
    required this.rentCount,
  });

  final String sellerName;
  final String location;
  final bool verified;
  final int propertyCount;
  final int saleCount;
  final int rentCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(
                    Icons.person,
                    size: 30.sp,
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(width: 16.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              sellerName,
                              style: AppTextStyles.title14,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          if (verified) ...[
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.verified,
                              color: AppColors.primary,
                              size: 16.sp,
                            ),
                          ],
                        ],
                      ),

                      if (verified) ...[
                        SizedBox(height: 2.h),
                        Text(
                          "Verified Seller".tr,
                          style: AppTextStyles.body13.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],

                      if (location.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 12.sp,
                            ),

                            SizedBox(width: 5.w),

                            Expanded(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: 10.w),

                // OutlinedButton.icon(
                //   onPressed: () {},
                //   style: OutlinedButton.styleFrom(
                //     foregroundColor: AppColors.primary,
                //     side: BorderSide(color: AppColors.primary),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8.r),
                //     ),
                //     padding: EdgeInsets.symmetric(
                //       horizontal: 15.w,
                //       vertical: 2.h,
                //     ),
                //   ),
                //   icon: Icon(Icons.chat_bubble_outline, size: 12.sp),
                //   label: Text("Message".tr,style: TextStyle(fontSize:10.sp),),
                // ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    Icons.home_work_outlined,
                    propertyCount.toString(),
                    "Properties",
                  ),
                ),

                _Divider(),

                Expanded(
                  child: _StatItem(
                    Icons.sell_outlined,
                    saleCount.toString(),
                    "For Sale",
                  ),
                ),

                _Divider(),

                Expanded(
                  child: _StatItem(
                    Icons.key_outlined,
                    rentCount.toString(),
                    "For Rent",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 55.h, width: 1, color: Colors.grey.shade200);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(this.icon, this.value, this.title);

  final IconData icon;
  final String value;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 18.sp),

        SizedBox(height: 8.h),

        Text(
          value,
          style: AppTextStyles.title14.copyWith(color: const Color(0xff222222)),
        ),

        SizedBox(height: 4.h),

        Text(
          title.tr,
          style: AppTextStyles.body12.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

class SellerFilterBar extends StatelessWidget {
  const SellerFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.total,
    required this.sale,
    required this.rent,
  });

  final String selected;
  final Function(String) onChanged;
  final int total;
  final int sale;
  final int rent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip("All".tr, total),
                  SizedBox(width: 8.w),
                  _chip("Sale".tr, sale),
                  SizedBox(width: 8.w),
                  _chip("Rent".tr, rent),
                ],
              ),
            ),
          ),

          SizedBox(width: 10.w),

          // Container(
          //   height: 40.h,
          //   width: 40.h,
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(10.r),
          //     border: Border.all(color: AppColors.fieldBorder),
          //   ),
          //   child: Icon(
          //     Icons.tune_rounded,
          //     color: AppColors.primary,
          //     size: 20.sp,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _chip(String title, int count) {
    final selectedChip = selected == title;

    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: () => onChanged(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selectedChip ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selectedChip ? AppColors.primary : AppColors.fieldBorder,
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: AppTextStyles.body12.copyWith(
                color: selectedChip ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 0.h),
              decoration: BoxDecoration(
                color: selectedChip
                    ? Colors.white.withOpacity(.18)
                    : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                "$count",
                style: AppTextStyles.body13.copyWith(
                  fontSize: 11.sp,
                  color: selectedChip ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SellerFilterChip extends StatelessWidget {
  const SellerFilterChip({
    super.key,
    required this.title,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.fieldBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyles.body13.copyWith(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 6),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(.18)
                    : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$count",
                style: AppTextStyles.body13.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
