
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Screens/Onboarding/Model/onboarding_model.dart';
import 'package:palqarbot_app/Screens/Onboarding/Service/onboarding_controller.dart';

import 'package:palqarbot_app/main.dart';

// ============================================================
// ONBOARDING QUESTIONS SCREEN
// ============================================================

class OnboardingQuestionsScreen extends StatefulWidget {
  const OnboardingQuestionsScreen({super.key});

  @override
  State<OnboardingQuestionsScreen> createState() =>
      _OnboardingQuestionsScreenState();
}

class _OnboardingQuestionsScreenState
    extends State<OnboardingQuestionsScreen> {
  late final OnboardingController controller;

  final TextEditingController _customAnswerController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<OnboardingController>()
        ? Get.find<OnboardingController>()
        : Get.put(OnboardingController());
  }

  @override
  void dispose() {
    _customAnswerController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    FocusScope.of(context).unfocus();

    final success = await controller.submitAnswer();

    if (!mounted || !success) return;

    _customAnswerController.clear();

    if (controller.isComplete) {
      Get.offAll(() => const _OnboardingCompletionScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GetBuilder<OnboardingController>(
          builder: (onboardingController) {
            final item = onboardingController.current;

            if (item == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (item.done) {
              return const _CompletionView();
            }

            return _QuestionContent(
              key: ValueKey(
                '${item.requestId}_${item.step}_${item.question}',
              ),
              item: item,
              controller: onboardingController,
              customAnswerController: _customAnswerController,
              onSubmit: _submitAnswer,
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// QUESTION CONTENT
// ============================================================

class _QuestionContent extends StatelessWidget {
  final OnboardingModel item;
  final OnboardingController controller;
  final TextEditingController customAnswerController;
  final Future<void> Function() onSubmit;

  const _QuestionContent({
    super.key,
    required this.item,
    required this.controller,
    required this.customAnswerController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final options = item.options;
    final progress = controller.progress.clamp(0.0, 1.0).toDouble();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              25.w,
              8.h,
              25.w,
              20.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OnboardingHeader(
                  progress: progress,
                  step: item.step,
                  maxSteps: item.maxSteps,
                ),

               

                SizedBox(height: 20.h),

                Text(
                  item.question,
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 20.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.6.sp,
                  ),
                ),

                SizedBox(height: 12.h),

                Text(
                  'Choose the options that best describe your business. '
                  'You can change these later.',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 24.h),

                // Answer options
                if (options.isNotEmpty)
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: options.map((option) {
                      final selected =
                          controller.selectedAnswer == option;

                      return _AnswerChip(
                        label: option,
                        selected: selected,
                        enabled: !controller.isSubmitting,
                        onTap: () {
                          customAnswerController.clear();
                          controller.selectAnswer(option);
                        },
                      );
                    }).toList(),
                  ),

                SizedBox(height: 25.h),

                Text(
                  'SOMETHING ELSE?',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4.sp,
                  ),
                ),

                SizedBox(height: 10.h),

                // Custom answer
                TextField(
                  controller: customAnswerController,
                  enabled: !controller.isSubmitting,
                  minLines: 1,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  onChanged: controller.setCustomAnswer,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your own answer...',
                    hintStyle: AppTextStyles.body.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: Icon(
                      Icons.edit_outlined,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 17.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                  ),
                ),

                // API error
                if (controller.errorMessage.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  _ErrorMessage(
                    message: controller.errorMessage,
                  ),
                ],
              ],
            ),
          ),
        ),

        // Fixed bottom button
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            25.w,
            12.h,
            25.w,
            16.h,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(
                color: AppColors.divider,
              ),
            ),
          ),
          child: _PrimaryButton(
            label: 'Continue',
            loading: controller.isSubmitting,
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ONBOARDING HEADER
// ============================================================

class _OnboardingHeader extends StatelessWidget {
  final double progress;
  final int step;
  final int maxSteps;

  const _OnboardingHeader({
    required this.progress,
    required this.step,
    required this.maxSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (Get.key.currentState?.canPop() ?? false) {
                    Get.back();
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20.sp,
                  color: AppColors.textPrimary,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: 28.w,
                  minHeight: 36.h,
                ),
              ),

              const Spacer(),

              Text(
                '$step/$maxSteps',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),

              const Spacer(),

              SizedBox(width: 28.w),
            ],
          ),

          SizedBox(height: 16.h),

          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4.h,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CONVERSATION ILLUSTRATION
// ============================================================

// ============================================================
// ANSWER CHIP
// ============================================================

class _AnswerChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _AnswerChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(
            horizontal: 15.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.65)
                  : AppColors.border,
              width: selected ? 1.5.w : 1.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14.sp,
                    height: 1.25,
                    color: AppColors.textPrimary,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),

              if (selected) ...[
                SizedBox(width: 8.w),
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 18.sp,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PRIMARY BUTTON
// ============================================================

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final Future<void> Function() onPressed;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          disabledBackgroundColor:
              AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 22.w,
                height: 22.h,
                child: CircularProgressIndicator(
                  color: AppColors.textWhite,
                  strokeWidth: 2.w,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.button.copyWith(
                      fontSize: 15.sp,
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 21.sp,
                  ),
                ],
              ),
      ),
    );
  }
}

// ============================================================
// ERROR MESSAGE
// ============================================================

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 19.sp,
          ),

          SizedBox(width: 9.w),

          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                height: 1.4,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ONBOARDING COMPLETION SCREEN
// ============================================================

class _OnboardingCompletionScreen extends StatelessWidget {
  const _OnboardingCompletionScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const SafeArea(
        child: _CompletionView(),
      ),
    );
  }
}

// ============================================================
// COMPLETION VIEW
// ============================================================

class _CompletionView extends StatelessWidget {
  const _CompletionView();

  void _goToHome() {
    Get.offAll(() => const Bottombar());
  }

  

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24.w,
          22.h,
          24.w,
          22.h,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _SuccessIllustration(),

            SizedBox(height: 18.h),

            Text(
              'You’re all set!',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading1.copyWith(
                fontSize: 30.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7.sp,
                color: const Color(0xFF142044),
              ),
            ),

            SizedBox(height: 10.h),

            Text(
              'Your business profile is ready. You can now start using '
              'Palqarbot to assist your customers.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize: 14.sp,
                height: 1.5,
                color: const Color(0xFF7A8298),
              ),
            ),

            SizedBox(height: 22.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(13.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: const Color(0xFFE6EBF5),
                ),
              ),
              child: Column(
                children: [
                  const _BenefitRow(
                    icon: Icons.chat_bubble_rounded,
                    title: 'Instant customer replies',
                    subtitle: 'Answer enquiries across your channels.',
                  ),

                  SizedBox(height: 13.h),

                  const _BenefitRow(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Consistent responses',
                    subtitle: 'Respond based on your business details.',
                  ),

                  SizedBox(height: 13.h),

                  const _BenefitRow(
                    icon: Icons.bar_chart_rounded,
                    title: 'More time for your business',
                    subtitle: 'Let Palqarbot handle common questions.',
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            _PrimaryButton(
              label: 'Go to Home',
              loading: false,
              onPressed: () async => _goToHome(),
            ),

            SizedBox(height: 10.h),

          
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SUCCESS ILLUSTRATION
// ============================================================

class _SuccessIllustration extends StatelessWidget {
  const _SuccessIllustration();

  @override
  Widget build(BuildContext context) {
    final confetti = <
        ({
          double left,
          double top,
          Color color,
          double size,
          double angle,
        })
      >[
        (
          left: 18,
          top: 26,
          color: const Color(0xFF9A70FF),
          size: 10,
          angle: 0.7,
        ),
        (
          left: 42,
          top: 8,
          color: const Color(0xFF48D5BD),
          size: 6,
          angle: 0.2,
        ),
        (
          left: 150,
          top: 12,
          color: const Color(0xFFFFB52E),
          size: 8,
          angle: 0.5,
        ),
        (
          left: 178,
          top: 42,
          color: const Color(0xFF2EA7FF),
          size: 9,
          angle: 0.8,
        ),
        (
          left: 20,
          top: 82,
          color: const Color(0xFFFF78B7),
          size: 8,
          angle: 0.5,
        ),
        (
          left: 166,
          top: 92,
          color: const Color(0xFFFF78B7),
          size: 7,
          angle: 0.8,
        ),
        (
          left: 44,
          top: 112,
          color: const Color(0xFF48D5BD),
          size: 9,
          angle: 0.7,
        ),
        (
          left: 151,
          top: 116,
          color: const Color(0xFF2EA7FF),
          size: 8,
          angle: 0.3,
        ),
      ];

    return SizedBox(
      width: 220.w,
      height: 165.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 142.w,
            height: 142.h,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF8F2),
              shape: BoxShape.circle,
            ),
          ),

          Container(
            width: 82.w,
            height: 82.h,
            decoration: const BoxDecoration(
              color: Color(0xFF2FC58A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x302FC58A),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 52.sp,
            ),
          ),

          ...confetti.map(
            (piece) => Positioned(
              left: piece.left.w,
              top: piece.top.h,
              child: Transform.rotate(
                angle: piece.angle,
                child: Container(
                  width: piece.size.w,
                  height: (piece.size * 1.45).h,
                  decoration: BoxDecoration(
                    color: piece.color,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BENEFIT ROW
// ============================================================

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 23.sp,
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
