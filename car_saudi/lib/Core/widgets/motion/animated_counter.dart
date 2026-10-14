import 'package:flutter/material.dart';

import 'package:villas_qatar/Core/theme/app_motion.dart';

/// Tweens a number label between its old and new value instead of
/// snapping to it - used for dashboard/insight stat tiles.
///
/// Only animates when [value] actually changes between builds (tracked
/// via `didUpdateWidget`), so it never replays on unrelated rebuilds.
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = AppMotion.medium,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> {
  late int _previousValue = widget.value;

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = prefersReducedMotion(context);

    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.value),
      tween: Tween<double>(
        begin: reduceMotion
            ? widget.value.toDouble()
            : _previousValue.toDouble(),
        end: widget.value.toDouble(),
      ),
      duration: reduceMotion ? Duration.zero : widget.duration,
      curve: AppMotion.curve,
      builder: (context, value, child) {
        return Text(value.round().toString(), style: widget.style);
      },
    );
  }
}
