import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/Core/widgets/motion/pressable_scale.dart';

import '../../../Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/utils/app_toast.dart';

/// "Join us on social media" panel that closes the home page - a cream panel
/// with a warm border (same material as the trust strip above it) holding one
/// tile each for Facebook, Instagram and X. The links are the ones the
/// website footer uses.
class SocialMediaCard extends StatelessWidget {
  const SocialMediaCard({super.key});

  static const String facebookUrl =
      'https://www.facebook.com/share/1BnzUDDcnj/?mibextid=wwXIfr';
  static const String instagramUrl =
      'https://www.instagram.com/villasqatar?igsi=MWJjMGtqdmIzN3h6MQ%3D%3D&utm_source=qr';
  static const String xUrl = 'https://x.com/villasqatar';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join us on social media'.tr,
            style: AppTextStyles.bold14.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              letterSpacing: -0.1,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            'Follow us for new listings, market updates and exclusive offers'
                .tr,
            style: AppTextStyles.body13.copyWith(
              fontSize: 11.sp,
              color: AppColors.inkMuted,
              height: 1.45,
            ),
          ),

          SizedBox(height: 14.h),

          Row(
            children: [
              Expanded(
                child: _SocialTile(
                  label: 'Facebook'.tr,
                  icon: FontAwesomeIcons.facebookF,
                  color: const Color(0xFF1877F2),
                  url: facebookUrl,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SocialTile(
                  label: 'Instagram'.tr,
                  icon: FontAwesomeIcons.instagram,
                  gradient: const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color(0xFFF58529),
                      Color(0xFFDD2A7B),
                      Color(0xFF8134AF),
                    ],
                  ),
                  url: instagramUrl,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SocialTile(
                  label: 'X'.tr,
                  icon: FontAwesomeIcons.xTwitter,
                  color: AppColors.ink,
                  url: xUrl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialTile extends StatelessWidget {
  const _SocialTile({
    required this.label,
    required this.icon,
    required this.url,
    this.color,
    this.gradient,
  });

  final String label;
  final FaIconData icon;
  final String url;
  final Color? color;
  final Gradient? gradient;

  Future<void> _open() async {
    final Uri uri = Uri.parse(url);

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) return;
    } catch (e) {
      debugPrint('Social link error: $e');
    }

    AppToast.show(msg: 'Could not open the link'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: _open,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 6.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.warmBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  // FaIcon is a bare glyph (no built-in centering like Icon),
                  // so centre it explicitly or it paints from the top-left.
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    gradient: gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (color ?? const Color(0xFFDD2A7B)).withValues(
                          alpha: .28,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: FaIcon(icon, size: 19.sp, color: Colors.white),
                ),

                SizedBox(height: 9.h),

                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
