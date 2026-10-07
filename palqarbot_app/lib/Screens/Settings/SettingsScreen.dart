import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Core/widgets/app_buttons.dart';
import 'package:palqarbot_app/Core/widgets/app_topbar.dart';
import 'package:palqarbot_app/Screens/Auth/Service/auth_controller.dart';
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
    // Get logged-in user and profile ID from /auth/me
    await controller.getUserProfile();

    // Fetch the profile using GET /profiles/{id}
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
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 24),
            child: Column(
              children: [
                // ==========================================================
                // WHATSAPP
                // ==========================================================
                // ==========================================================
                // CONNECTIONS
                // ==========================================================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFF0F2F6),
                      width: 0.7,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildConnectionRow(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: Colors.white,
                        iconBackground: AppColors.whatsapp,
                        title: 'WhatsApp Business',
                        subtitle: controller.hasWhatsappConfig
                            ? 'Phone ID: ${controller.whatsappPhoneNumberId}'
                            : 'Connect to send and receive messages',
                        isConnected: controller.whatsappEnabled,
                        onTap: _showWhatsappConfig,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 1,
                          color: const Color(0xFFF0F2F6),
                        ),
                      ),

                      _buildConnectionRow(
                        icon: Icons.camera_alt_rounded,
                        iconColor: Colors.white,
                        iconBackground: const Color(0xFFE1306C),
                        title: 'Instagram',
                        subtitle: controller.hasInstagramConfig
                            ? 'Account ID: ${controller.instagramAccountId}'
                            : 'Connect to send and receive messages',
                        isConnected: controller.instagramIsEnabled,
                        onTap: _showInstagramConfig,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                const SizedBox(height: 5),

                // ==========================================================
                // PROFILE
                // ==========================================================
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
                      () => ProfileScreen(profileId: controller.profileId),
                    );
                  },
                ),

                const SizedBox(height: 5),

                // ==========================================================
                // COMPANY
                // ==========================================================
                _buildSettingsCard(
                  icon: Icons.business_outlined,
                  iconBackground: const Color(0xFFF1E9FF),
                  iconColor: const Color(0xFF9747FF),
                  title: 'Company',
                  subtitle: controller.profileName.isNotEmpty
                      ? controller.profileName
                      : 'Manage your company name',
                  onTap: () {
                    _showProfileConfig();
                  },
                ),

                const SizedBox(height: 5),

                // ==========================================================
                // LOGOUT
                // ==========================================================
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

  // =========================================================================
  // WHATSAPP CONFIG
  // =========================================================================

  Widget _buildConnectionRow({
    required IconData icon,
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
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 84,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: iconColor),
                ),

                const SizedBox(width: 16),

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
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                _buildStatusBadge(connected: isConnected),

                const SizedBox(width: 8),

                const Icon(
                  Icons.chevron_right_rounded,
                  size: 23,
                  color: Color(0xFF718096),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


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

// =========================================================================
// INSTAGRAM CONFIG
// =========================================================================

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

// =========================================================================
// COMPANY PROFILE CONFIG
// =========================================================================

void _showProfileConfig() {
  final nameController = TextEditingController(
    text: controller.profile?.name ?? '',
  );

  final slugController = TextEditingController(
    text: controller.profile?.slug ?? '',
  );

  final promptController = TextEditingController(
    text: controller.profile?.systemPrompt ?? '',
  );

  bool autoReplyEnabled = controller.autoReplyEnabled;

  _showConfigSheet(
    title: 'Company Profile',
    subtitle: 'Manage your company profile',
    icon: Icons.business_outlined,
    iconColor: const Color(0xFF9747FF),
    sections: [
      _buildConfigSection(
        title: 'Company',
        children: [
          _buildConfigField(
            controller: nameController,
            label: 'Company Name',
          ),
          _buildConfigField(
            controller: slugController,
            label: 'Slug',
          ),
        ],
      ),
      _buildConfigSection(
        title: 'AI Settings',
        children: [
          _buildConfigField(
            controller: promptController,
            label: 'System Prompt',
            maxLines: 6,
          ),
        ],
      ),
    ],
    enableTitle: 'Enable Auto Reply',
    enabled: autoReplyEnabled,
    enableColor: AppColors.primary,
    onEnabledChanged: (value) {
      autoReplyEnabled = value;
    },
    saveLabel: 'Save Profile',
    onSave: () async {
      if (nameController.text.trim().isEmpty) {
        return false;
      }

      return await controller.updateProfile(
        id: controller.profileId,
        name: nameController.text.trim(),
        systemPrompt: promptController.text.trim(),
        autoReplyEnabled: autoReplyEnabled,
      );
    },
  );
}

// =========================================================================
// COMMON CONFIG SHEET
// =========================================================================

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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =====================================================
                    // HEADER
                    // =====================================================

                    _buildConfigHeader(
                      icon: icon,
                      iconColor: iconColor,
                      title: title,
                      subtitle: subtitle,
                      onClose: () {
                        Navigator.pop(sheetContext);
                      },
                    ),

                    const SizedBox(height: 24),

                    // =====================================================
                    // SECTIONS
                    // =====================================================

                    ...sections,

                    const SizedBox(height: 4),

                    // =====================================================
                    // ENABLE
                    // =====================================================

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

                    const SizedBox(height: 20),

                    // =====================================================
                    // SAVE
                    // =====================================================

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

// =========================================================================
// CONFIG HEADER
// =========================================================================

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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 21,
        ),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(width: 8),

      IconButton(
        onPressed: onClose,
        visualDensity: VisualDensity.compact,
        icon: const Icon(
          Icons.close_rounded,
          size: 21,
        ),
        color: AppColors.textSecondary,
      ),
    ],
  );
}

// =========================================================================
// SECTION
// =========================================================================

Widget _buildConfigSection({
  required String title,
  required List<Widget> children,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 9),

        ...children,
      ],
    ),
  );
}

// =========================================================================
// NORMAL FIELD
// =========================================================================

Widget _buildConfigField({
  required TextEditingController controller,
  required String label,
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 14,
      ),
      decoration: _configInputDecoration(
        label: label,
      ),
    ),
  );
}

// =========================================================================
// SECRET FIELD
// =========================================================================

Widget _buildSecretField({
  required TextEditingController controller,
  required String label,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      obscureText: true,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 14,
      ),
      decoration: _configInputDecoration(
        label: label,
        hintText: '••••••••',
      ),
    ),
  );
}

// =========================================================================
// INPUT DECORATION
// =========================================================================

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

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 14,
    ),

    labelStyle: AppTextStyles.bodySmall.copyWith(
      fontSize: 12.5,
      color: AppColors.textSecondary,
    ),

    hintStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textSecondary.withValues(alpha: 0.55),
      letterSpacing: 1,
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: AppColors.border,
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: AppColors.border,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: AppColors.primary,
        width: 1.2,
      ),
    ),
  );
}

// =========================================================================
// ENABLE SWITCH
// =========================================================================

Widget _buildConfigSwitch({
  required String title,
  required bool value,
  required Color activeColor,
  required ValueChanged<bool> onChanged,
}) {
  return Container(
    height: 62,
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
    ),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: AppColors.border,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value ? 'Active' : 'Disabled',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11.5,
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

// =========================================================================
// SAVE BUTTON
// =========================================================================

Widget _buildConfigSaveButton({
  required String label,
  required bool isSaving,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: isSaving ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
      ),
      child: isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
    ),
  );
}





  // =========================================================================
  // STATUS BADGE
  // =========================================================================

  Widget _buildStatusBadge({required bool connected}) {
    final Color background = connected
        ? AppColors.successLight
        : const Color(0xFFFFE8EB);

    final Color foreground = connected ? AppColors.success : AppColors.error;

    return Container(
      height: 27,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 5),

          Text(
            connected ? 'Connected' : 'Not Connected',
            style: AppTextStyles.captionMedium.copyWith(
              fontSize: 10.5,
              color: foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // NORMAL SETTINGS CARD
  // =========================================================================

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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F2F6), width: 0.7),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 26, color: iconColor),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                size: 25,
                color: Color(0xFF718096),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // LOGOUT
  // =========================================================================


void _showLogoutDialog() {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          'Logout',
          style: AppTextStyles.heading3,
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final authController =
                  Get.find<AuthController>();

              await authController.logout();
            },
            child: Text(
              'Logout',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      );
    },
  );
}


}
