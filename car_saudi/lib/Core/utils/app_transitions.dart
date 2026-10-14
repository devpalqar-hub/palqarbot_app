import 'package:get/get.dart';

/// Centralized, direction-aware page transitions.
///
/// Instead of hardcoding `Transition.rightToLeft` at every call site,
/// use [AppTransitions.forward] / [AppTransitions.backward]. They flip
/// automatically based on the current app locale so that:
///   - English (LTR): new screens slide in from the right (natural push).
///   - Arabic (RTL): new screens slide in from the left (mirrored push,
///     matching RTL reading direction).
///
/// This keeps every `Get.to()` / `Get.off()` call in the app consistent
/// and correct without each screen needing to know the current locale.
class AppTransitions {
  AppTransitions._();

  static bool get _isRtl =>
      Get.locale?.languageCode == 'ar';

  /// Use for forward navigation (Get.to / Get.toNamed / push-like calls).
  static Transition get forward =>
      _isRtl
          ? Transition.leftToRight
          : Transition.rightToLeft;

  /// Use for replace/back-like navigation that should visually mirror
  /// the [forward] transition (Get.off / Get.back-style flows).
  static Transition get backward =>
      _isRtl
          ? Transition.rightToLeft
          : Transition.leftToRight;
}
