import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';

/// A compact partner/agent card that displays ONLY their logo.
/// If no logo is available, it gracefully falls back to showing their name.
class CompactAgentCard extends StatelessWidget {
  final String image;
  final String name;
  final VoidCallback? onTap;

  const CompactAgentCard({
    super.key,
    required this.image,
    required this.name,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Container(
        width: 100.w,
        height: 70.h, // Compact height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          clipBehavior:
              Clip.antiAlias, // Keeps ripple effect inside the borders
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Center(child: _buildContent()),
            ),
          ),
        ),
      ),
    );
  }

  /// Attempts to build the image. If empty or fails, shows the name.
  Widget _buildContent() {
    if (image.trim().isEmpty) {
      return _namePlaceholder();
    }

    return image.startsWith("http")
        ? Image.network(
            image,
            fit: BoxFit.contain, // 'contain' prevents logos from being cropped
            errorBuilder: (_, __, ___) => _namePlaceholder(),
          )
        : Image.asset(
            image,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _namePlaceholder(),
          );
  }

  /// Centered text fallback when the logo is unavailable
  Widget _namePlaceholder() {
    return Text(
      name.isNotEmpty ? name : "Partner".tr,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: AppTextStyles.bold14.copyWith(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color:
            AppColors.gold, // Adjust to AppColors.ink if you prefer dark text
        height: 1.2,
        letterSpacing: -0.2,
      ),
    );
  }
}
