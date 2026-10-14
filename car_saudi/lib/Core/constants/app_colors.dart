import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF8A1538);
  static const Color primaryDark = Color(0xFF6E102D);
  static const Color primaryLight = Color(0xFFF8E9EE);

  // Accent
  static const Color secondary = Color(0xFFD9B27C);

  // Backgrounds
  static const Color background = Color(0xFFFDFDFD);
  static const Color scaffold = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Borders
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Input
  static const Color inputBorder = Color(0xFFE5E7EB);
  static const Color focusedBorder = primary;

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Common
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Auth Screens
  static const Color authInfoBackground = Color(0xFFF9F2F4);
  static const Color authIconBackground = Color(0xFFF7E8EE);

  // Property Tags
  static const Color featured = primary;
  static const Color newProperty = Color(0xFF16A34A);
  static const Color sold = Color(0xFFDC2626);

  // Shadow
  static const Color shadow = Color(0x14000000);

  // Button Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF980A43), Color(0xFF8A1538), Color(0xFF730D30)],
  );

  // Decorative Background
  static const Color backgroundPattern = Color(0xFFF8EEF2);

  // OTP Box
  static const Color otpBorder = Color(0xFFE5E7EB);
  static const Color otpFocused = primary;

  // Disabled
  static const Color disabled = Color(0xFFD1D5DB);
  static const pinkChipBg = Color(0xFFFDF0F3);
  static const fieldBorder = Color(0xFFE3E1E6);
  static const fieldBg = Color(0xFFFFFFFF);
  static const greenBg = Color(0xFFE8F8EE);
  static const greenText = Color(0xFF1E9E4B);
  static const hintGrey = Color(0xFF9C9AA3);
  static const labelGrey = Color(0xFF4A4750);
  static const pinkBg = Color(0xFFFBE7EC);
  static const mapBg = Color(0xFFDCE9E4);
  static const cardBg = Color(0xFFFFFFFF);

  static const Color primarySoft = Color(0xFFF3E3E9);
  static const Color surface = Color(0xFFFFFFFF);
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B1F3D), Color(0xFFA13A5C)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7B1F3D), Color(0xFF9A3054)],
  );

  // ─── Web-aligned design tokens ─────────────────────────────────────────────
  // Mirrors the palette used by user-site so the app and the website read as
  // one product: deep maroon brand, gold accent, warm cream surfaces.

  /// Gold accent — the site's `#d39d55` (hero eyebrow, headline accent, CTAs).
  static const Color gold = Color(0xFFD39D55);

  /// Softer gold used for hovered/active borders on the site.
  static const Color goldSoft = Color(0xFFE6CFA1);

  /// Pale gold used for uppercase eyebrow text over dark imagery.
  static const Color goldPale = Color(0xFFD6CFB3);

  /// Warm panel background — the site's `#fdfaf6` AI-estimator panel.
  static const Color cream = Color(0xFFFDFAF6);

  /// Card background top-stop for the category gradient (`#fffdf8`).
  static const Color creamCard = Color(0xFFFFFDF8);

  /// Sand chip/circle background (`#f5f1e6`).
  static const Color sand = Color(0xFFF5F1E6);

  /// Warm hairline border around cream cards (`#ebe6d8`).
  static const Color warmBorder = Color(0xFFEBE6D8);

  /// Neutral hairline border used on the site's place/dealer cards.
  static const Color coolBorder = Color(0xFFE8E9EB);

  /// Gold-tinted border used on the site's property cards (`#d39d557e`).
  static const Color goldBorder = Color(0x7ED39D55);

  /// Heading ink (`#16181d`).
  static const Color ink = Color(0xFF16181D);

  /// Body/subtitle ink (`#6b6d72`).
  static const Color inkMuted = Color(0xFF6B6D72);

  /// Label/caption ink (`#8b8d92`).
  static const Color inkFaint = Color(0xFF8B8D92);

  /// Deepest maroon — the site's app-promo panel (`#640d22`).
  static const Color maroonDeep = Color(0xFF640D22);

  /// Tint behind maroon feature icons on the dealer CTA (`#fdf2f4`).
  static const Color maroonTint = Color(0xFFFDF2F4);

  /// Positive trend chip (site `#dcfce7` / `#15803d`).
  static const Color trendBg = Color(0xFFDCFCE7);
  static const Color trendText = Color(0xFF15803D);

  /// Warm badge chip behind "Smart & Fast" (site `#fef3c7`).
  static const Color goldChipBg = Color(0xFFFEF3C7);

  /// Maroon → gold hairline that tops the site's category cards.
  static const LinearGradient accentLine = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, gold],
  );

  /// Blush → gold wash behind category icons (site `#fbe1e6` → `#f6ebd6`).
  static const LinearGradient categoryIconGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBE1E6), Color(0xFFF6EBD6)],
  );

  /// Cream card wash (site `linear-gradient(165deg, #fffdf8, #ffffff 55%)`).
  static const LinearGradient creamCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [creamCard, white],
    stops: [0.0, 0.55],
  );

  /// Maroon CTA gradient (site `linear-gradient(135deg, #a51b44, #8A1538)`).
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA51B44), primary],
  );
}
