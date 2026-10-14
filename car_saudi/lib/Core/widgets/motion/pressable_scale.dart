import 'package:flutter/material.dart';

import 'package:villas_qatar/Core/theme/app_motion.dart';

/// Wraps [child] with a subtle press-down scale, the way a physical
/// button would compress under a finger.
///
/// This deliberately drives the scale off raw pointer events (`Listener`)
/// rather than a `GestureDetector`'s tap recognizer, so it never enters
/// the gesture arena and competes with an existing `InkWell`/tap handler
/// underneath it for who "wins" the tap. Put this on the OUTSIDE of the
/// widget that already handles the tap:
///
/// ```dart
/// PressableScale(
///   child: InkWell(
///     onTap: onTap,
///     child: ...,
///   ),
/// )
/// ```
///
/// If the wrapped subtree has no tap handler of its own, pass [onTap]
/// and this widget will fire it directly.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = prefersReducedMotion(context);

    final Widget scaled = AnimatedScale(
      scale: (_pressed && !reduceMotion) ? widget.pressedScale : 1.0,
      duration: AppMotion.fast,
      curve: AppMotion.curve,
      child: widget.child,
    );

    final Widget listener = Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: scaled,
    );

    if (widget.onTap == null) {
      return listener;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      child: listener,
    );
  }
}
