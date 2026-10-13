import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/widgets/app_toast.dart';
import 'package:palqarbot_app/Screens/Settings/service/profile_setting_controller.dart';

class InboxChannelConnection {
  InboxChannelConnection._();

  static const Color _heading = Color(0xFF17213D);
  static const Color _secondary = Color(0xFF7B8BA7);
  static const Color _border = Color(0xFFE3EAF4);
  static const Color _blue = Color(0xFF1685F8);

  static bool _isShowingWhatsappOptions = false;

  static ProfileSettingsController get _controller {
    if (Get.isRegistered<ProfileSettingsController>()) {
      return Get.find<ProfileSettingsController>();
    }

    return Get.put(ProfileSettingsController());
  }

  static Future<bool> _ensureProfile() async {
    final controller = _controller;

    if (controller.profileId.isEmpty || controller.selectedProfile == null) {
      await controller.loadSettings();
    }

    if (controller.profileId.isNotEmpty && controller.selectedProfile != null) {
      return true;
    }
    AppToast.showToast('Please create or select a business profile first.');

    return false;
  }

  static Future<bool> _showDisconnectConfirmation() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        titlePadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 8.h),
        contentPadding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
        actionsPadding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
        title: Column(
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.link_off_rounded,
                color: const Color(0xFFDC2626),
                size: 28.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Disconnect WhatsApp?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _heading,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to disconnect your WhatsApp account? '
          'Your bot will stop managing conversations through this connection.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _secondary, fontSize: 13.sp, height: 1.6),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44.h,
                  child: OutlinedButton(
                    onPressed: () => Get.back<bool>(result: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _heading,
                      side: const BorderSide(color: Color(0xFFE3EAF4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
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
                  child: ElevatedButton.icon(
                    onPressed: () => Get.back<bool>(result: true),
                    icon: Icon(Icons.link_off_rounded, size: 17.sp),
                    label: Text(
                      'Disconnect',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: true,
    );

    return result == true;
  }

  static Future<void> connectWhatsApp() async {
    if (_isShowingWhatsappOptions) return;

    _isShowingWhatsappOptions = true;

    try {
      final hasProfile = await _ensureProfile();
      if (!hasProfile) return;

      final controller = _controller;

      if (controller.isOpenWaConnected) {
        final shouldDisconnect = await _showDisconnectConfirmation();

        if (!shouldDisconnect) return;

        final disconnected = await controller.deactivateOpenWa();

        if (!disconnected) {
          AppToast.showToast(
            'Unable to disconnect WhatsApp. Please try again.',
          );
          return;
        }

        controller.isOpenWaConnected = false;
        controller.isOpenWaPolling = false;
        controller.openWaQrCode = '';
        controller.openWaConnectedNumber = '';
        controller.openWaPairingCode = '';
        controller.update();

        await controller.loadSettings();

        AppToast.showToast('WhatsApp disconnected successfully.');
        return;
      }

      // If not connected, show the existing connection options.
      final selected = await Get.dialog<String>(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Connect WhatsApp',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _heading,
              fontSize: 18.sp,
            ),
          ),
          content: Text(
            'Choose how you want to connect your WhatsApp account.',
            style: TextStyle(color: _secondary, height: 1.5, fontSize: 14.sp),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.back<String>(result: 'cloud'),
                icon: Icon(Icons.cloud_outlined, size: 20.sp),
                label: Text(
                  'Connect via Cloud API',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.back<String>(result: 'qr'),
                icon: Icon(Icons.qr_code_2_rounded, size: 20.sp),
                label: Text(
                  'Connect WhatsApp',
                  style: TextStyle(fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: true,
      );

      if (selected == null) return;

      switch (selected) {
        case 'cloud':
          await _showWhatsappCloudApiForm();
          break;
        case 'qr':
          await _startWhatsappQrFlow();
          break;
      }
    } finally {
      _isShowingWhatsappOptions = false;
    }
  }

  static Future<void> connectInstagram() async {
    if (!await _ensureProfile()) return;

    await _showInstagramConfigForm();
  }

  // ---------------------------------------------------------------------------
  // WHATSAPP CLOUD API CONFIGURATION
  // ---------------------------------------------------------------------------

  static Future<void> _showWhatsappCloudApiForm() async {
    final controller = _controller;

    if (controller.profileId.isEmpty) {
      await controller.loadSettings();
    }

    final profileId = controller.profileId;

    if (profileId.isEmpty) {
      _showProfileUnavailable();
      return;
    }

    final fields = [
      const _ConfigField(
        label: 'Phone Number ID',
        hint: 'Enter your Meta phone number ID',
        icon: Icons.phone_android_rounded,
      ),
      const _ConfigField(
        label: 'Business Account ID',
        hint: 'Enter your WhatsApp Business Account ID',
        icon: Icons.business_rounded,
      ),
      const _ConfigField(
        label: 'Access Token',
        hint: 'Paste your permanent access token',
        icon: Icons.key_rounded,
        obscure: true,
      ),
      const _ConfigField(
        label: 'App Secret',
        hint: 'Enter your Meta app secret',
        icon: Icons.lock_outline_rounded,
        obscure: true,
      ),
      const _ConfigField(
        label: 'Verify Token',
        hint: 'Enter your webhook verify token',
        icon: Icons.verified_user_outlined,
        obscure: true,
      ),
    ];

    final saved = await _showChannelConfigDialog(
      title: 'WhatsApp Cloud API',
      subtitle:
          'Connect your WhatsApp Business account to manage conversations.',
      channelName: 'WhatsApp',
      icon: Icons.chat_rounded,
      iconColor: const Color(0xFF168C58),
      iconBackground: const Color(0xFFE7F7EE),
      fields: fields,
      onSave: (values, enabled) {
        return controller.saveWhatsappConfig(
          profileId: profileId,
          phoneNumberId: values[0],
          businessAccountId: values[1],
          accessToken: values[2],
          appSecret: values[3],
          verifyToken: values[4],
          enabled: enabled,
        );
      },
    );

    if (saved == true) {
      await controller.loadSettings();

      _showSuccess(
        'Configuration saved',
        'WhatsApp Cloud API has been configured successfully.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // INSTAGRAM CONFIGURATION
  // ---------------------------------------------------------------------------

  static Future<void> _showInstagramConfigForm() async {
    final controller = _controller;

    if (controller.profileId.isEmpty) {
      await controller.loadSettings();
    }

    final profileId = controller.profileId;

    if (profileId.isEmpty) {
      _showProfileUnavailable();
      return;
    }

    final fields = [
      const _ConfigField(
        label: 'Instagram Account ID',
        hint: 'Enter your Instagram Business Account ID',
        icon: Icons.camera_alt_outlined,
      ),
      const _ConfigField(
        label: 'Access Token',
        hint: 'Paste your Instagram access token',
        icon: Icons.key_rounded,
        obscure: true,
      ),
      const _ConfigField(
        label: 'App Secret',
        hint: 'Enter your Meta app secret',
        icon: Icons.lock_outline_rounded,
        obscure: true,
      ),
      const _ConfigField(
        label: 'Verify Token',
        hint: 'Enter your webhook verify token',
        icon: Icons.verified_user_outlined,
        obscure: true,
      ),
    ];

    final saved = await _showChannelConfigDialog(
      title: 'Instagram Business',
      subtitle:
          'Connect your Instagram professional account to manage customer DMs.',
      channelName: 'Instagram',
      icon: Icons.camera_alt_rounded,
      iconColor: const Color(0xFFC13584),
      iconBackground: const Color(0xFFFFE8F1),
      fields: fields,
      onSave: (values, enabled) {
        return controller.saveInstagramConfig(
          profileId: profileId,
          accountId: values[0],
          accessToken: values[1],
          appSecret: values[2],
          verifyToken: values[3],
          enabled: enabled,
        );
      },
    );

    if (saved == true) {
      await controller.loadSettings();

      _showSuccess(
        'Configuration saved',
        'Instagram has been configured successfully.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SHARED CONFIGURATION DIALOG
  // ---------------------------------------------------------------------------

  static Future<bool?> _showChannelConfigDialog({
    required String title,
    required String subtitle,
    required String channelName,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required List<_ConfigField> fields,
    required Future<bool> Function(List<String> values, bool enabled) onSave,
  }) async {
    final textControllers = List.generate(
      fields.length,
      (_) => TextEditingController(),
    );

    bool enabled = true;
    bool submitting = false;
    final visibleFields = <int>{};

    try {
      return await Get.bottomSheet<bool>(
        StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final screenHeight = MediaQuery.of(sheetContext).size.height;
            final screenWidth = MediaQuery.of(sheetContext).size.width;

            return Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: screenHeight * 0.80),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    SizedBox(height: 8.h),
                    Container(
                      width: 32.w,
                      height: 3.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7DFEA),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),

                    // Compact header
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
                      child: Row(
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: iconBackground,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(icon, color: iconColor, size: 20.sp),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _heading,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    height: 1.3,
                                    color: _secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            constraints: BoxConstraints(
                              minWidth: 32.w,
                              minHeight: 32.h,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: submitting
                                ? null
                                : () => Get.back<bool>(result: false),
                            icon: Icon(Icons.close_rounded, size: 19.sp),
                            color: _secondary,
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: _border),

                    // Scrollable form
                    Flexible(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 500 ? 16.w : 20.w,
                          vertical: 12.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.admin_panel_settings_outlined,
                                  size: 15.sp,
                                  color: _blue,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    'API CREDENTIALS',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: _secondary,
                                    ),
                                  ),
                                ),
                                const _RequiredBadge(),
                              ],
                            ),
                            SizedBox(height: 12.h),

                            for (int i = 0; i < fields.length; i++) ...[
                              Text(
                                fields[i].label,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _heading,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              TextField(
                                controller: textControllers[i],
                                obscureText:
                                    fields[i].obscure &&
                                    !visibleFields.contains(i),
                                autocorrect: false,
                                enableSuggestions: !fields[i].obscure,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: _heading,
                                ),
                                decoration: InputDecoration(
                                  hintText: fields[i].hint,
                                  hintStyle: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  prefixIcon: Icon(
                                    fields[i].icon,
                                    size: 17.sp,
                                    color: _secondary,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 38.w,
                                    minHeight: 38.h,
                                  ),
                                  suffixIcon: fields[i].obscure
                                      ? IconButton(
                                          visualDensity: VisualDensity.compact,
                                          constraints: BoxConstraints(
                                            minWidth: 34.w,
                                            minHeight: 34.h,
                                          ),
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            setSheetState(() {
                                              if (!visibleFields.add(i)) {
                                                visibleFields.remove(i);
                                              }
                                            });
                                          },
                                          icon: Icon(
                                            visibleFields.contains(i)
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 17.sp,
                                            color: _secondary,
                                          ),
                                        )
                                      : null,
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 10.h,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9.r),
                                    borderSide: const BorderSide(
                                      color: _border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9.r),
                                    borderSide: const BorderSide(
                                      color: _border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9.r),
                                    borderSide: BorderSide(
                                      color: _blue,
                                      width: 1.2.w,
                                    ),
                                  ),
                                ),
                              ),
                              if (i != fields.length - 1)
                                SizedBox(height: 10.h),
                            ],

                            SizedBox(height: 14.h),

                            // Enable channel
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: enabled
                                    ? const Color(0xFFF0FAF4)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: enabled
                                      ? const Color(0xFFC7EBD4)
                                      : _border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    enabled
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.pause_circle_outline_rounded,
                                    color: enabled
                                        ? const Color(0xFF168C58)
                                        : _secondary,
                                    size: 21.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Enable $channelName',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                            color: _heading,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          enabled
                                              ? 'Channel enabled after saving.'
                                              : 'Save without enabling.',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            height: 1.3,
                                            color: _secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch.adaptive(
                                      value: enabled,
                                      activeTrackColor: AppColors.primary,
                                      onChanged: submitting
                                          ? null
                                          : (value) {
                                              setSheetState(() {
                                                enabled = value;
                                              });
                                            },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 10.h),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 13.sp,
                                  color: _secondary,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    'Verify your credentials and webhook settings in Meta before connecting.',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      height: 1.35,
                                      color: _secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 1, color: _border),

                    // Footer
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 9.h, 16.w, 10.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 38.h,
                              child: OutlinedButton(
                                onPressed: submitting
                                    ? null
                                    : () => Get.back<bool>(result: false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _heading,
                                  side: const BorderSide(color: _border),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.r),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 38.h,
                              child: ElevatedButton.icon(
                                onPressed: submitting
                                    ? null
                                    : () async {
                                        final values = textControllers
                                            .map((c) => c.text.trim())
                                            .toList();

                                        if (values.any((v) => v.isEmpty)) {
                                          AppToast.showToast(
                                            'Please complete all credential fields.',
                                          );
                                          return;
                                        }

                                        setSheetState(() {
                                          submitting = true;
                                        });

                                        var success = false;

                                        try {
                                          success = await onSave(
                                            values,
                                            enabled,
                                          );
                                        } catch (error, stackTrace) {
                                          debugPrint(
                                            'CHANNEL CONFIG SAVE ERROR: $error',
                                          );
                                          debugPrintStack(
                                            stackTrace: stackTrace,
                                          );
                                        }

                                        if (!sheetContext.mounted) return;

                                        if (success) {
                                          Get.back<bool>(result: true);
                                        } else {
                                          setSheetState(() {
                                            submitting = false;
                                          });
                                          AppToast.showToast(
                                            'Unable to save the configuration. '
                                            'Check your credentials and try again.',
                                          );
                                        }
                                      },
                                icon: submitting
                                    ? SizedBox(
                                        width: 14.w,
                                        height: 14.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.w,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 16.sp,
                                      ),
                                label: Text(
                                  submitting
                                      ? 'Saving...'
                                      : 'Save configuration',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11.5.sp),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _blue,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: _blue.withValues(
                                    alpha: 0.7,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.r),
                                  ),
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
      );
    } finally {
      for (final textController in textControllers) {
        textController.dispose();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // WHATSAPP QR CONNECTION
  // ---------------------------------------------------------------------------
  static Future<void> _startWhatsappQrFlow() async {
    final controller = _controller;

    if (controller.profileId.isEmpty) {
      await controller.loadSettings();
    }

    if (controller.profileId.isEmpty) {
      _showProfileUnavailable();
      return;
    }

    // Show loading dialog while connecting.
    Get.dialog<void>(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 42.w,
                  height: 42.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.w,
                    color: _blue,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Preparing WhatsApp connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _heading,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please wait while we connect to WhatsApp and generate your QR code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _secondary,
                    fontSize: 12.sp,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    bool success = false;

    try {
      final results = await Future.wait<bool>([
        controller.connectOpenWa(),
        Future.delayed(const Duration(seconds: 2), () => true),
      ]);

      success = results.first;
    } catch (error, stackTrace) {
      debugPrint('WHATSAPP CONNECTION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (Get.isDialogOpen == true) {
        Get.back<void>();
      }
    }

    if (!success) return;

    // Keep a reference to the exact QR dialog route.
    Route<dynamic>? qrDialogRoute;
    NavigatorState? qrDialogNavigator;

    final action = await Get.dialog<String>(
      Builder(
        builder: (dialogContext) {
          qrDialogRoute ??= ModalRoute.of(dialogContext);
          qrDialogNavigator ??= Navigator.of(dialogContext);

          return GetBuilder<ProfileSettingsController>(
            builder: (c) {
              return AlertDialog(
                insetPadding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 20.h,
                ),
                titlePadding: EdgeInsets.fromLTRB(18.w, 14.h, 12.w, 6.h),
                contentPadding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 4.h),
                actionsPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                  side: const BorderSide(color: _border),
                ),
                title: Row(
                  children: [
                    Container(
                      width: 34.w,
                      height: 34.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        color: _blue,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Connect WhatsApp',
                        style: TextStyle(
                          color: _heading,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: BoxConstraints(
                        minWidth: 30.w,
                        minHeight: 30.h,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => Get.back<String>(),
                      icon: Icon(Icons.close_rounded, size: 19.sp),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 290.w,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (c.isOpenWaConnected) ...[
                          Icon(
                            Icons.check_circle_rounded,
                            color: const Color(0xFF0BAA78),
                            size: 54.sp,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'WhatsApp is connected',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _heading,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (c.openWaConnectedNumber.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(
                              'Connected number: '
                              '${c.openWaConnectedNumber}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _secondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                          SizedBox(height: 14.h),
                          _ConnectionStatus(
                            connected: true,
                            polling: false,
                            status: c.openWaStatusLabel,
                          ),
                          SizedBox(height: 10.h),
                        ] else ...[
                          Text(
                            'Scan the QR code using WhatsApp → Linked Devices.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _secondary,
                              fontSize: 12.sp,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            width: 176.w,
                            height: 176.h,
                            padding: EdgeInsets.all(7.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: _border),
                            ),
                            child: _buildOpenWaQr(c.openWaQrCode),
                          ),
                          SizedBox(height: 8.h),
                          TextButton.icon(
                            onPressed: () {
                              Get.back<String>(result: 'phone');
                            },
                            icon: Icon(
                              Icons.phone_android_rounded,
                              size: 16.sp,
                            ),
                            label: Text(
                              'Use phone number instead',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: _blue,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          _ConnectionStatus(
                            connected: false,
                            polling: c.isOpenWaPolling,
                            status: c.openWaStatusLabel,
                          ),
                          if (c.isOpenWaPolling) ...[
                            SizedBox(height: 6.h),
                            Text(
                              'Waiting for WhatsApp to connect...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: _secondary,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (c.isOpenWaConnected)
                    SizedBox(
                      height: 36.h,
                      child: ElevatedButton(
                        onPressed: c.isOpenWaActivating
                            ? null
                            : () async {
                                final shouldDisconnect =
                                    await _showDisconnectConfirmation();

                                if (shouldDisconnect != true) return;

                                final disconnected = await c.deactivateOpenWa();

                                if (!disconnected) {
                                  AppToast.showToast(
                                    'Unable to disconnect WhatsApp. '
                                    'Please try again.',
                                  );
                                  return;
                                }

                                // Reset the WhatsApp connection state.
                                c.isOpenWaConnected = false;
                                c.isOpenWaPolling = false;
                                c.openWaQrCode = '';
                                c.openWaConnectedNumber = '';
                                c.openWaPairingCode = '';
                                c.update();

                                // Remove the exact QR dialog route rather
                                // than popping whichever route is on top.
                                final route = qrDialogRoute;
                                final navigator = qrDialogNavigator;

                                if (route != null &&
                                    navigator != null &&
                                    route.isActive) {
                                  navigator.removeRoute(route);
                                }

                                AppToast.showToast(
                                  'WhatsApp disconnected successfully.',
                                );

                                await c.loadSettings();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                        ),
                        child: Text(
                          'Disconnect',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    )
                  else ...[
                    TextButton(
                      onPressed: c.isOpenWaActivating || c.isOpenWaPolling
                          ? null
                          : () => c.fetchOpenWaStatus(),
                      child: Text('Refresh', style: TextStyle(fontSize: 12.sp)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 36.h,
                          child: ElevatedButton(
                            onPressed: c.isOpenWaActivating || c.isOpenWaPolling
                                ? null
                                : () async {
                                    await c.activateOpenWa();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9.r),
                              ),
                            ),
                            child: c.isOpenWaActivating
                                ? SizedBox(
                                    width: 15.w,
                                    height: 15.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.w,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Activate',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Note: Scan the QR code first, then tap Activate.',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.red, fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
      barrierDismissible: false,
    );

    if (action == 'phone') {
      await _startWhatsappPhoneFlow();
      return;
    }

    await controller.loadSettings();
  }
  // ---------------------------------------------------------------------------
  // WHATSAPP PHONE-NUMBER CONNECTION
  // ---------------------------------------------------------------------------

  static Future<void> _startWhatsappPhoneFlow() async {
    final controller = _controller;

    if (controller.profileId.isEmpty) {
      await controller.loadSettings();
    }

    if (controller.profileId.isEmpty) {
      _showProfileUnavailable();
      return;
    }

    // Step 1: Ask for the WhatsApp phone number.
    final phoneNumber = await Get.dialog<String>(
      const _WhatsappPhoneNumberDialog(),
      barrierDismissible: false,
    );

    if (phoneNumber == null || phoneNumber.isEmpty) return;

    // Step 2: Show loading while requesting the pairing code.
    Get.dialog<void>(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 42.w,
                  height: 42.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.w,
                    color: _blue,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Generating pairing code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _heading,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Connecting to WhatsApp. Please wait while we generate your pairing code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _secondary,
                    fontSize: 12.sp,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    bool success = false;

    try {
      // Keep the loading indicator visible for at least 2 seconds.
      // If the API takes longer, continue showing loading until it finishes.
      final results = await Future.wait<bool>([
        controller.connectOpenWaWithPhone(phoneNumber),
        Future.delayed(const Duration(seconds: 2), () => true),
      ]);

      success = results.first;
    } catch (error, stackTrace) {
      debugPrint('WHATSAPP PHONE CONNECTION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      // Close the loading dialog after the request completes.
      if (Get.isDialogOpen == true) {
        Get.back<void>();
      }
    }

    // Step 3: Show an error if the pairing code request failed.
    if (!success) {
      AppToast.showToast(
        'Unable to generate the pairing code. Please try again.',
      );
      return;
    }

    // Step 4: Show the pairing code dialog.
    await _showWhatsappPhonePairingDialog(controller);

    // Step 5: Refresh connection settings.
    await controller.loadSettings();
  }

  static Future<void> _showWhatsappPhonePairingDialog(
    ProfileSettingsController controller,
  ) async {
    Route<dynamic>? pairingDialogRoute;
    NavigatorState? pairingDialogNavigator;
    await Get.dialog<void>(
      Builder(
        builder: (dialogContext) {
          pairingDialogRoute ??= ModalRoute.of(dialogContext);
          pairingDialogNavigator ??= Navigator.of(dialogContext);

          return GetBuilder<ProfileSettingsController>(
            builder: (c) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.phone_android_rounded,
                      color: _blue,
                      size: 22.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Pair WhatsApp',
                        style: TextStyle(
                          color: _heading,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Get.back<void>(),
                      icon: Icon(Icons.close_rounded, size: 22.sp),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 320.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Enter the pairing code in WhatsApp to link your account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _secondary,
                            height: 1.5,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 22.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F2FF),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFFC9E1FF)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'PAIRING CODE',
                                style: TextStyle(
                                  color: _secondary,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              SelectableText(
                                c.openWaPairingCode.isEmpty
                                    ? 'Waiting for code...'
                                    : c.openWaPairingCode,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _heading,
                                  fontSize: 23.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _ConnectionStatus(
                          connected: c.isOpenWaConnected,
                          polling: c.isOpenWaPolling,
                          status: c.openWaStatusLabel,
                        ),
                        if (c.isOpenWaConnected &&
                            c.openWaConnectedNumber.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          Text(
                            'Connected number: ${c.openWaConnectedNumber}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF0BAA78),
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                        SizedBox(height: 12.h),
                        if (!c.isOpenWaConnected)
                          Text(
                            'Open WhatsApp → Linked Devices → Link a Device. '
                            'Choose the phone-number pairing option and enter '
                            'the code above.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _secondary,
                              fontSize: 12.sp,
                              height: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (c.isOpenWaConnected)
                    ElevatedButton.icon(
                      onPressed: c.isOpenWaActivating
                          ? null
                          : () async {
                              final shouldDisconnect =
                                  await _showDisconnectConfirmation();

                              // The confirmation dialog has already closed.
                              if (!shouldDisconnect) return;

                              final disconnected = await c.deactivateOpenWa();

                              if (!disconnected) {
                                AppToast.showToast(
                                  'Unable to disconnect WhatsApp. Please try again.',
                                );
                                return;
                              }

                              c.isOpenWaConnected = false;
                              c.isOpenWaPolling = false;
                              c.openWaQrCode = '';
                              c.openWaConnectedNumber = '';
                              c.openWaPairingCode = '';
                              c.update();

                              // Close only the phone-pairing dialog.
                              final route = pairingDialogRoute;
                              final navigator = pairingDialogNavigator;

                              if (route != null &&
                                  navigator != null &&
                                  route.isActive) {
                                navigator.removeRoute(route);
                              }

                              AppToast.showToast(
                                'WhatsApp disconnected successfully.',
                              );

                              await c.loadSettings();
                            },

                      icon: Icon(Icons.link_off_rounded, size: 18.sp),
                      label: Text(
                        'Disconnect',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else ...[
                    TextButton(
                      onPressed: c.isOpenWaPolling || c.isOpenWaActivating
                          ? null
                          : () => c.fetchOpenWaStatus(),
                      child: Text(
                        'Refresh status',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: c.isOpenWaActivating || c.isOpenWaPolling
                              ? null
                              : () async {
                                  final activated = await c.activateOpenWa();

                                  if (activated) {
                                    Get.back<void>();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                          ),
                          child: c.isOpenWaActivating
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.w,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Activate',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Enter the pairing code in WhatsApp, then tap Activate.',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.red, fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  // ---------------------------------------------------------------------------
  // QR IMAGE
  // ---------------------------------------------------------------------------

  static Widget _buildOpenWaQr(String qrCode) {
    if (qrCode.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2_rounded, size: 64.sp, color: _secondary),
            SizedBox(height: 8.h),
            Text(
              'QR code unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondary, fontSize: 12.sp),
            ),
          ],
        ),
      );
    }

    final value = qrCode.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Image.network(
        value,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const _QrError(),
      );
    }

    try {
      final base64Value = value.contains(',')
          ? value.substring(value.indexOf(',') + 1)
          : value;

      return Image.memory(
        base64Decode(base64Value),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const _QrError(),
      );
    } catch (_) {
      return const _QrError();
    }
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  static void _showProfileUnavailable() {
    AppToast.showToast('Please create or select a business profile first.');
  }

  static void _showSuccess(String title, String message) {
    AppToast.showToast('$title: $message');
  }
}

// =============================================================================
// SUPPORTING WIDGETS
// =============================================================================

class _ConfigField {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;

  const _ConfigField({
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });
}

class _RequiredBadge extends StatelessWidget {
  const _RequiredBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 12.sp,
            color: InboxChannelConnection._blue,
          ),
          SizedBox(width: 4.w),
          Text(
            'Required',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: InboxChannelConnection._blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  final bool connected;
  final bool polling;
  final String status;

  const _ConnectionStatus({
    required this.connected,
    required this.polling,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: connected ? const Color(0xFFE0FAEF) : const Color(0xFFE7F2FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            connected ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: connected
                ? const Color(0xFF0BAA78)
                : InboxChannelConnection._blue,
            size: 22.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                color: InboxChannelConnection._heading,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
          if (polling)
            SizedBox(
              width: 16.w,
              height: 16.h,
              child: CircularProgressIndicator(strokeWidth: 2.w),
            ),
        ],
      ),
    );
  }
}

class _QrError extends StatelessWidget {
  const _QrError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 40.sp,
            color: InboxChannelConnection._secondary,
          ),
          SizedBox(height: 8.h),
          Text(
            'Unable to display QR code',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: InboxChannelConnection._secondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// WHATSAPP PHONE NUMBER INPUT DIALOG
// =============================================================================

class _WhatsappPhoneNumberDialog extends StatefulWidget {
  const _WhatsappPhoneNumberDialog();

  @override
  State<_WhatsappPhoneNumberDialog> createState() =>
      _WhatsappPhoneNumberDialogState();
}

class _WhatsappPhoneNumberDialogState
    extends State<_WhatsappPhoneNumberDialog> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      AppToast.showToast('Enter your WhatsApp phone number with country code.');
      return;
    }

    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 8 || digits.length > 15) {
      AppToast.showToast('Enter a valid number including the country code.');
      return;
    }

    Get.back<String>(result: phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      titlePadding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 8.h),
      contentPadding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 8.h),
      actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: const BorderSide(color: InboxChannelConnection._border),
      ),
      title: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.h,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.phone_android_rounded,
              color: InboxChannelConnection._blue,
              size: 19.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Connect by phone',
              style: TextStyle(
                color: InboxChannelConnection._heading,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 290.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your WhatsApp number with country code.',
              style: TextStyle(
                color: InboxChannelConnection._secondary,
                fontSize: 12.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _phoneController,
              autofocus: true,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: TextStyle(
                fontSize: 13.sp,
                color: InboxChannelConnection._heading,
              ),
              decoration: InputDecoration(
                hintText: '+919876543210',
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                prefixIcon: Icon(
                  Icons.phone_android_rounded,
                  size: 18.sp,
                  color: InboxChannelConnection._secondary,
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 40.w,
                  minHeight: 40.h,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 10.h,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(
                    color: InboxChannelConnection._border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(
                    color: InboxChannelConnection._border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: InboxChannelConnection._blue,
                    width: 1.2.w,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<String>(),
          child: Text('Cancel', style: TextStyle(fontSize: 12.sp)),
        ),
        SizedBox(
          height: 36.h,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: InboxChannelConnection._blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.r),
              ),
            ),
            child: Text('Continue', style: TextStyle(fontSize: 12.sp)),
          ),
        ),
      ],
    );
  }
}
