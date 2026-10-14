import 'package:flutter/material.dart';

import 'package:villas_qatar/Core/theme/app_motion.dart';

/// Subtle entrance animation: fades and slides [child] up into place.
///
/// Used for page-section and list-item entrances (see spec sections 3 &
/// 12) - never for every individual `Text` widget, only for logical
/// chunks of UI (a header, a card, a stat block).
///
/// [delay] lets callers stagger a sequence of these by a small offset
/// (~30-60ms per item) instead of everything animating in at once.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.medium,
    this.offsetY = 12,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;

  // Guards against re-triggering the entrance every time an ancestor
  // InheritedWidget (e.g. MediaQuery) rebuilds - didChangeDependencies
  // can fire more than once, but the entrance should only ever play once.
  bool _started = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacity = CurvedAnimation(parent: _controller, curve: AppMotion.curve);

    _translateY = Tween<double>(
      begin: widget.offsetY,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: AppMotion.curve));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // MediaQuery.maybeOf (inside prefersReducedMotion) must be read from
    // didChangeDependencies/build, not initState - reading it there trips
    // Flutter's "dependOnInheritedWidgetOfExactType called before
    // initState() completed" assertion.
    if (_started) {
      return;
    }

    _started = true;

    if (prefersReducedMotion(context)) {
      _controller.value = 1;
      return;
    }

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _translateY.value),
            child: child,
          ),
        );
      },
    );
  }
}
