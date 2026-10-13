import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

              padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 3.h),

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



                    ],

                  ),



               SizedBox(height: 10.h),



                  _buildProfileList(profiles),



           SizedBox(height: 24.h),



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

     SizedBox(width: 7.w),

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

        borderRadius: BorderRadius.circular(10.r),

        border: Border.all(color: const Color(0xFFE5E7EB)),

      ),

      child: Column(

        children: [

          for (int i = 0; i < profiles.length; i++) ...[

            _buildProfileItem(profiles[i]),

            if (i != profiles.length - 1)

               Divider(height: 1.h, indent: 56.w, color: Color(0xFFE5E7EB)),

          ],

        ],

      ),

    );

  }



  // ===========================================================================

  // PROFILE ITEM

  // ===========================================================================



  // Widget _buildAddProfileTopButton() {

  //   return SizedBox(

  //     height: 36.h,

  //     child: OutlinedButton.icon(

  //       onPressed: controller.isSaving ? null : _showAddProfileScreen,

  //       icon: const Icon(Icons.add_rounded, size: 17.sp),

  //       label: const Text('Add Profile'),

  //       style: OutlinedButton.styleFrom(

  //         foregroundColor: AppColors.primary,

  //         side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),

  //         padding: EdgeInsets.symmetric(horizontal: 12.w),

  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),

  //       ),

  //     ),

  //   );

  // }



  Widget _buildProfileItem(UserProfileModel userProfile) {

    final profile = userProfile.profile;



    final isSelected = controller.selectedProfile?.id == profile.id;



    return Material(

      color: Colors.transparent,

      child: InkWell(

        onTap: () => _selectProfile(userProfile),

        child: Padding(

          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),

          child: Row(

            children: [

              Container(

                width: 34.w,

                height: 34.h,

                decoration: BoxDecoration(

                  color: AppColors.primary.withValues(alpha: 0.08),

                  borderRadius: BorderRadius.circular(8.r),

                ),

                child: Icon(

                  Icons.person_outline_rounded,

                  size: 18.sp,

                  color: AppColors.primary,

                ),

              ),



           SizedBox(width: 10.w),



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

                           SizedBox(width: 6.w),

                          _buildSmallBadge('Owner'),

                        ],

                      ],

                    ),



                SizedBox(height: 2.h),



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

                  size: 20.sp,

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



         SizedBox(height: 8.h),



        Container(

          width: double.infinity,

          padding: EdgeInsets.all(14.r),

          decoration: BoxDecoration(

            color: AppColors.surface,

            borderRadius: BorderRadius.circular(10.r),

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

                        SizedBox(height: 2.h),

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



           SizedBox(height: 14.h),



         Divider(height: 1.h, color: Color(0xFFE5E7EB)),



               SizedBox(height: 14.h),



              // ---------------------------------------------------------------

              // BASIC DETAILS

              // ---------------------------------------------------------------

              _buildInfoRow(label: 'Profile ID', value: profile.id),



              SizedBox(height: 9.h),



              _buildInfoRow(label: 'Slug', value: profile.slug),



      SizedBox(height: 16.h),



              // ---------------------------------------------------------------

              // SYSTEM PROMPT

              // ---------------------------------------------------------------

              Text(

                'System Prompt',

                style: AppTextStyles.bodySmall.copyWith(

                  fontWeight: FontWeight.w600,

                ),

              ),



           SizedBox(height: 6.h),



              Container(

                width: double.infinity,

                padding: EdgeInsets.all(10.r),

                decoration: BoxDecoration(

                  color: AppColors.background,

                  borderRadius: BorderRadius.circular(8.r),

                ),

                child: Text(

                  profile.systemPrompt.isNotEmpty

                      ? profile.systemPrompt

                      : 'No system prompt configured.',

                  style: AppTextStyles.captionMedium.copyWith(

                    color: AppColors.textSecondary,

                    height: 1.4.h,

                  ),

                ),

              ),



               SizedBox(height: 18.h),



              // ---------------------------------------------------------------

              // INTEGRATIONS

              // ---------------------------------------------------------------

              Text(

                'Integrations',

                style: AppTextStyles.bodySmall.copyWith(

                  fontWeight: FontWeight.w600,

                ),

              ),



              SizedBox(height: 7.h),



              _buildIntegrationRow(

                icon: Icons.chat_bubble_outline_rounded,

                iconColor: AppColors.whatsapp,

                title: 'WhatsApp Business',

                enabled: controller.whatsappEnabled,

                value: controller.whatsappPhoneNumberId,

              ),


 SizedBox(height: 6.h),



              _buildIntegrationRow(

                icon: Icons.camera_alt_outlined,

                iconColor: const Color(0xFFE1306C),

                title: 'Instagram',

                enabled: controller.instagramIsEnabled,

                value: controller.instagramAccountId,

              ),



             SizedBox(height: 16.h),



              // ---------------------------------------------------------------

              // ACTIONS

              // ---------------------------------------------------------------

              Row(

                children: [

                  Expanded(

                    child: OutlinedButton.icon(

                      onPressed: _showEditProfileScreen,

                      icon:  Icon(Icons.edit_outlined, size: 17.sp),

                      label: const Text('Edit Profile'),

                      style: OutlinedButton.styleFrom(

                        foregroundColor: AppColors.primary,

                        side: BorderSide(color: AppColors.primary),

                        padding: EdgeInsets.symmetric(vertical: 11.h),

                        shape: RoundedRectangleBorder(

                          borderRadius: BorderRadius.circular(8.r),

                        ),

                      ),

                    ),

                  ),



                 SizedBox(width: 8.w),



                  IconButton(

                    onPressed: controller.isDeleting

                        ? null

                        : () => _showDeleteDialog(profile.id),

                    tooltip: 'Delete profile',

                    style: IconButton.styleFrom(

                      foregroundColor: AppColors.error,

                      backgroundColor: AppColors.error.withValues(alpha: 0.06),

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(8.r),

                      ),

                    ),

                    icon: controller.isDeleting

                        ? SizedBox(width: 18.w,

                            height: 18.h,

                            child: CircularProgressIndicator(strokeWidth: 2.r),

                          )

                        :  Icon(Icons.delete_outline_rounded, size: 19.sp),

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

        SizedBox(width: 82.w,

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

      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),

      decoration: BoxDecoration(

        color: AppColors.background,

        borderRadius: BorderRadius.circular(8.r),

      ),

      child: Row(

        children: [

          Icon(icon, size: 18.sp, color: iconColor),



       SizedBox(width: 9.w),



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

                SizedBox(height: 1.h),

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



  // Widget _buildAddProfileButton() {

  //   return SizedBox(

  //     width: double.infinity,

  //     height: 44.h,

  //     child: OutlinedButton.icon(

  //       onPressed: controller.isSaving ? null : _showAddProfileScreen,

  //       icon: const Icon(Icons.add_rounded, size: 18.sp),

  //       label: const Text('Add Profile'),

  //       style: OutlinedButton.styleFrom(

  //         foregroundColor: AppColors.primary,

  //         side: BorderSide(color: AppColors.primary),

  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),

  //       ),

  //     ),

  //   );

  // }



  // ===========================================================================

  // ADD PROFILE SHEET

  // ===========================================================================



  // void _showAddProfileScreen() {

  //   final nameController = TextEditingController();

  //   final slugController = TextEditingController();

  //   final promptController = TextEditingController();



  //   bool autoReplyEnabled = false;



  //   showModalBottomSheet(

  //     context: context,

  //     isScrollControlled: true,

  //     backgroundColor: AppColors.surface,

  //     shape: const RoundedRectangleBorder(

  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),

  //     ),

  //     builder: (sheetContext) {

  //       return StatefulBuilder(

  //         builder: (context, setModalState) {

  //           return Padding(

  //             padding: EdgeInsets.only(

  //               left: 18,

  //               right: 18,

  //               top: 18,

  //               bottom: MediaQuery.of(context).viewInsets.bottom + 18,

  //             ),

  //             child: SingleChildScrollView(

  //               child: Column(

  //                 crossAxisAlignment: CrossAxisAlignment.start,

  //                 children: [

  //                   _buildSheetHeader(

  //                     title: 'Add Profile',

  //                     subtitle: 'Create a new bot profile',

  //                   ),



  //                   const SizedBox(height: 18.h),



  //                   _buildTextField(

  //                     controller: nameController,

  //                     label: 'Profile Name',

  //                   ),



  //                   _buildTextField(controller: slugController, label: 'Slug'),



  //                   _buildTextField(

  //                     controller: promptController,

  //                     label: 'System Prompt',

  //                     maxLines: 6,

  //                   ),



  //                   SwitchListTile(

  //                     contentPadding: EdgeInsets.zero,

  //                     title: Text(

  //                       'Auto Reply',

  //                       style: AppTextStyles.bodySmall.copyWith(

  //                         fontWeight: FontWeight.w600,

  //                       ),

  //                     ),

  //                     value: autoReplyEnabled,

  //                     activeThumbColor: AppColors.primary,

  //                     onChanged: (value) {

  //                       setModalState(() {

  //                         autoReplyEnabled = value;

  //                       });

  //                     },

  //                   ),



  //                   const SizedBox(height: 8.h),



  //                   _buildSaveButton(

  //                     isSaving: controller.isSaving,

  //                     label: 'Create Profile',

  //                     onPressed: () async {

  //                       if (nameController.text.trim().isEmpty ||

  //                           slugController.text.trim().isEmpty) {

  //                         return;

  //                       }



  //                       final success = await controller.addProfile(

  //                         name: nameController.text.trim(),

  //                         slug: slugController.text.trim(),

  //                         systemPrompt: promptController.text.trim(),

  //                         autoReplyEnabled: autoReplyEnabled,

  //                       );



  //                       if (!context.mounted) {

  //                         return;

  //                       }



  //                       if (success) {

  //                         Navigator.pop(context);

  //                         await _loadProfiles();

  //                       }

  //                     },

  //                   ),

  //                 ],

  //               ),

  //             ),

  //           );

  //         },

  //       );

  //     },

  //   );

  // }



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



                 SizedBox(height: 18.h),



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



                    SizedBox(height: 8.h),



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

            borderRadius: BorderRadius.circular(12.r),

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

       SizedBox(height: 3.h),

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

      padding: EdgeInsets.only(bottom: 12.h),

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

            borderRadius: BorderRadius.circular(8.r),

            borderSide: BorderSide.none,

          ),

          enabledBorder: OutlineInputBorder(

            borderRadius: BorderRadius.circular(8.r),

            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),

          ),

          focusedBorder: OutlineInputBorder(

            borderRadius: BorderRadius.circular(8.r),

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

      height: 44.h,

      child: ElevatedButton(

        onPressed: isSaving ? null : onPressed,

        style: ElevatedButton.styleFrom(

          backgroundColor: AppColors.primary,

          foregroundColor: Colors.white,

          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),

        ),

        child: isSaving

            ?  SizedBox(width: 18.w,

                height: 18.h,

                child: CircularProgressIndicator(

                  strokeWidth: 2.r,

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

      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),

      decoration: BoxDecoration(

        color: AppColors.primary.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(4.r),

      ),

      child: Text(

        text,

        style: AppTextStyles.captionMedium.copyWith(

          color: AppColors.primary,

          fontWeight: FontWeight.w600,

          fontSize: 9.sp,

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

      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),

      decoration: BoxDecoration(

        color: enabled ? AppColors.successLight : AppColors.background,

        borderRadius: BorderRadius.circular(5.r),

      ),

      child: Text(

        enabled ? activeText : inactiveText,

        style: AppTextStyles.captionMedium.copyWith(

          color: enabled ? AppColors.success : AppColors.textSecondary,

          fontWeight: FontWeight.w600,

          fontSize: 10.sp,

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

        padding: EdgeInsets.all(24.r),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Text('No profiles', style: AppTextStyles.heading3),

            SizedBox(height: 5.h),

            Text(

              'Create a profile to get started.',

              textAlign: TextAlign.center,

              style: AppTextStyles.bodySmall.copyWith(

                color: AppColors.textSecondary,

              ),

            ),

          SizedBox(height: 16.h),

            // SizedBox(

            //   height: 42.h,

            //   child: ElevatedButton.icon(

            //     onPressed: _showAddProfileScreen,

            //     icon: const Icon(Icons.add_rounded, size: 18.sp),

            //     label: const Text('Add Profile'),

            //     style: ElevatedButton.styleFrom(

            //       backgroundColor: AppColors.primary,

            //       foregroundColor: Colors.white,

            //       shape: RoundedRectangleBorder(

            //         borderRadius: BorderRadius.circular(8.r),

            //       ),

            //     ),

            //   ),

            // ),

          ],

        ),

      ),

    );

  }

}
