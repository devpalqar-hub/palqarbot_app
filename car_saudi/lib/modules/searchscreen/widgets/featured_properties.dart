// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';

// import 'package:villas_qatar/Core/constants/app_colors.dart';
// import 'package:villas_qatar/Core/theme/app_textstyles.dart';
// import 'package:villas_qatar/Core/widgets/motion/app_shimmer.dart';
// import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';
// import 'package:villas_qatar/modules/PlansandFeatures/model/featured_property_model.dart';
// import 'package:villas_qatar/modules/PlansandFeatures/services/featured_properties_controller.dart';
// import 'package:villas_qatar/modules/propertydetailscreen/propertydetailscreen.dart';

// class FeaturedProperties extends StatefulWidget {
//   const FeaturedProperties({super.key});

//   @override
//   State<FeaturedProperties> createState() => _FeaturedPropertiesState();
// }

// class _FeaturedPropertiesState extends State<FeaturedProperties> {
//   late final FeaturedPropertiesController featuredController;

//   final ScrollController scrollController = ScrollController();

//   // =============================================================
//   // INIT
//   // =============================================================

//   @override
//   void initState() {
//     super.initState();

//     // -----------------------------------------------------------
//     // GET OR REGISTER FEATURED CONTROLLER
//     // -----------------------------------------------------------

//     featuredController = Get.isRegistered<FeaturedPropertiesController>()
//         ? Get.find<FeaturedPropertiesController>()
//         : Get.put(FeaturedPropertiesController());

//     // -----------------------------------------------------------
//     // PAGINATION LISTENER
//     // -----------------------------------------------------------

//     scrollController.addListener(_onScroll);

//     // -----------------------------------------------------------
//     // INITIAL API CALL
//     //
//     // location = LISTING_PAGE
//     // page     = 1
//     // limit    = 5
//     // -----------------------------------------------------------

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       featuredController.fetchFeaturedProperties(
//         location: FeaturedLocation.listingPage,
//         limit: 5,
//       );
//     });
//   }

//   // =============================================================
//   // HORIZONTAL PAGINATION
//   // =============================================================

//   void _onScroll() {
//     if (!scrollController.hasClients) {
//       return;
//     }

//     final ScrollPosition position = scrollController.position;

//     // Start fetching slightly before reaching
//     // the end so pagination feels smooth.
//     if (position.pixels >= position.maxScrollExtent - 150) {
//       final bool hasMore = featuredController.hasMore(
//         FeaturedLocation.listingPage,
//       );

//       final bool isLoadingMore = featuredController.isLoadingMore(
//         FeaturedLocation.listingPage,
//       );

//       if (hasMore && !isLoadingMore) {
//         debugPrint('Loading more LISTING_PAGE featured properties...');

//         featuredController.loadMore(
//           location: FeaturedLocation.listingPage,
//           limit: 5,
//         );
//       }
//     }
//   }

//   // =============================================================
//   // DISPOSE
//   // =============================================================

//   @override
//   void dispose() {
//     scrollController.removeListener(_onScroll);

//     scrollController.dispose();

//     super.dispose();
//   }

//   // =============================================================
//   // BUILD
//   // =============================================================

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<FeaturedPropertiesController>(
//       builder: (controller) {
//         // ---------------------------------------------------------
//         // GET LISTING PAGE FEATURED PROPERTIES
//         // ---------------------------------------------------------

//         final List<FeaturedProperty> featuredProperties = controller
//             .getProperties(FeaturedLocation.listingPage);

//         final bool isLoading = controller.isLoading(
//           FeaturedLocation.listingPage,
//         );

//         final bool isLoadingMore = controller.isLoadingMore(
//           FeaturedLocation.listingPage,
//         );

//         final String error = controller.getError(FeaturedLocation.listingPage);

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // =====================================================
//             // HEADER
//             // SAME UI
//             // =====================================================
//             Row(
//               children: [
//                 Text(
//                   "Featured Properties".tr,
//                   style: AppTextStyles.title18.copyWith(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black,
//                   ),
//                 ),

//                 const Spacer(),

//                 GestureDetector(
//                   onTap: () {},
//                   child: Row(
//                     children: [
//                       Text(
//                         "See All".tr,
//                         style: AppTextStyles.body14.copyWith(
//                           fontSize: 12.sp,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.primary,
//                         ),
//                       ),

//                       Icon(
//                         Icons.arrow_forward,
//                         color: AppColors.primary,
//                         size: 16.sp,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             SizedBox(height: 12.h),

//             // =====================================================
//             // INITIAL LOADING
//             // =====================================================
//             if (isLoading && featuredProperties.isEmpty)
//               SizedBox(
//                 height: 80.h,
//                 child: AppShimmer(
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: 3,
//                     separatorBuilder: (_, __) => SizedBox(width: 14.w),
//                     itemBuilder: (_, __) => ShimmerBox(
//                       width: 160.w,
//                       height: 80.h,
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                   ),
//                 ),
//               )
//             // =====================================================
//             // ERROR
//             // =====================================================
//             else if (error.isNotEmpty && featuredProperties.isEmpty)
//               SizedBox(
//                 height: 80.h,
//                 child: Center(
//                   child: Text(
//                     "Unable to load featured properties".tr,
//                     style: AppTextStyles.body14.copyWith(
//                       fontSize: 12.sp,
//                       color: const Color(0xff6E6E73),
//                     ),
//                   ),
//                 ),
//               )
//             // =====================================================
//             // EMPTY
//             // =====================================================
//             else if (featuredProperties.isEmpty)
//               const SizedBox.shrink()
//             // =====================================================
//             // FEATURED LIST
//             // SAME UI + PAGINATION
//             // =====================================================
//             else
//               SizedBox(
//                 height: 80.h,
//                 child: ListView.separated(
//                   controller: scrollController,

//                   scrollDirection: Axis.horizontal,

//                   physics: const BouncingScrollPhysics(),

//                   // Add one extra item only while
//                   // next page is loading.
//                   itemCount:
//                       featuredProperties.length + (isLoadingMore ? 1 : 0),

//                   separatorBuilder: (_, __) => SizedBox(width: 14.w),

//                   itemBuilder: (context, index) {
//                     // =============================================
//                     // PAGINATION LOADER
//                     // =============================================

//                     if (index >= featuredProperties.length) {
//                       return SizedBox(
//                         width: 60.w,
//                         height: 80.h,
//                         child: const Center(child: CircularProgressIndicator()),
//                       );
//                     }

//                     // =============================================
//                     // FEATURED PROPERTY
//                     // =============================================

//                     final FeaturedProperty featured = featuredProperties[index];

//                     final FeaturedListing listing = featured.listing;

//                     // =============================================
//                     // SAME LOCALITY CARD UI
//                     // =============================================

//                     return LocalityCard(
//                       propertyId: listing.id,
//                       image: listing.imageUrl,
//                       title: listing.propertyName,
//                       properties: listing.formattedPrice,
//                     );
//                   },
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }

// // ===============================================================
// // LOCALITY CARD
// //
// // UI IS KEPT THE SAME.
// // Only image handling supports API network images.
// // ===============================================================

// class LocalityCard extends StatelessWidget {
//   final String propertyId;
//   final String image;
//   final String title;
//   final String properties;

//   const LocalityCard({
//     super.key,
//     required this.propertyId,
//     required this.image,
//     required this.title,
//     required this.properties,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return PressableScale(
//       onTap: _openPropertyDetails,
//       child: Container(
//         width: 160.w,
//         height: 80.h,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8.r),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0x14000000),
//               blurRadius: 18,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,

//         child: Row(
//           children: [
//             // =====================================================
//             // LEFT IMAGE
//             // =====================================================
//             SizedBox(
//               width: 65.w,
//               height: double.infinity,
//               child: _buildImage(),
//             ),

//             SizedBox(width: 12.w),

//             // =====================================================
//             // TEXT
//             // =====================================================
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     title,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: AppTextStyles.title16.copyWith(
//                       fontSize: 11.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),

//                   SizedBox(height: 4.h),

//                   Text(
//                     properties,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: AppTextStyles.title16.copyWith(
//                       fontSize: 11.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),

//                   SizedBox(height: 2.h),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // =============================================================
//   // IMAGE
//   // Supports API network image while preserving same dimensions.
//   // =============================================================

//   void _openPropertyDetails() {
//     final String id = propertyId.trim();

//     if (id.isEmpty) {
//       debugPrint("FEATURED PROPERTY ERROR: Property ID is empty");

//       Fluttertoast.showToast(msg: "Property details are not available".tr);
//       return;
//     }

//     debugPrint("OPEN FEATURED PROPERTY DETAILS: $id");

//     Get.to(() => PropertyDetailsScreen(propertyId: id));
//   }

//   Widget _buildImage() {
//     final String url = image.trim();

//     if (url.startsWith('http://') || url.startsWith('https://')) {
//       return Image.network(
//         url,
//         fit: BoxFit.cover,

//         errorBuilder: (context, error, stackTrace) {
//           return Image.asset('assets/lct.jpeg', fit: BoxFit.cover);
//         },
//       );
//     }

//     // Empty or invalid API URL.
//     if (url.isEmpty) {
//       return Image.asset('assets/lct.jpeg', fit: BoxFit.cover);
//     }

//     // Allows existing asset paths too.
//     return Image.asset(
//       url,
//       fit: BoxFit.cover,

//       errorBuilder: (context, error, stackTrace) {
//         return Image.asset('assets/lct.jpeg', fit: BoxFit.cover);
//       },
//     );
//   }
// }
