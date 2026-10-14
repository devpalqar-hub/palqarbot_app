import 'package:flutter/material.dart';

/// One day's worth of the dealer's performance-trend series.
class TrendPoint {
  final int views;
  final int chats;
  final int visits;
  const TrendPoint(this.views, this.chats, this.visits);
}

/// Draws the 14-day views line (with a soft fill under it), gold dots on
/// days with a chat, and blue dots on days with a site visit — mirroring
/// the inline SVG built by the original analytics mockup.
class TrendChartPainter extends CustomPainter {
  final List<TrendPoint> series;
  final Color lineColor;
  final Color chatColor;
  final Color visitColor;

  TrendChartPainter({
    required this.series,
    required this.lineColor,
    required this.chatColor,
    required this.visitColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    const pad = 8.0;
    final w = size.width;
    final h = size.height;
    final maxV = series.map((s) => s.views).fold<int>(1, (a, b) => a > b ? a : b);
    final stepX = series.length > 1 ? (w - pad * 2) / (series.length - 1) : 0.0;

    double yFor(int v) => h - pad - (v / maxV) * (h - pad * 2 - 14);

    final linePath = Path();
    for (var i = 0; i < series.length; i++) {
      final x = pad + i * stepX;
      final y = yFor(series[i].views);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    final areaPath = Path.from(linePath)
      ..lineTo(pad + (series.length - 1) * stepX, h - pad)
      ..lineTo(pad, h - pad)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(.28), lineColor.withOpacity(.02)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(areaPath, areaPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    final whiteStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = 0; i < series.length; i++) {
      final x = pad + i * stepX;
      final s = series[i];
      if (s.chats > 0) {
        final c = Offset(x, yFor(s.views));
        canvas.drawCircle(c, 4.5, Paint()..color = chatColor);
        canvas.drawCircle(c, 4.5, whiteStroke);
      }
      if (s.visits > 0) {
        final c = Offset(x, h - pad - 6);
        canvas.drawCircle(c, 3.2, Paint()..color = visitColor);
        canvas.drawCircle(c, 3.2, whiteStroke..strokeWidth = 1);
      }
    }

    final lastX = pad + (series.length - 1) * stepX;
    final lastY = yFor(series.last.views);
    canvas.drawCircle(Offset(lastX, lastY), 5, Paint()..color = lineColor);
    canvas.drawCircle(
      Offset(lastX, lastY),
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant TrendChartPainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.chatColor != chatColor ||
        oldDelegate.visitColor != visitColor;
  }
}
