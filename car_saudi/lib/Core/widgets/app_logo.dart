import 'package:get/get.dart';

/// Locale-aware logo asset paths — swap to the Arabic wordmark whenever the
/// app locale is Arabic, everywhere the logo is shown.
class AppLogo {
  AppLogo._();

  static bool get _isArabic => (Get.locale?.languageCode ?? 'en') == 'ar';

  /// Full logo used on Home/Search's app bar and header.
  static String get path =>
      _isArabic ? 'assets/Logo/arabiclogo.png' : 'assets/Logo/logo.png';

  /// Larger wordmark used on Splash / Welcome / Dealer login.
  static String get heroPath =>
      _isArabic ? 'assets/Logo/arabiclogo.png' : 'assets/Logo/homeLogo.png';
}
