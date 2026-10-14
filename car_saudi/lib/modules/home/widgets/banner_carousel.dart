import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:villas_qatar/Core/theme/app_motion.dart';
import 'package:villas_qatar/modules/home/model/banner_model.dart';
import 'package:villas_qatar/modules/home/widgets/sponser_banner.dart';

/// Looping, auto-advancing carousel of [InvestmentBanner]s with page dots —
/// used when there is more than one banner to show. Swiping works too; the
/// auto-advance pauses while the user is dragging or another screen covers
/// this one.
class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  final ValueChanged<BannerModel> onTap;

  const BannerCarousel({super.key, required this.banners, required this.onTap});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  static const Duration _slideInterval = Duration(seconds: 5);
  static const Duration _slideDuration = Duration(milliseconds: 500);

  /// Start far from page 0 (as a multiple of the banner count) so the user
  /// can also swipe backwards from the first banner; `% count` is the banner.
  static const int _loopBase = 1000;

  late PageController _pageController;
  Timer? _autoSlideTimer;
  bool _userDragging = false;
  int _page = 0;

  int get _count => widget.banners.length;

  @override
  void initState() {
    super.initState();
    _page = _loopBase * _count;
    _pageController = PageController(initialPage: _page);
    _scheduleNextSlide();
  }

  @override
  void didUpdateWidget(covariant BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.banners.length != _count) {
      _page = _loopBase * _count;

      if (_pageController.hasClients) {
        _pageController.jumpToPage(_page);
      }

      _scheduleNextSlide();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _scheduleNextSlide() {
    _autoSlideTimer?.cancel();

    if (_count < 2) return;

    _autoSlideTimer = Timer(_slideInterval, _slideToNext);
  }

  void _slideToNext() {
    if (!mounted) return;

    // TickerMode is off while another route covers the home screen.
    if (_userDragging ||
        !_pageController.hasClients ||
        !TickerMode.valuesOf(context).enabled) {
      _scheduleNextSlide();
      return;
    }

    // onPageChanged schedules the following slide.
    _pageController.nextPage(duration: _slideDuration, curve: AppMotion.curve);
  }

  @override
  Widget build(BuildContext context) {
    final int count = _count;

    return SizedBox(
      height: 150.h,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.depth != 0) return false;

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
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _page = index);
                _scheduleNextSlide();
              },
              itemBuilder: (context, index) {
                final BannerModel banner = widget.banners[index % count];

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: InvestmentBanner(
                    banner: banner,
                    onTap: () => widget.onTap(banner),
                  ),
                );
              },
            ),
          ),

          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 8.h,
            child: IgnorePointer(
              child: _Dots(count: count, active: _page % count),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int active;

  const _Dots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool isActive = i == active;

        return AnimatedContainer(
          duration: AppMotion.fast,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          width: isActive ? 14.w : 5.w,
          height: 5.w,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(.55),
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }),
    );
  }
}
