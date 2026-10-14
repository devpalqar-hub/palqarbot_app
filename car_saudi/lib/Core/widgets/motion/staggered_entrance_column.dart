import 'package:flutter/material.dart';

import 'fade_slide_in.dart';

/// Drop-in replacement for a top-level `Column(children: [...])` of page
/// sections: renders exactly like `Column`, but wraps each direct child
/// in [FadeSlideIn] with a small increasing delay, so the page's
/// sections settle into place one after another instead of popping in
/// all at once.
///
/// Only meant for a handful of *logical sections* (header, banner, a
/// list, a card) - never for wrapping every individual list item, per
/// the "don't over-animate" rule.
class StaggeredEntranceColumn extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final Duration staggerStep;

  const StaggeredEntranceColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 0,
    this.staggerStep = const Duration(milliseconds: 40),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      children: [
        for (int i = 0; i < children.length; i++)
          FadeSlideIn(delay: staggerStep * i, child: children[i]),
      ],
    );
  }
}
