
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';

class ConnectChannelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  const ConnectChannelCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWhatsApp = title.toLowerCase().contains('whatsapp');

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.border,
              width: 1.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: FaIcon(
                        isWhatsApp
                            ? FontAwesomeIcons.whatsapp
                            : FontAwesomeIcons.instagram,
                        size: 25.sp,
                        color: color,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          isLoading ? 'Connecting to WhatsApp...' : subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  if (isLoading)
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: AppColors.primary,
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: isLoading ? null : onTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary,
                      width: 1.w,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.8.w,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Please wait...',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.primary,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Connect',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
