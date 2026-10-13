
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Core/widgets/app_buttons.dart';
import 'package:palqarbot_app/Core/widgets/app_topbar.dart';
import 'package:palqarbot_app/Screens/Auth/Service/auth_controller.dart';
import 'package:palqarbot_app/Screens/Inbox/widget/inbox_channel_connection.dart';
import 'package:palqarbot_app/Screens/Settings/service/profile_setting_controller.dart';
import 'package:palqarbot_app/Screens/Settings/views/Profile_detail_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final ProfileSettingsController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<ProfileSettingsController>()
        ? Get.find<ProfileSettingsController>()
        : Get.put(ProfileSettingsController());

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await controller.getUserProfile();

    if (controller.profileId.isNotEmpty) {
      await controller.getProfile(controller.profileId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        title: 'Settings',
        subtitle: 'Manage your account and connections',
      ),
      body: GetBuilder<ProfileSettingsController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 24.h),
            child: Column(
              children: [
                SizedBox(height: 5.h),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFF0F2F6),
                      width: 0.7.w,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildConnectionRow(
                        icon: FaIcon(
                          FontAwesomeIcons.whatsapp,
                          size: 24.sp,
                          color: Colors.white,
                        ),
                        iconColor: Colors.white,
                        iconBackground: AppColors.whatsapp,
                        title: 'WhatsApp Business',
                        subtitle:
                            controller.profile?.openWaConfig?.connectedNumber !=
                                    null
                                ? 'Connected: ${controller.profile!.openWaConfig!.connectedNumber}'
                                : controller.hasWhatsappConfig
                                    ? 'Phone ID: ${controller.whatsappPhoneNumberId}'
                                    : 'Connect to send and receive messages',
                        isConnected:
                            (controller.profile?.whatsappConfig?.enabled ??
                                false) ||
                            (controller.profile?.openWaConfig?.sessionStatus ==
                                'CONNECTED'),
                        onTap: () {
                          InboxChannelConnection.connectWhatsApp();
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Divider(
                          height: 1.h,
                          color: const Color(0xFFF0F2F6),
                        ),
                      ),
                      _buildConnectionRow(
                        icon: FaIcon(
                          FontAwesomeIcons.instagram,
                          size: 24.sp,
                          color: Colors.white,
                        ),
                        iconColor: Colors.white,
                        iconBackground: const Color(0xFFE1306C),
                        title: 'Instagram',
                        subtitle: controller.hasInstagramConfig
                            ? 'Account ID: ${controller.instagramAccountId}'
                            : 'Connect to send and receive messages',
                        isConnected: controller.instagramIsEnabled,
                        onTap: () {
                          InboxChannelConnection.connectInstagram();
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 5.h),
                SizedBox(height: 5.h),

                // PROFILE
                _buildSettingsCard(
                  icon: Icons.person_outline_rounded,
                  iconBackground: const Color(0xFFEAF5FF),
                  iconColor: AppColors.primary,
                  title: 'Profile',
                  subtitle: controller.profileName.isNotEmpty
                      ? controller.profileName
                      : 'Manage your profile information',
                  onTap: () {
                    if (controller.profileId.isEmpty) {
                      return;
                    }

                    Get.to(
                      () => ProfileScreen(
                        profileId: controller.profileId,
                      ),
                    );
                  },
                ),

                SizedBox(height: 5.h),

                // COMPANY
                // _buildSettingsCard(
                //   icon: Icons.business_outlined,
                //   iconBackground: const Color(0xFFF1E9FF),
                //   iconColor: const Color(0xFF9747FF),
                //   title: 'Company',
                //   subtitle: controller.profileName.isNotEmpty
                //       ? controller.profileName
                //       : 'Manage your company name',
                //   onTap: _showProfileConfig,
                // ),

                SizedBox(height: 5.h),

                // LOGOUT
                _buildSettingsCard(
                  icon: Icons.logout_rounded,
                  iconBackground: const Color(0xFFFFEEF0),
                  iconColor: AppColors.error,
                  title: 'Logout',
                  subtitle: 'Sign out from your account',
                  onTap: _showLogoutDialog,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // CONNECTION ROW
  // ============================================================

  Widget _buildConnectionRow({
    required Widget icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required bool isConnected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: SizedBox(
          height: 84.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Container(
                  width: 46.w,
                  height: 46.h,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(child: icon),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12.5.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                _buildStatusBadge(connected: isConnected),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 23.sp,
                  color: const Color(0xFF718096),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WHATSAPP CONFIG
  // ============================================================

  void _showWhatsappConfig() {
    final phoneNumberIdController = TextEditingController(
      text: controller.whatsappConfig?.phoneNumberId ?? '',
    );

    final businessAccountIdController = TextEditingController(
      text: controller.whatsappConfig?.businessAccountId ?? '',
    );

    final accessTokenController = TextEditingController();
    final appSecretController = TextEditingController();
    final verifyTokenController = TextEditingController();

    bool enabled = controller.whatsappEnabled;

    _showConfigSheet(
      title: 'WhatsApp Business',
      subtitle: 'Configure your WhatsApp connection',
      icon: Icons.chat_bubble_outline_rounded,
      iconColor: AppColors.whatsapp,
      sections: [
        _buildConfigSection(
          title: 'Business',
          children: [
            _buildConfigField(
              controller: phoneNumberIdController,
              label: 'Phone Number ID',
            ),
            _buildConfigField(
              controller: businessAccountIdController,
              label: 'Business Account ID',
            ),
          ],
        ),
        _buildConfigSection(
          title: 'Security',
          children: [
            _buildSecretField(
              controller: accessTokenController,
              label: 'Access Token',
            ),
            _buildSecretField(
              controller: appSecretController,
              label: 'App Secret',
            ),
            _buildSecretField(
              controller: verifyTokenController,
              label: 'Verify Token',
            ),
          ],
        ),
      ],
      enableTitle: 'Enable WhatsApp',
      enabled: enabled,
      enableColor: AppColors.whatsapp,
      onEnabledChanged: (value) {
        enabled = value;
      },
      onSave: () async {
        if (phoneNumberIdController.text.trim().isEmpty ||
            businessAccountIdController.text.trim().isEmpty) {
          return false;
        }

        return await controller.saveWhatsappConfig(
          profileId: controller.profileId,
          phoneNumberId: phoneNumberIdController.text.trim(),
          businessAccountId: businessAccountIdController.text.trim(),
          accessToken: accessTokenController.text.trim(),
          appSecret: appSecretController.text.trim(),
          verifyToken: verifyTokenController.text.trim(),
          enabled: enabled,
        );
      },
    );
  }

  // ============================================================
  // INSTAGRAM CONFIG
  // ============================================================

  void _showInstagramConfig() {
    final accountIdController = TextEditingController(
      text: controller.instagramConfig?.accountId ?? '',
    );

    final accessTokenController = TextEditingController();
    final appSecretController = TextEditingController();
    final verifyTokenController = TextEditingController();

    bool enabled = controller.instagramIsEnabled;

    _showConfigSheet(
      title: 'Instagram',
      subtitle: 'Configure your Instagram connection',
      icon: Icons.camera_alt_outlined,
      iconColor: const Color(0xFFE1306C),
      sections: [
        _buildConfigSection(
          title: 'Account',
          children: [
            _buildConfigField(
              controller: accountIdController,
              label: 'Account ID',
            ),
          ],
        ),
        _buildConfigSection(
          title: 'Security',
          children: [
            _buildSecretField(
              controller: accessTokenController,
              label: 'Access Token',
            ),
            _buildSecretField(
              controller: appSecretController,
              label: 'App Secret',
            ),
            _buildSecretField(
              controller: verifyTokenController,
              label: 'Verify Token',
            ),
          ],
        ),
      ],
      enableTitle: 'Enable Instagram',
      enabled: enabled,
      enableColor: const Color(0xFFE1306C),
      onEnabledChanged: (value) {
        enabled = value;
      },
      onSave: () async {
        if (accountIdController.text.trim().isEmpty) {
          return false;
        }

        return await controller.saveInstagramConfig(
          profileId: controller.profileId,
          accountId: accountIdController.text.trim(),
          accessToken: accessTokenController.text.trim(),
          appSecret: appSecretController.text.trim(),
          verifyToken: verifyTokenController.text.trim(),
          enabled: enabled,
        );
      },
    );
  }

  // ============================================================
  // COMMON CONFIG SHEET
  // ============================================================

  void _showConfigSheet({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<Widget> sections,
    required String enableTitle,
    required bool enabled,
    required Color enableColor,
    required ValueChanged<bool> onEnabledChanged,
    required Future<bool> Function() onSave,
    String saveLabel = 'Save Changes',
  }) {
    bool currentEnabled = enabled;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 16.h,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildConfigHeader(
                        icon: icon,
                        iconColor: iconColor,
                        title: title,
                        subtitle: subtitle,
                        onClose: () {
                          Navigator.pop(sheetContext);
                        },
                      ),
                      SizedBox(height: 24.h),
                      ...sections,
                      SizedBox(height: 4.h),
                      _buildConfigSwitch(
                        title: enableTitle,
                        value: currentEnabled,
                        activeColor: enableColor,
                        onChanged: (value) {
                          setModalState(() {
                            currentEnabled = value;
                          });

                          onEnabledChanged(value);
                        },
                      ),
                      SizedBox(height: 20.h),
                      _buildConfigSaveButton(
                        label: saveLabel,
                        isSaving: controller.isSaving,
                        onPressed: () async {
                          if (controller.isSaving) {
                            return;
                          }

                          final success = await onSave();

                          if (!context.mounted) {
                            return;
                          }

                          if (success) {
                            Navigator.pop(sheetContext);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // CONFIG HEADER
  // ============================================================

  Widget _buildConfigHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onClose,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42.w,
          height: 42.h,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 21.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          onPressed: onClose,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            Icons.close_rounded,
            size: 21.sp,
          ),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  // ============================================================
  // CONFIG SECTION
  // ============================================================

  Widget _buildConfigSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 9.h),
          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // NORMAL CONFIG FIELD
  // ============================================================

  Widget _buildConfigField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 14.sp,
        ),
        decoration: _configInputDecoration(label: label),
      ),
    );
  }

  // ============================================================
  // SECRET FIELD
  // ============================================================

  Widget _buildSecretField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextField(
        controller: controller,
        obscureText: true,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 14.sp,
        ),
        decoration: _configInputDecoration(
          label: label,
          hintText: '••••••••',
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _configInputDecoration({
    required String label,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: AppColors.background,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 14.h,
      ),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        fontSize: 12.5.sp,
        color: AppColors.textSecondary,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary.withValues(alpha: 0.55),
        letterSpacing: 1,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: AppColors.border,
          width: 1.w,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: AppColors.border,
          width: 1.w,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 1.2.w,
        ),
      ),
    );
  }

  // ============================================================
  // ENABLE SWITCH
  // ============================================================

  Widget _buildConfigSwitch({
    required String title,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 62.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.border,
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value ? 'Active' : 'Disabled',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.5.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONFIG SAVE BUTTON
  // ============================================================

  Widget _buildConfigSaveButton({
    required String label,
    required bool isSaving,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11.r),
          ),
        ),
        child: isSaving
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge({required bool connected}) {
    final Color background = connected
        ? AppColors.successLight
        : const Color(0xFFFFE8EB);

    final Color foreground = connected
        ? AppColors.success
        : AppColors.error;

    return Container(
      height: 27.h,
      padding: EdgeInsets.symmetric(horizontal: 9.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            connected ? 'Connected' : 'Not Connected',
            style: AppTextStyles.captionMedium.copyWith(
              fontSize: 10.5.sp,
              color: foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NORMAL SETTINGS CARD
  // ============================================================

  Widget _buildSettingsCard({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          height: 84.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFF0F2F6),
              width: 0.7.w,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  size: 26.sp,
                  color: iconColor,
                ),
              ),
              SizedBox(width: 18.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 25.sp,
                color: const Color(0xFF718096),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
            side: BorderSide(
              color: AppColors.border,
              width: 0.7.w,
            ),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52.w,
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.w,
                    ),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 25.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'Logout',
                  style: AppTextStyles.heading3.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Are you sure you want to sign out from your account?',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44.h,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(
                              color: AppColors.border,
                              width: 1.w,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11.r),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 44.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext);

                            final authController =
                                Get.find<AuthController>();

                            await authController.logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11.r),
                            ),
                          ),
                          child: Text(
                            'Logout',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
