import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:villas_qatar/Core/theme/app_motion.dart';
import 'package:villas_qatar/modules/home/model/PropertyModel.dart';
import 'package:villas_qatar/modules/home/widgets/property_card.dart';

/// Horizontal, snapping rail of [PropertyCard]s that also advances on its own
/// (looping back to the first card after the last). Each card runs its own
/// photo carousel.
class FeaturedPropertiesCarousel extends StatefulWidget {
  final List<PropertyModel> properties;

  const FeaturedPropertiesCarousel({super.key, required this.properties});

  @override
  State<FeaturedPropertiesCarousel> createState() =>
      _FeaturedPropertiesCarouselState();
}

class _FeaturedPropertiesCarouselState
    extends State<FeaturedPropertiesCarousel> {
  static const Duration _slideInterval = Duration(seconds: 5);
  static const Duration _slideDuration = Duration(milliseconds: 500);

  PageController? _pageController;
  double _viewportFraction = 0.5;
  Timer? _autoSlideTimer;
  bool _userDragging = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _scheduleNextSlide();
  }

  @override
  void didUpdateWidget(covariant FeaturedPropertiesCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.properties.length != widget.properties.length) {
      _page = 0;
      if (_pageController?.hasClients ?? false) {
        _pageController!.jumpToPage(0);
      }
      _scheduleNextSlide();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  void _scheduleNextSlide() {
    _autoSlideTimer?.cancel();

    if (widget.properties.length < 2) {
      return;
    }

    _autoSlideTimer = Timer(_slideInterval, _slideToNext);
  }

  void _slideToNext() {
    if (!mounted) {
      return;
    }

    final PageController? controller = _pageController;

    // Hold off while the user is dragging, or while another route covers
    // this screen.
    if (_userDragging ||
        controller == null ||
        !controller.hasClients ||
        !TickerMode.valuesOf(context).enabled) {
      _scheduleNextSlide();
      return;
    }

    final int count = widget.properties.length;
    final int next = _page + 1;

    // onPageChanged schedules the following slide.
    if (next >= count) {
      controller.animateToPage(
        0,
        duration: _slideDuration,
        curve: AppMotion.curve,
      );
    } else {
      controller.nextPage(duration: _slideDuration, curve: AppMotion.curve);
    }
  }

  PageController _controllerFor(double viewportFraction) {
    if (_pageController == null ||
        (_viewportFraction - viewportFraction).abs() > 0.001) {
      _pageController?.dispose();
      _viewportFraction = viewportFraction;
      _pageController = PageController(
        viewportFraction: viewportFraction,
        initialPage: _page,
      );
    }

    return _pageController!;
  }

  @override
  Widget build(BuildContext context) {
    final List<PropertyModel> properties = widget.properties;

    if (properties.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Cards keep their 180.w footprint (plus the gap between them).
        final double cardExtent = 185.w;
        final double railWidth = constraints.maxWidth - 20.w;
        final double fraction = (cardExtent / railWidth).clamp(0.3, 1.0);

        return Padding(
          // Aligns the first card with the page gutter; cards that slide off
          // the left edge keep painting over it (clipBehavior.none below).
          padding: EdgeInsetsDirectional.only(start: 20.w),
          child: SizedBox(
            height: 220.h,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.depth != 0) {
                  return false;
                }

                if (notification is ScrollStartNotification &&
                    notification.dragDetails != null) {
                  _userDragging = true;
                  _autoSlideTimer?.cancel();
                } else if (notification is ScrollEndNotification) {
                  _userDragging = false;
                  _scheduleNextSlide();
                }

                return false;
              },
              child: PageView.builder(
                controller: _controllerFor(fraction),
                padEnds: false,
                clipBehavior: Clip.none,
                itemCount: properties.length,
                onPageChanged: (index) {
                  _page = index;
                  _scheduleNextSlide();
                },
                itemBuilder: (context, index) => PropertyCard(
                  key: ValueKey(properties[index].id ?? index),
                  listing: properties[index],
                  width: double.infinity,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
