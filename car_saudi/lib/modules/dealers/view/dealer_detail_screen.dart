import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/utils/app_transitions.dart';
import 'package:villas_qatar/modules/dealers/service/dealer_controller.dart';
import 'package:villas_qatar/modules/dealers/model/dealer_details_model.dart';
import 'package:villas_qatar/modules/propertydetailscreen/propertydetailscreen.dart';
import 'package:villas_qatar/modules/mainscreen/mainscreen.dart';

class DealerDetailsScreen extends StatefulWidget {
  const DealerDetailsScreen({super.key});

  @override
  State<DealerDetailsScreen> createState() => _DealerDetailsScreenState();
}

class _DealerDetailsScreenState extends State<DealerDetailsScreen> {
  final _controller = Get.find<DealerController>();
  bool _expandAbout = false;
  bool _favorite = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchDealerDetails(Get.arguments as String);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DealerController>(
      builder: (c) {
        final d = c.dealer;
        if (c.isLoading || d == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final p = d.dealerProfile;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(
                          p,
                          d,
                          favorite: _favorite,
                          onFavorite: () =>
                              setState(() => _favorite = !_favorite),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 60.h),
                              _Identity(p, d),
                              SizedBox(height: 16.h),
                              _ContactCard(p, d),
                            
                         
                              SizedBox(height: 18.h),
                              _SectionTitle(
                                title: "Properties".tr,
                                onViewAll: () {
                                  Get.offAll(
                                    () => const MainScreen(initialIndex: 1),
                                    transition: AppTransitions.forward,
                                  );
                                },
                              ),
                              SizedBox(height: 12.h),
                            ],
                          ),
                        ),
                        _PropertiesRow(d.listings),
                      ],
                    ),
                  ),
                ),
                _BottomActions(d),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------------ Header
class _Header extends StatelessWidget {
  final DealerProfile p;
  final DealerDetailsModel d;
  final bool favorite;
  final VoidCallback onFavorite;

  const _Header(
    this.p,
    this.d, {
    required this.favorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final hasCover = p.coverImage?.trim().isNotEmpty ?? false;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ---------------------------------------------------------
        // COVER IMAGE
        // ---------------------------------------------------------
        SizedBox(
          height: 200.h,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            ),
            child: hasCover
                ? Image.network(
                    p.coverImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) {
                      return const _CoverPlaceholder();
                    },
                  )
                : const _CoverPlaceholder(),
          ),
        ),

        // ---------------------------------------------------------
        // BACK BUTTON
        // ---------------------------------------------------------
        Positioned(
          top: 16.h,
          left: 16.w,
          child: _RoundIcon(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Get.back(),
          ),
        ),

        Positioned(
          left: 16.w,
          bottom: -50.h,
          child: Container(
            width: 100.w,
            height: 100.w,
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.10),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17.r),
              child: hasCover
                  ? Image.network(
                      p.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const _DealerPlaceholder();
                      },
                    )
                  : const _DealerPlaceholder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF4F5F7),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle background building pattern
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Icon(
              Icons.location_city_outlined,
              size: 150.sp,
              color: const Color(0xFFE7E8EB),
            ),
          ),

          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(
              Icons.business_outlined,
              size: 28.sp,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
class _DealerPlaceholder extends StatelessWidget {
  const _DealerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F6F7),
      alignment: Alignment.center,
      child: Icon(
        Icons.business_outlined,
        size: 38.sp,
        color: AppColors.primary,
      ),
    );
  }
}


// A neutral "no image" indication used wherever a network image is
// missing or fails to load, instead of a plain brand-tinted background.
class _NoImagePlaceholder extends StatelessWidget {
  final double? iconSize;

  const _NoImagePlaceholder({this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.r))),
      width: double.infinity,
      height: double.infinity,
      color: AppColors.divider,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: iconSize ?? 32.sp,
        color: AppColors.textHint,
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _RoundIcon({
    required this.icon,
    this.iconColor = Colors.black87,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 15.sp, color: iconColor),
      ),
    );
  }
}

// ---------------------------------------------------------------- Identity
class _Identity extends StatelessWidget {
  final DealerProfile p;
  final DealerDetailsModel d;

  const _Identity(this.p, this.d);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                p.dealerName,
                style: AppTextStyles.title18,
                overflow: TextOverflow.ellipsis,
              ),
            ),
           
          ],
        ),
        if (p.tagline != null) ...[
          SizedBox(height: 4.h),
          Text(
            p.tagline!,
            style: AppTextStyles.body13.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        SizedBox(height: 8.h),
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: d.isActive ? AppColors.success : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),

            SizedBox(width: 6.w),

            Text(
              d.isActive ? "Active".tr : "Inactive".tr,
              style: AppTextStyles.body13.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            SizedBox(width: 8.w),

            // Small vertical divider
            Container(width: 1, height: 14.h, color: Colors.grey.shade400),

            SizedBox(width: 8.w),

            Text(
              "${"Trade No".tr} ${p.tradeNumber ?? ""}",
              style: AppTextStyles.body13.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 15.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 4.w),
            Text(
              "${p.city}, ${p.country}",
              style: AppTextStyles.body13.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 16.w),
            Icon(
              Icons.calendar_today_outlined,
              size: 13.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 4.w),
            Text(
              "${"Active Since".tr} ${d.createdAt.year}",
              style: AppTextStyles.body13.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- ContactCard
class _ContactCard extends StatelessWidget {
  final DealerProfile p;
  final DealerDetailsModel d;

  const _ContactCard(this.p, this.d);

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: "Contact Information".tr,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ContactTile(Icons.call_outlined, d.phone, "Phone".tr),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ContactTile(Icons.email_outlined, d.email, "Email".tr),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _ContactTile(
                  Icons.language,
                  p.website ?? "",
                  "Website".tr,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ContactTile(
                  Icons.location_on_outlined,
                  p.address ?? "",
                  p.city ?? "",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ContactTile(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 16.sp, color: AppColors.primary),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body14.copyWith(fontSize: 12.sp),
              ),
              Text(
                label,
                style: AppTextStyles.body10.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 16.sp, color: color),
            ),
            SizedBox(width: 8.w),
            Text(value, style: AppTextStyles.bold16),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: AppTextStyles.body12.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- About Card
class _AboutCard extends StatelessWidget {
  final String description;
  final bool expanded;
  final VoidCallback onToggle;

  const _AboutCard(
    this.description, {
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: "About Company".tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            maxLines: expanded ? null : 2,
            overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: AppTextStyles.body13.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onToggle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    expanded ? "Show Less".tr : "Read More".tr,
                    style: AppTextStyles.body13.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- Section
class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionTitle({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.title16.copyWith(fontWeight:FontWeight.w500)),
        InkWell(
          onTap: onViewAll,
          child: Row(
            children: [
              Text(
                "See all".tr,
                style: AppTextStyles.body13.copyWith(color: AppColors.primary),
              ),
              Icon(Icons.chevron_right, size: 18.sp, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------- Properties Row
class _PropertiesRow extends StatelessWidget {
  final List<DealerListing> listings;

  const _PropertiesRow(this.listings);

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 54.w,
                height: 54.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_work_outlined,
                  color: AppColors.primary,
                  size: 26.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "No Properties Listed".tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.title18.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "This dealer hasn't added any listings yet".tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.body13.copyWith(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 220.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: listings.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, i) => _PropertyCard(listings[i]),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final DealerListing listing;

  const _PropertyCard(this.listing);

  @override
  Widget build(BuildContext context) {
    final photo = listing.sortedPhotos.isNotEmpty
        ? listing.sortedPhotos.first.url
        : "";

    final forSale = listing.purpose.toLowerCase() != "rent";

    return GestureDetector(
      onTap: () {
        debugPrint("Dealer Property Clicked: ${listing.id}");

        Get.to(
          () => PropertyDetailsScreen(propertyId: listing.id),
          transition: AppTransitions.forward,
          duration: const Duration(milliseconds: 500),
        );
      },
      child: Container(
        width: 180.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  child: SizedBox(
                    height: 120.h,
                    width: double.infinity,
                    child: (photo?.isNotEmpty ?? false)
                        ? Image.network(
                            photo!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const _NoImagePlaceholder(),
                          )
                        : const _NoImagePlaceholder(),
                  ),
                ),

                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      forSale ? "FOR SALE".tr : "FOR RENT".tr,
                      style: AppTextStyles.bold12.copyWith(
                        color: Colors.white,
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                10.w,
                10.w,
                10.w,
                5.h, // reduced bottom space
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.propertyName ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold12,
                  ),

                  SizedBox(height: 4.h),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          "${listing.areaName}, ${listing.municipality.name}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body12.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    "${"QAR".tr} ${listing.price.toStringAsFixed(0)}"
                    "${forSale ? '' : '/month'.tr}",
                    style: AppTextStyles.bold16.copyWith(
                      color: AppColors.primary,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// -------------------------------------------------------------- Generic
class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.body12),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final DealerDetailsModel d;

  const _BottomActions(this.d);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: Icons.call_outlined,
                label: "Call".tr,
                onTap: () async {
                  final phone = d.phone?.trim() ?? '';

                  if (phone.isEmpty) return;

                  final uri = Uri(scheme: 'tel', path: phone);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
            ),

            SizedBox(width: 8.w),

            Expanded(
              child: _actionButton(
                icon: Icons.chat_bubble_outline,
                label: "WhatsApp".tr,
                filled: true,
                onTap: () async {
                  final phone = d.phone?.trim() ?? '';

                  if (phone.isEmpty) return;

                  final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

                  if (cleanPhone.isEmpty) return;

                  final uri = Uri.parse('https://wa.me/$cleanPhone');

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),

            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return SizedBox(
      height: 46.h,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 15.sp, color: Colors.white),
              label: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body12.copyWith(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 15.sp, color: AppColors.primary),
              label: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body12.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
    );
  }
}
