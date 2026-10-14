import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

/// Autoplaying, muted, looping video that fills its parent like
/// `BoxFit.cover` — the banner equivalent of a background photo.
///
/// Shows a spinner while the video loads, and [fallback] if it can't be
/// played. Pauses while another screen covers it or the app is in the
/// background.
class BannerVideo extends StatefulWidget {
  final String url;
  final Widget fallback;

  const BannerVideo({super.key, required this.url, required this.fallback});

  @override
  State<BannerVideo> createState() => _BannerVideoState();
}

class _BannerVideoState extends State<BannerVideo> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _failed = false;
  bool _tickerEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final Uri? uri = Uri.tryParse(widget.url);

    if (uri == null) {
      setState(() => _failed = true);
      return;
    }

    final VideoPlayerController controller = VideoPlayerController.networkUrl(
      uri,
      // A muted banner must not steal audio focus from music etc.
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);

      if (!mounted) return;

      setState(() {});

      if (_tickerEnabled) {
        await controller.play();
      }
    } catch (e) {
      debugPrint('Banner video error: $e');

      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  void didUpdateWidget(covariant BannerVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {
      _controller?.dispose();
      _controller = null;
      _failed = false;
      _init();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // TickerMode is off while another route covers this one.
    final bool enabled = TickerMode.valuesOf(context).enabled;

    if (enabled != _tickerEnabled) {
      _tickerEnabled = enabled;
      _syncPlayback();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncPlayback();
    } else {
      _controller?.pause();
    }
  }

  void _syncPlayback() {
    final VideoPlayerController? controller = _controller;

    if (controller == null || !controller.value.isInitialized) return;

    _tickerEnabled ? controller.play() : controller.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return widget.fallback;
    }

    final VideoPlayerController? controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: const Color(0xff8C1437),
        alignment: Alignment.center,
        child: SizedBox(
          width: 22.w,
          height: 22.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      );
    }

    final Size size = controller.value.size;

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
