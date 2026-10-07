import 'package:flutter/material.dart';
import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;

  final bool showSearch;
  final bool showFilter;
  final bool showNotification;

  final VoidCallback? onSearch;
  final VoidCallback? onFilter;
  final VoidCallback? onNotification;

  const AppTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.showSearch = false,
    this.showFilter = false,
    this.showNotification = false,
    this.onSearch,
    this.onFilter,
    this.onNotification,
  });

 @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        20,
        55,
        20,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          if (showSearch)
            _buildActionButton(
              icon: Icons.search_rounded,
              onPressed: onSearch,
            ),

          if (showFilter) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.tune_rounded,
              onPressed: onFilter,
            ),
          ],

          if (showNotification) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.notifications_none_rounded,
              onPressed: onNotification,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 19,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}