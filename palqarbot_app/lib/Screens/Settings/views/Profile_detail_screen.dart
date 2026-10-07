import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Core/widgets/app_topbar.dart';
import 'package:palqarbot_app/Screens/Settings/Model/profile_setting_model.dart';
import 'package:palqarbot_app/Screens/Settings/service/profile_setting_controller.dart';

class ProfileScreen extends StatefulWidget {
  final String profileId;

  const ProfileScreen({super.key, required this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileSettingsController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<ProfileSettingsController>()
        ? Get.find<ProfileSettingsController>()
        : Get.put(ProfileSettingsController());

    _loadProfiles();
  }

  // ===========================================================================
  // LOAD
  // ===========================================================================

  Future<void> _loadProfiles() async {
    final success = await controller.getUserProfile();

    if (!success || controller.profileSettings == null) {
      return;
    }

    final profiles = controller.profileSettings!.userProfiles;

    if (profiles.isEmpty) {
      return;
    }

    UserProfileModel? selected;

    for (final item in profiles) {
      if (item.profile.id == widget.profileId) {
        selected = item;
        break;
      }
    }

    selected ??= profiles.first;

    await controller.getProfile(selected.profile.id);
  }

  // ===========================================================================
  // SELECT PROFILE
  // ===========================================================================

  Future<void> _selectProfile(UserProfileModel userProfile) async {
    if (controller.selectedProfile?.id == userProfile.profile.id) {
      return;
    }

    await controller.getProfile(userProfile.profile.id);
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Profile Details', style: AppTextStyles.heading3)],
        ),
      ),
      body: GetBuilder<ProfileSettingsController>(
        builder: (controller) {
          if (controller.isLoading && controller.profileSettings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final profiles = controller.profileSettings?.userProfiles ?? [];

          if (profiles.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadProfiles,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildSectionTitle(
                        title: 'Profiles',
                        trailing: '${profiles.length}',
                      ),

                      const Spacer(),

                      _buildAddProfileTopButton(),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _buildProfileList(profiles),

                  const SizedBox(height: 24),

                  if (controller.selectedProfile != null)
                    _buildProfileDetails(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // SECTION TITLE
  // ===========================================================================

  Widget _buildSectionTitle({required String title, String? trailing}) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 7),
          Text(
            trailing,
            style: AppTextStyles.captionMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // PROFILE LIST
  // ===========================================================================

  Widget _buildProfileList(List<UserProfileModel> profiles) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < profiles.length; i++) ...[
            _buildProfileItem(profiles[i]),
            if (i != profiles.length - 1)
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // PROFILE ITEM
  // ===========================================================================

  Widget _buildAddProfileTopButton() {
    return SizedBox(
      height: 36,
      child: OutlinedButton.icon(
        onPressed: controller.isSaving ? null : _showAddProfileScreen,
        icon: const Icon(Icons.add_rounded, size: 17),
        label: const Text('Add Profile'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildProfileItem(UserProfileModel userProfile) {
    final profile = userProfile.profile;

    final isSelected = controller.selectedProfile?.id == profile.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectProfile(userProfile),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        if (userProfile.isOwner) ...[
                          const SizedBox(width: 6),
                          _buildSmallBadge('Owner'),
                        ],
                      ],
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '@${profile.slug}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.captionMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PROFILE DETAILS
  // ===========================================================================

  Widget _buildProfileDetails() {
    final profile = controller.selectedProfile!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title: 'Profile Details'),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------------------
              // NAME
              // ---------------------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${profile.slug}',
                          style: AppTextStyles.captionMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildStatusBadge(
                    profile.autoReplyEnabled,
                    activeText: 'Auto Reply',
                    inactiveText: 'Auto Reply Off',
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              const SizedBox(height: 14),

              // ---------------------------------------------------------------
              // BASIC DETAILS
              // ---------------------------------------------------------------
              _buildInfoRow(label: 'Profile ID', value: profile.id),

              const SizedBox(height: 9),

              _buildInfoRow(label: 'Slug', value: profile.slug),

              const SizedBox(height: 16),

              // ---------------------------------------------------------------
              // SYSTEM PROMPT
              // ---------------------------------------------------------------
              Text(
                'System Prompt',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  profile.systemPrompt.isNotEmpty
                      ? profile.systemPrompt
                      : 'No system prompt configured.',
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ---------------------------------------------------------------
              // INTEGRATIONS
              // ---------------------------------------------------------------
              Text(
                'Integrations',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 7),

              _buildIntegrationRow(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: AppColors.whatsapp,
                title: 'WhatsApp Business',
                enabled: controller.whatsappEnabled,
                value: controller.whatsappPhoneNumberId,
              ),

              const SizedBox(height: 6),

              _buildIntegrationRow(
                icon: Icons.camera_alt_outlined,
                iconColor: const Color(0xFFE1306C),
                title: 'Instagram',
                enabled: controller.instagramIsEnabled,
                value: controller.instagramAccountId,
              ),

              const SizedBox(height: 16),

              // ---------------------------------------------------------------
              // ACTIONS
              // ---------------------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showEditProfileScreen,
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton(
                    onPressed: controller.isDeleting
                        ? null
                        : () => _showDeleteDialog(profile.id),
                    tooltip: 'Delete profile',
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.error,
                      backgroundColor: AppColors.error.withValues(alpha: 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: controller.isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline_rounded, size: 19),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // INFO ROW
  // ===========================================================================

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: AppTextStyles.captionMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // INTEGRATION ROW
  // ===========================================================================

  Widget _buildIntegrationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool enabled,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.captionMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (enabled && value.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Text(
            enabled ? 'Connected' : 'Not connected',
            style: AppTextStyles.captionMedium.copyWith(
              color: enabled ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ADD PROFILE
  // ===========================================================================

  Widget _buildAddProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: controller.isSaving ? null : _showAddProfileScreen,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Add Profile'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // ===========================================================================
  // ADD PROFILE SHEET
  // ===========================================================================

  void _showAddProfileScreen() {
    final nameController = TextEditingController();
    final slugController = TextEditingController();
    final promptController = TextEditingController();

    bool autoReplyEnabled = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSheetHeader(
                      title: 'Add Profile',
                      subtitle: 'Create a new bot profile',
                    ),

                    const SizedBox(height: 18),

                    _buildTextField(
                      controller: nameController,
                      label: 'Profile Name',
                    ),

                    _buildTextField(controller: slugController, label: 'Slug'),

                    _buildTextField(
                      controller: promptController,
                      label: 'System Prompt',
                      maxLines: 6,
                    ),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Auto Reply',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: autoReplyEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) {
                        setModalState(() {
                          autoReplyEnabled = value;
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    _buildSaveButton(
                      isSaving: controller.isSaving,
                      label: 'Create Profile',
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty ||
                            slugController.text.trim().isEmpty) {
                          return;
                        }

                        final success = await controller.addProfile(
                          name: nameController.text.trim(),
                          slug: slugController.text.trim(),
                          systemPrompt: promptController.text.trim(),
                          autoReplyEnabled: autoReplyEnabled,
                        );

                        if (!context.mounted) {
                          return;
                        }

                        if (success) {
                          Navigator.pop(context);
                          await _loadProfiles();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // EDIT PROFILE
  // ===========================================================================

  void _showEditProfileScreen() {
    final profile = controller.selectedProfile;

    if (profile == null) {
      return;
    }

    final nameController = TextEditingController(text: profile.name);

    final slugController = TextEditingController(text: profile.slug);

    final promptController = TextEditingController(text: profile.systemPrompt);

    bool autoReplyEnabled = profile.autoReplyEnabled;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSheetHeader(
                      title: 'Edit Profile',
                      subtitle: 'Update profile information',
                    ),

                    const SizedBox(height: 18),

                    _buildTextField(
                      controller: nameController,
                      label: 'Profile Name',
                    ),

                    _buildTextField(controller: slugController, label: 'Slug'),

                    _buildTextField(
                      controller: promptController,
                      label: 'System Prompt',
                      maxLines: 6,
                    ),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Auto Reply',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: autoReplyEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) {
                        setModalState(() {
                          autoReplyEnabled = value;
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    _buildSaveButton(
                      isSaving: controller.isSaving,
                      label: 'Update Profile',
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty ||
                            slugController.text.trim().isEmpty) {
                          return;
                        }

                        final success = await controller.updateProfile(
                          id: profile.id,
                          name: nameController.text.trim(),
                          systemPrompt: promptController.text.trim(),
                          autoReplyEnabled: autoReplyEnabled,
                        );

                        if (!context.mounted) {
                          return;
                        }

                        if (success) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // DELETE
  // ===========================================================================

  void _showDeleteDialog(String profileId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Delete Profile?', style: AppTextStyles.heading3),
          content: Text(
            'This profile will be permanently deleted.',
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
              onPressed: controller.isDeleting
                  ? null
                  : () async {
                      Navigator.pop(dialogContext);

                      final success = await controller.deleteProfile(profileId);

                      if (!mounted) {
                        return;
                      }

                      if (success) {
                        await _loadProfiles();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to delete profile'),
                          ),
                        );
                      }
                    },
              child: Text(
                'Delete',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // SHEET HEADER
  // ===========================================================================

  Widget _buildSheetHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading3),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TEXT FIELD
  // ===========================================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SAVE BUTTON
  // ===========================================================================

  Widget _buildSaveButton({
    required bool isSaving,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // ===========================================================================
  // BADGES
  // ===========================================================================

  Widget _buildSmallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.captionMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    bool enabled, {
    required String activeText,
    required String inactiveText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? AppColors.successLight : AppColors.background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        enabled ? activeText : inactiveText,
        style: AppTextStyles.captionMedium.copyWith(
          color: enabled ? AppColors.success : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY
  // ===========================================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No profiles', style: AppTextStyles.heading3),
            const SizedBox(height: 5),
            Text(
              'Create a profile to get started.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 42,
              child: ElevatedButton.icon(
                onPressed: _showAddProfileScreen,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
