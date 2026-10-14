import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';

/// Shared building blocks for the "List / Edit property" wizard.
///
/// Everything here is presentation-only; state lives in
/// `ListPropertyController` and the screen.

class LpColors {
  LpColors._();

  static const Color pageBg = Color(0xFFF7F5F6);
  static const Color fieldFill = Color(0xFFFAFAFB);
  static const Color border = AppColors.fieldBorder;
  static const Color ink = AppColors.ink;
  static const Color muted = AppColors.inkMuted;
  static const Color error = AppColors.error;
}

const double _fieldRadius = 12;

// =================================================================
// TOP BAR + SEGMENTED PROGRESS
// =================================================================
class LpTopBar extends StatelessWidget {
  final String title;
  final String stepLabel;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final ValueChanged<int> onStepTap;

  const LpTopBar({
    super.key,
    required this.title,
    required this.stepLabel,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    tooltip: 'Back'.tr,
                    icon: const Icon(Icons.arrow_back, color: LpColors.ink),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: LpColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stepLabel,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: LpColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                children: List.generate(totalSteps, (i) {
                  final reached = i <= currentStep;
                  final tappable = i < currentStep;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: tappable ? () => onStepTap(i) : null,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: i == totalSteps - 1 ? 0 : 5,
                          top: 4,
                          bottom: 12,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 4,
                          decoration: BoxDecoration(
                            color: reached
                                ? AppColors.primary
                                : AppColors.fieldBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: LpColors.border),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// STEP HEADING (top of each step's scroll content)
// =================================================================
class LpStepHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const LpStepHeading({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.pinkBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: LpColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: LpColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =================================================================
// SECTION CARD
// =================================================================
class LpSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool required;
  final List<Widget> children;

  const LpSectionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.required = false,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LpColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: title,
                    children: [
                      if (required)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: AppColors.primary),
                        ),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: LpColors.ink,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: LpColors.muted,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// =================================================================
// FIELD LABEL
// =================================================================
class LpFieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const LpFieldLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.primary),
              ),
          ],
        ),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.labelGrey,
        ),
      ),
    );
  }
}

/// A label + field pair used in two-column rows.
class LpLabeledField extends StatelessWidget {
  final String label;
  final bool required;
  final Widget child;

  const LpLabeledField({
    super.key,
    required this.label,
    this.required = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LpFieldLabel(label, required: required),
        child,
      ],
    );
  }
}

/// Two fields side by side with even spacing.
class LpFieldRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const LpFieldRow({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

// =================================================================
// TEXT FIELD
// =================================================================
class LpTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final Widget? prefix;
  final String? suffixText;
  final TextInputType? keyboardType;
  final bool digitsOnly;
  final bool decimal;
  final int? maxLength;
  final int maxLines;
  final bool enabled;
  final bool hasError;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  const LpTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.prefix,
    this.suffixText,
    this.keyboardType,
    this.digitsOnly = false,
    this.decimal = false,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.hasError = false,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  static OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      keyboardType:
          keyboardType ??
          (decimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : digitsOnly
              ? TextInputType.number
              : null),
      inputFormatters: [
        if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
        if (decimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,6}')),
      ],
      style: const TextStyle(fontSize: 14.5, color: LpColors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hintGrey, fontSize: 14),
        suffixText: suffixText,
        suffixStyle: const TextStyle(color: AppColors.hintGrey, fontSize: 14),
        counterText: '',
        filled: true,
        fillColor: enabled ? LpColors.fieldFill : const Color(0xFFF1F0F2),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        prefixIcon:
            prefix ??
            (prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.hintGrey, size: 20)
                : null),
        prefixIconConstraints: prefix != null
            ? const BoxConstraints(minWidth: 0, minHeight: 0)
            : null,
        border: _border(hasError ? LpColors.error : LpColors.border),
        enabledBorder: _border(hasError ? LpColors.error : LpColors.border),
        disabledBorder: _border(LpColors.border),
        focusedBorder: _border(
          hasError ? LpColors.error : AppColors.primary,
          1.5,
        ),
      ),
    );
  }
}

// =================================================================
// DROPDOWN
// =================================================================
class LpDropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final List<String> items;
  final bool hasError;
  final ValueChanged<String?> onChanged;

  const LpDropdownField({
    super.key,
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    // DropdownButton asserts if `value` isn't one of the items (e.g. in
    // edit mode before the option list has loaded).
    final safeValue = items.contains(value) ? value : null;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: LpColors.fieldFill,
        borderRadius: BorderRadius.circular(_fieldRadius),
        border: Border.all(
          color: hasError ? LpColors.error : LpColors.border,
          width: hasError ? 1.2 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: safeValue,
          menuMaxHeight: 320,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.hintGrey,
          ),
          hint: Row(
            children: [
              Icon(icon, color: AppColors.hintGrey, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hint,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.hintGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          selectedItemBuilder: (_) => items
              .map(
                (e) => Row(
                  children: [
                    Icon(icon, color: AppColors.hintGrey, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e.tr,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: LpColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.tr, style: const TextStyle(fontSize: 14.5)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// =================================================================
// CHOICE CHIP (single / multi select)
// =================================================================
class LpChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final String? imageUrl;
  final VoidCallback onTap;

  const LpChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? AppColors.pinkChipBg : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppColors.primary : LpColors.border,
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                ] else if (imageUrl != null && imageUrl!.trim().isNotEmpty) ...[
                  Image.network(
                    imageUrl!,
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(width: 0),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label.tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppColors.primary : LpColors.ink,
                    ),
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

/// Wrap of chips that collapses to [collapsedCount] with a "Show all" toggle.
class LpChipWrap extends StatelessWidget {
  final List<Widget> chips;
  final int collapsedCount;
  final bool expanded;
  final VoidCallback onToggle;

  const LpChipWrap({
    super.key,
    required this.chips,
    required this.expanded,
    required this.onToggle,
    this.collapsedCount = 12,
  });

  @override
  Widget build(BuildContext context) {
    final canCollapse = chips.length > collapsedCount;
    final visible = (!canCollapse || expanded)
        ? chips
        : chips.take(collapsedCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 8, runSpacing: 8, children: visible),
        if (canCollapse)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: TextButton(
              onPressed: onToggle,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                expanded
                    ? 'Show less'.tr
                    : '${'Show all'.tr} (${chips.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// =================================================================
// SEGMENTED CHOICE (Sale / Rent)
// =================================================================
class LpSegmentOption {
  final String value;
  final String label;
  final IconData icon;

  const LpSegmentOption(this.value, this.label, this.icon);
}

class LpSegmented extends StatelessWidget {
  final List<LpSegmentOption> options;
  final String selected;
  final bool hasError;
  final ValueChanged<String> onChanged;

  const LpSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _tile(options[i])),
        ],
      ],
    );
  }

  Widget _tile(LpSegmentOption o) {
    final isSelected = o.value == selected;
    final borderColor = isSelected
        ? AppColors.primary
        : (hasError ? LpColors.error : LpColors.border);

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(o.value),
          borderRadius: BorderRadius.circular(_fieldRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.pinkChipBg : LpColors.fieldFill,
              borderRadius: BorderRadius.circular(_fieldRadius),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  o.icon,
                  size: 18,
                  color: isSelected ? AppColors.primary : AppColors.hintGrey,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    o.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.labelGrey,
                    ),
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

// =================================================================
// INFO BANNER
// =================================================================
enum LpBannerTone { info, success, warning, error }

class LpBanner extends StatelessWidget {
  final LpBannerTone tone;
  final IconData? icon;
  final String title;
  final String? message;
  final Widget? action;

  const LpBanner({
    super.key,
    required this.tone,
    required this.title,
    this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final IconData defaultIcon;

    switch (tone) {
      case LpBannerTone.success:
        bg = AppColors.greenBg;
        fg = AppColors.greenText;
        defaultIcon = Icons.verified_rounded;
        break;
      case LpBannerTone.warning:
        bg = const Color(0xFFFFF7E8);
        fg = const Color(0xFFB7791F);
        defaultIcon = Icons.info_outline_rounded;
        break;
      case LpBannerTone.error:
        bg = const Color(0xFFFEF2F2);
        fg = AppColors.error;
        defaultIcon = Icons.error_outline_rounded;
        break;
      case LpBannerTone.info:
        bg = AppColors.pinkChipBg;
        fg = AppColors.primary;
        defaultIcon = Icons.info_outline_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    message!,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: LpColors.ink,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 8), action!],
        ],
      ),
    );
  }
}

// =================================================================
// SMALL OUTLINED ACTION BUTTON
// =================================================================
class LpOutlineButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final double height;

  const LpOutlineButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.loading = false,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: loading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: Colors.white,
          side: BorderSide(color: AppColors.primary.withOpacity(.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_fieldRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// =================================================================
// DASHED UPLOAD BOX
// =================================================================
class LpUploadBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool hasError;
  final double height;

  const LpUploadBox({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.hasError = false,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    final color = hasError ? LpColors.error : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: color.withOpacity(hasError ? .8 : .45),
          radius: 14,
        ),
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: hasError ? const Color(0xFFFEF2F2) : AppColors.pinkChipBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: LpColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: LpColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    const dash = 7.0;
    const gap = 5.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

// =================================================================
// PHOTO TILES
// =================================================================
class LpPhotoTile extends StatelessWidget {
  final String? filePath;
  final String? networkUrl;
  final VoidCallback onRemove;

  const LpPhotoTile({
    super.key,
    this.filePath,
    this.networkUrl,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final Widget image = filePath != null
        ? Image.file(
            File(filePath!),
            fit: BoxFit.cover,
            cacheWidth: 360,
            errorBuilder: (_, __, ___) => _placeholder(),
          )
        : Image.network(
            networkUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: image),
        PositionedDirectional(
          top: 4,
          end: 4,
          child: LpRoundIconButton(
            icon: Icons.close_rounded,
            size: 26,
            tooltip: 'Remove'.tr,
            onTap: onRemove,
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFEDEAE4),
    child: const Icon(Icons.broken_image_outlined, color: AppColors.hintGrey),
  );
}

class LpAddPhotoTile extends StatelessWidget {
  final VoidCallback onTap;

  const LpAddPhotoTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.primary.withOpacity(.45),
          radius: 12,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.pinkChipBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primary,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                'Add'.tr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LpRoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final String? tooltip;

  const LpRoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 32,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Color(0x99000000),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: size * .58),
        ),
      ),
    );
  }
}

// =================================================================
// BOTTOM ACTION BAR
// =================================================================
class LpBottomBar extends StatelessWidget {
  final Widget child;

  const LpBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: LpColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: child,
        ),
      ),
    );
  }
}

// =================================================================
// REVIEW SECTION + ROW
// =================================================================
class LpReviewSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onEdit;
  final List<Widget> children;

  const LpReviewSection({
    super.key,
    required this.icon,
    required this.title,
    required this.onEdit,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LpColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: LpColors.ink,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(
                  'Edit'.tr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 12, color: LpColors.border),
          ...children,
        ],
      ),
    );
  }
}

class LpReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const LpReviewRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: LpColors.muted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: LpColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
