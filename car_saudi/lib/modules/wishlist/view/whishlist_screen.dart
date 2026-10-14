import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/modules/wishlist/service/wishlist_controller.dart';
import 'package:villas_qatar/modules/wishlist/widget/wishlist_property_acrd.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late final WishlistController wishlistController;

  final TextEditingController searchController = TextEditingController();

  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    wishlistController = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController(), permanent: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      wishlistController.fetchWishlist();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color(0xffFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Text(
          "My Wishlist".tr,
          style: AppTextStyles.title18.copyWith(
            fontSize: 17.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xff202124),
          ),
        ),
      ),

      body: GetBuilder<WishlistController>(
        builder: (controller) {
          if (controller.isLoading && controller.wishlistProperties.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final filteredProperties = controller.wishlistProperties.where((
            property,
          ) {
            if (searchQuery.isEmpty) return true;

            final query = searchQuery.toLowerCase();

            return property.propertyName.toLowerCase().contains(query) ||
                property.areaName.toLowerCase().contains(query) ||
                property.municipality.name.toLowerCase().contains(
                  query.toLowerCase(),
                );
          }).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.refreshWishlist,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 30.h),
              children: [
                // SEARCH
                _buildSearchField(),

                SizedBox(height: 18.h),

                // HEADER
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Saved Properties".tr,
                            style: AppTextStyles.title16.copyWith(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff202124),
                            ),
                          ),

                          SizedBox(height: 3.h),

                          Text(
                            "${controller.wishlistProperties.length} ${"properties saved".tr}",
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xff8A8A8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                if (controller.wishlistProperties.isEmpty)
                  _buildEmptyWishlist()
                else if (filteredProperties.isEmpty)
                  _buildNoSearchResults()
                else
                  ...filteredProperties.map(
                    (property) => WishlistPropertyCard(property: property),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 45.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value.trim();
          });
        },
        style: TextStyle(fontSize: 12.sp, color: const Color(0xff333333)),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13.h),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.sp,
            color: const Color(0xff8A8A8A),
          ),
          hintText: "Search saved properties".tr,
          hintStyle: TextStyle(fontSize: 11.sp, color: const Color(0xff9A9A9A)),

          suffixIcon: searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    searchController.clear();

                    setState(() {
                      searchQuery = "";
                    });
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: const Color(0xff777777),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Padding(
      padding: EdgeInsets.only(top: 100.h),
      child: Column(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: const BoxDecoration(
              color: Color(0xffFFF1F4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              color: AppColors.primary,
              size: 30.sp,
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            "Your wishlist is empty".tr,
            style: AppTextStyles.title16.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            "Save properties you love and find them easily here.".tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, color: const Color(0xff888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Padding(
      padding: EdgeInsets.only(top: 90.h),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 42.sp,
            color: const Color(0xffBBBBBB),
          ),
          SizedBox(height: 12.h),
          Text(
            "No saved properties found".tr,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff555555),
            ),
          ),
        ],
      ),
    );
  }
}
