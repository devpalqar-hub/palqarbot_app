import 'package:flutter/material.dart';
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

  final TextEditingController _promptController = TextEditingController(
    
  );

  @override
  void initState() {
    super.initState();

    _controller = Get.put(BotController());

    _promptController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _promptController.removeListener(_onTextChanged);
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _savePrompt() async {
    FocusScope.of(context).unfocus();

    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) {
      return;
    }

    await _controller.updateSystemPrompt(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BotController>(
      builder: (controller) {
        return Scaffold(
          appBar: const AppTopBar(
            title: 'System Prompt',
            subtitle:
                'Define how the AI assistant should behave\n'
                'and respond.',
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Align(
                alignment: Alignment.topCenter,
                child: _buildPromptCard(
                  _promptController.text.length,
                  controller,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PROMPT CARD
  // ============================================================

  Widget _buildPromptCard(int characterCount, BotController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 19),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Prompt',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _buildPromptField(characterCount),
          const SizedBox(height: 18),
          _buildSaveButton(controller),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildPromptField(int characterCount) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _promptController,
            maxLength: maxCharacters,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Enter system prompt...',
              hintStyle: AppTextStyles.bodySmall,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.fromLTRB(12, 11, 12, 34),
              counterText: '',
            ),
          ),
          Positioned(
            right: 10,
            bottom: 9,
            child: Text(
              '$characterCount/$maxCharacters',
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================
Widget _buildSaveButton(BotController controller) {
  return AppButton(
    text: 'Save',
    isLoading: controller.isSaving,
    onPressed: _savePrompt,
  );
}
}
