
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Core/widgets/app_buttons.dart';
import 'package:palqarbot_app/Core/widgets/app_topbar.dart';
import 'package:palqarbot_app/Screens/bot/service/bot_controller.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  static const int maxCharacters = 2000;

  late final BotController _controller;

  final TextEditingController _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = Get.isRegistered<BotController>()
        ? Get.find<BotController>()
        : Get.put(BotController());

    _promptController.addListener(_onTextChanged);

    _loadPrompt();
  }

  // ===========================================================================
  // LOAD EXISTING PROMPT
  // ===========================================================================

  Future<void> _loadPrompt() async {
    final success = await _controller.loadSystemPrompt();

    if (!mounted) return;

    if (success) {
      final prompt = _controller.systemPrompt;

      _promptController.text = prompt;

      _promptController.selection = TextSelection.fromPosition(
        TextPosition(offset: _promptController.text.length),
      );
    }

    setState(() {});
  }

  // ===========================================================================
  // TEXT CHANGE
  // ===========================================================================

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ===========================================================================
  // SAVE
  // ===========================================================================

  Future<void> _savePrompt() async {
    FocusScope.of(context).unfocus();

    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) return;

    final success = await _controller.updateSystemPrompt(prompt);

    if (!mounted) return;

    if (success) {
      _promptController.text = prompt;

      _promptController.selection = TextSelection.fromPosition(
        TextPosition(offset: _promptController.text.length),
      );
    }
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _promptController.removeListener(_onTextChanged);
    _promptController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BotController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppTopBar(
            title: 'System Prompt',
            subtitle: 'Define how the AI assistant should behave\n'
                'and respond.',
          ),
          body: SafeArea(
            child: controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      18.h,
                      20.w,
                      24.h,
                    ),
                    child: _buildPromptContainer(controller),
                  ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MAIN CONTAINER
  // ===========================================================================

  Widget _buildPromptContainer(BotController controller) {
    final characterCount = _promptController.text.length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18.w,
        18.h,
        18.w,
        20.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.border,
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // TITLE
          // -------------------------------------------------------------------

          Text(
            'System Prompt',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            'Set the instructions that guide how your AI assistant '
            'responds to customers.',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),

          SizedBox(height: 16.h),

          // -------------------------------------------------------------------
          // PROMPT FIELD
          // -------------------------------------------------------------------

          _buildPromptField(characterCount),

          SizedBox(height: 18.h),

          // -------------------------------------------------------------------
          // SAVE BUTTON
          // -------------------------------------------------------------------

          _buildSaveButton(controller),
        ],
      ),
    );
  }

  // ===========================================================================
  // PROMPT FIELD
  // ===========================================================================

  Widget _buildPromptField(int characterCount) {
    return Container(
      width: double.infinity,
      height: 320.h,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.border,
          width: 1.w,
        ),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _promptController,
            maxLength: maxCharacters,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: AppTextStyles.body.copyWith(
              fontSize: 14.sp,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter system prompt...\n\n'
                  'Example:\n'
                  'You are a helpful customer support assistant. '
                  'Answer clearly, politely, and professionally.',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                fontSize: 13.sp,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.fromLTRB(
                14.w,
                14.h,
                14.w,
                38.h,
              ),
              counterText: '',
            ),
          ),

          // -------------------------------------------------------------------
          // CHARACTER COUNT
          // -------------------------------------------------------------------

          Positioned(
            right: 12.w,
            bottom: 10.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 7.w,
                vertical: 3.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Text(
                '$characterCount/$maxCharacters',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SAVE BUTTON
  // ===========================================================================

  Widget _buildSaveButton(BotController controller) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        text: 'Save',
        isLoading: controller.isSaving,
        onPressed: _savePrompt,
      ),
    );
  }
}
