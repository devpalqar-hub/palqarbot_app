// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get_utils/src/extensions/internacionalization.dart';
// import 'package:villas_qatar/Core/constants/app_colors.dart';

// class ExploreQatarSection extends StatelessWidget {
//   const ExploreQatarSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       {
//         "icon": Icons.location_on_outlined,
//         "title": "Popular Areas".tr,
//         "subtitle": "Explore top locations".tr,
//       },
//       {
//         "icon": Icons.menu_book_outlined,
//         "title": "Buying Guide".tr,
//         "subtitle": "Step by step process".tr,
//       },
//       {
//         "icon": Icons.trending_up_outlined,
//         "title": "Investment Guide".tr,
//         "subtitle": "Maximize your returns".tr,
//       },
//       {
//         "icon": Icons.show_chart_outlined,
//         "title": "Market Trends".tr,
//         "subtitle": "Stay updated".tr,
//       },
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 18.h),

//         ...List.generate(
//           items.length,
//           (index) => Padding(
//             padding: EdgeInsets.only(bottom: 10.h),
//             child: _ExploreCard(
//               icon: items[index]["icon"] as IconData,
//               title: items[index]["title"] as String,
//               subtitle: items[index]["subtitle"] as String,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _ExploreCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;

//   const _ExploreCard({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 60.h,
//       padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
//       decoration: BoxDecoration(
//         color: const Color(0xffFCF8F9),
//         borderRadius: BorderRadius.circular(6.r),
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 40.h,
//             width: 40.w,
//             decoration: const BoxDecoration(
//               color: Color(0xffFCECEF),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: AppColors.primary, size: 18.sp),
//           ),

//           SizedBox(width: 18.w),

//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w500,
//                     color: const Color(0xff202124),
//                   ),
//                 ),

//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: const Color(0xff777777),
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Icon(Icons.chevron_right, color: AppColors.primary, size: 30.sp),
//         ],
//       ),
//     );
//   }
// }
