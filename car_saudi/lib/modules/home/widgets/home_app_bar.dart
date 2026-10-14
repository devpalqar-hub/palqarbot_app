import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/Core/utils/auth_guard.dart';
import 'package:villas_qatar/Core/widgets/app_logo.dart';
import 'package:villas_qatar/modules/chats/views/chatlistscreen.dart';
import 'package:villas_qatar/modules/settings/view/setting_screen.dart';

/// Top bar of the Home screen: logo on the leading side, and on the trailing
/// side a language switch, the chats shortcut and the profile shortcut.
///
/// Chats and Profile used to live in a bottom navigation bar; now that Home has
/// none, they open as regular pushed screens (with a back button).
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1.h);

  void _openChats() {
    if (!AuthGuard.requireLogin(
      message: "Please login to access your chats.".tr,
    )) {
      return;
    }

    Get.to(() => ChatListScreen());
  }

  void _openProfile() {
    Get.to(() => SettingsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 15.w,
      title: Image.asset(
        AppLogo.path,
        width: 130.w,
        fit: BoxFit.contain,
        alignment: AlignmentDirectional.centerStart,
      ),
      actions: [
        const _LanguageSwitch(),
        SizedBox(width: 2.w),
        IconButton(
          tooltip: "Chats".tr,
          onPressed: _openChats,
          icon: Icon(
            CupertinoIcons.chat_bubble,
            color: AppColors.primary,
            size: 24.sp,
          ),
        ),
        IconButton(
          tooltip: "Profile".tr,
          onPressed: _openProfile,
          icon: Icon(
            CupertinoIcons.profile_circled,
            color: AppColors.primary,
            size: 26.sp,
          ),
        ),
        SizedBox(width: 6.w),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(height: 1.h, color: AppColors.warmBorder),
      ),
    );
  }
}

/// One-tap English <-> Arabic switch.
///
/// The pill names the language you'd switch *to*, written in that language's
/// own script, so it stays readable whichever language the app is in.
/// Persists the choice the same way [LanguageScreen] does, so it survives a
/// restart.
class _LanguageSwitch extends StatelessWidget {
  const _LanguageSwitch();

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  void _toggle() {
    final String code = _isArabic ? 'en' : 'ar';

    Get.updateLocale(
      code == 'ar' ? const Locale('ar', 'QA') : const Locale('en', 'US'),
    );
    StorageService.saveLanguage(code);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Language".tr,
      child: Material(
        color: AppColors.cream,
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.warmBorder),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: _toggle,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 5.w),
                Text(
                  _isArabic ? 'English' : 'العربية',
                  style: TextStyle(
                    fontSize: 12.sp,
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
