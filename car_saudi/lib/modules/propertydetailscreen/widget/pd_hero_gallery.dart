import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_tokens.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';

/// Full-bleed photo pager with a glass thumbnail rail and photo counter.
///
/// The rail and the pager are kept in sync in both directions (swiping
/// moves the rail, tapping a thumbnail moves the pager). Tapping the photo
/// opens [PdPhotoViewer]. The bottom edge is a canvas-coloured rounded
/// strip so the page body appears to slide up over the gallery.
class PdHeroGallery extends StatefulWidget {
  final Property property;
  final double height;

  const PdHeroGallery({
    super.key,
    required this.property,
    required this.height,
  });

  @override
  State<PdHeroGallery> createState() => _PdHeroGalleryState();
}

class _PdHeroGalleryState extends State<PdHeroGallery> {
  static const double _thumbSize = 46;
  static const double _stripHeight = 28;

  final PageController _pages = PageController();
  final ScrollController _rail = ScrollController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    _rail.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    _revealThumb(index);
  }

  void _revealThumb(int index) {
    if (!_rail.hasClients) return;

    final double extent = _thumbSize.w + 8.w;
    final double target =
        (index * extent - (_rail.position.viewportDimension - extent) / 2)
            .clamp(0.0, _rail.position.maxScrollExtent)
            .toDouble();

    _rail.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openViewer(List<Photo> photos, int index) async {
    final int? last = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PdPhotoViewer(
          photos: photos,
          initialIndex: index,
          heroPrefix: widget.property.id,
        ),
      ),
    );

    if (last != null && last != _index && _pages.hasClients) {
      _pages.jumpToPage(last);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Photo> photos = widget.property.sortedPhotos;
    final int count = photos.length;

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: count == 0 ? 1 : count,
            onPageChanged: _onPageChanged,
            itemBuilder: (_, int i) {
              return GestureDetector(
                onTap: count == 0 ? null : () => _openViewer(photos, i),
                child: count == 0
                    ? _photo(null)
                    : Hero(
                        tag: '${widget.property.id}-photo-$i',
                        child: _photo(photos[i].url),
                      ),
              );
            },
          ),

          // Legibility scrims for the top bar and the bottom HUD.
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.28, 0.58, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: .55),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: .62),
                  ],
                ),
              ),
            ),
          ),

          // HUD: thumbnail rail (start) + counter (end).
          PositionedDirectional(
            start: 16.w,
            end: 16.w,
            bottom: _stripHeight.h + 14.h,
            child: Row(
              children: [
                Expanded(
                  child: count > 1
                      ? _thumbRail(photos)
                      : const SizedBox.shrink(),
                ),
                if (count > 0) ...[
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () => _openViewer(photos, _index),
                    child: PdGlass(
                      borderRadius: BorderRadius.circular(20.r),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 7.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 13.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '${_index + 1} / $count',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Canvas strip - the body "sheet" rising over the photo.
          Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            child: Container(
              height: _stripHeight.h,
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: 9.h),
              decoration: BoxDecoration(
                color: PD.canvas,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: PD.line,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbRail(List<Photo> photos) {
    return SizedBox(
      height: _thumbSize.w,
      child: ListView.separated(
        controller: _rail,
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (_, int i) {
          final bool active = i == _index;

          return GestureDetector(
            onTap: () => _pages.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _thumbSize.w,
              height: _thumbSize.w,
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13.r),
                border: Border.all(
                  color: active
                      ? AppColors.gold
                      : Colors.white.withValues(alpha: .35),
                  width: active ? 2 : 1,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: .45),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Opacity(
                  opacity: active ? 1 : .72,
                  child: Image.network(
                    photos[i].url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(color: PD.line),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _photo(String? url) {
    final Widget fallback = Image.asset('assets/villa.jpg', fit: BoxFit.cover);

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: PD.line),
        if (url != null && url.trim().isNotEmpty)
          Image.network(
            url,
            fit: BoxFit.cover,
            frameBuilder: (_, Widget child, int? frame, bool sync) {
              if (sync) return child;

              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: child,
              );
            },
            errorBuilder: (_, _, _) => fallback,
          )
        else
          fallback,
      ],
    );
  }
}

/// Full-screen photo viewer.
///
/// Pinch or double-tap to zoom, tap once to hide / show the controls, swipe
/// (or use the filmstrip) to move between photos. Pops with the last viewed
/// index so the hero pager can follow along.
class PdPhotoViewer extends StatefulWidget {
  final List<Photo> photos;
  final int initialIndex;

  /// Shared with the hero pager so the tapped photo flies into place.
  final String? heroPrefix;

  const PdPhotoViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
    this.heroPrefix,
  });

  @override
  State<PdPhotoViewer> createState() => _PdPhotoViewerState();
}

class _PdPhotoViewerState extends State<PdPhotoViewer> {
  static const double _thumbSize = 50;

  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  final ScrollController _rail = ScrollController();
  late int _index = widget.initialIndex;
  bool _chrome = true;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _revealThumb(_index, animate: false),
    );
  }

  @override
  void dispose() {
    _pages.dispose();
    _rail.dispose();
    super.dispose();
  }

  void _revealThumb(int index, {bool animate = true}) {
    if (!_rail.hasClients) return;

    final double extent = _thumbSize.w + 8.w;
    final double target =
        (index * extent - (_rail.position.viewportDimension - extent) / 2)
            .clamp(0.0, _rail.position.maxScrollExtent)
            .toDouble();

    if (animate) {
      _rail.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    } else {
      _rail.jumpTo(target);
    }
  }

  void _onPageChanged(int i) {
    setState(() {
      _index = i;
      _zoomed = false;
    });
    _revealThumb(i);
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.photos.length;
    final String caption = widget.photos[_index].caption.trim();
    final EdgeInsets inset = MediaQuery.paddingOf(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) Navigator.of(context).pop(_index);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pages,
              itemCount: count,
              // A zoomed photo pans instead of paging.
              physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
              onPageChanged: _onPageChanged,
              itemBuilder: (_, int i) {
                return _ZoomablePhoto(
                  key: ValueKey(i),
                  url: widget.photos[i].url,
                  heroTag: widget.heroPrefix == null
                      ? null
                      : '${widget.heroPrefix}-photo-$i',
                  onTap: () => setState(() => _chrome = !_chrome),
                  onZoomChanged: (bool zoomed) {
                    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
                  },
                );
              },
            ),

            // Controls fade away on tap for an unobstructed view.
            AnimatedOpacity(
              opacity: _chrome ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              child: IgnorePointer(
                ignoring: !_chrome,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.2, 0.62, 1.0],
                            colors: [
                              Colors.black.withValues(alpha: .7),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: .78),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Top: close + counter.
                    Positioned(
                      top: inset.top + 8.h,
                      left: 16.w,
                      right: 16.w,
                      child: Row(
                        children: [
                          PdCircleButton(
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.of(context).pop(_index),
                          ),
                          const Spacer(),
                          PdGlass(
                            borderRadius: BorderRadius.circular(20.r),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 13.sp,
                                  color: AppColors.gold,
                                ),
                                SizedBox(width: 7.w),
                                Text(
                                  '${_index + 1} / $count',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom: caption + filmstrip.
                    Positioned(
                      left: 16.w,
                      right: 16.w,
                      bottom: inset.bottom + 16.h,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (caption.isNotEmpty) ...[
                            PdGlass(
                              borderRadius: BorderRadius.circular(16.r),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              child: Text(
                                caption,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                          if (count > 1) _filmstrip(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filmstrip() {
    return PdGlass(
      borderRadius: BorderRadius.circular(22.r),
      padding: EdgeInsets.all(8.w),
      child: SizedBox(
        height: _thumbSize.w,
        child: ListView.separated(
          controller: _rail,
          scrollDirection: Axis.horizontal,
          itemCount: widget.photos.length,
          separatorBuilder: (_, _) => SizedBox(width: 8.w),
          itemBuilder: (_, int i) {
            final bool active = i == _index;

            return GestureDetector(
              onTap: () => _pages.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _thumbSize.w,
                height: _thumbSize.w,
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13.r),
                  border: Border.all(
                    color: active
                        ? AppColors.gold
                        : Colors.white.withValues(alpha: .3),
                    width: active ? 2 : 1,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: .45),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Opacity(
                    opacity: active ? 1 : .68,
                    child: Image.network(
                      widget.photos[i].url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: PD.line),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// One photo in the viewer: pinch / pan via [InteractiveViewer], double-tap
/// to zoom into the tapped point (and back out), single tap for [onTap].
class _ZoomablePhoto extends StatefulWidget {
  final String url;
  final String? heroTag;
  final VoidCallback onTap;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomablePhoto({
    super.key,
    required this.url,
    required this.heroTag,
    required this.onTap,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomablePhoto> createState() => _ZoomablePhotoState();
}

class _ZoomablePhotoState extends State<_ZoomablePhoto>
    with SingleTickerProviderStateMixin {
  static const double _doubleTapScale = 2.5;

  final TransformationController _transform = TransformationController();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..addListener(_applyTick);

  Offset _tapAt = Offset.zero;
  bool _zoomed = false;

  double _fromScale = 1, _toScale = 1;
  double _fromX = 0, _toX = 0;
  double _fromY = 0, _toY = 0;

  @override
  void initState() {
    super.initState();
    _transform.addListener(_reportZoom);
  }

  @override
  void dispose() {
    _anim.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _reportZoom() {
    final bool zoomed = _transform.value.getMaxScaleOnAxis() > 1.02;

    if (zoomed == _zoomed) return;

    _zoomed = zoomed;
    widget.onZoomChanged(zoomed);
  }

  Matrix4 _matrix(double scale, double x, double y) =>
      Matrix4(scale, 0, 0, 0, 0, scale, 0, 0, 0, 0, 1, 0, x, y, 0, 1);

  void _applyTick() {
    final double t = Curves.easeOutCubic.transform(_anim.value);

    _transform.value = _matrix(
      _fromScale + (_toScale - _fromScale) * t,
      _fromX + (_toX - _fromX) * t,
      _fromY + (_toY - _fromY) * t,
    );
  }

  void _onDoubleTap() {
    final Matrix4 current = _transform.value;
    final bool zoomIn = current.getMaxScaleOnAxis() <= 1.02;

    _fromScale = current.getMaxScaleOnAxis();
    _fromX = current.storage[12];
    _fromY = current.storage[13];

    _toScale = zoomIn ? _doubleTapScale : 1;
    // Keep the tapped point under the finger while zooming in.
    _toX = zoomIn ? -_tapAt.dx * (_doubleTapScale - 1) : 0;
    _toY = zoomIn ? -_tapAt.dy * (_doubleTapScale - 1) : 0;

    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      widget.url,
      fit: BoxFit.contain,
      loadingBuilder: (_, Widget child, ImageChunkEvent? progress) {
        if (progress == null) return child;

        final int? total = progress.expectedTotalBytes;

        return Center(
          child: SizedBox(
            width: 30.w,
            height: 30.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.gold,
              value: total == null
                  ? null
                  : progress.cumulativeBytesLoaded / total,
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white54,
          size: 40.sp,
        ),
      ),
    );

    if (widget.heroTag != null) {
      image = Hero(tag: widget.heroTag!, child: image);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onDoubleTapDown: (TapDownDetails d) => _tapAt = d.localPosition,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _transform,
        minScale: 1,
        maxScale: 5,
        child: Center(child: image),
      ),
    );
  }
}
