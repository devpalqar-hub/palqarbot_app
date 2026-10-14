import 'package:flutter/material.dart';

/// Central timing/curve tokens for every implicit animation added on top
/// of the existing UI (press feedback, entrance fades, shimmer swaps,
/// selection indicators, etc).
///
/// Keeping these in one place is what stops every screen from picking
/// its own random duration - see `Core/widgets/motion/` for the shared
/// widgets that consume these values.
class AppMotion {
  AppMotion._();

  /// Instant feedback - button/card press-down, icon toggles.
  static const Duration fast = Duration(milliseconds: 150);

  /// Default micro-interaction duration - focus states, chip selection.
  static const Duration normal = Duration(milliseconds: 200);

  /// Section/card entrance, shimmer -> content cross-fade.
  static const Duration medium = Duration(milliseconds: 250);

  /// Larger content swaps (e.g. list skeleton -> loaded list).
  static const Duration slow = Duration(milliseconds: 350);

  /// Default entrance/settle curve - snappy start, gentle stop.
  static const Curve curve = Curves.easeOutCubic;

  /// Default curve for reversible/back-and-forth transitions
  /// (focus in/out, selection toggle, tab switches).
  static const Curve smooth = Curves.easeInOutCubic;
}

/// True when the platform has "reduce motion" turned on. Every motion
/// widget in `Core/widgets/motion/` checks this once and short-circuits
/// to the end state instead of animating.
bool prefersReducedMotion(BuildContext context) {
  return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}
