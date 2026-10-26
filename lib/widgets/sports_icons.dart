import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShuttlecockIcon extends StatelessWidget {
  const ShuttlecockIcon({
    super.key,
    this.size = 24,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ShuttlecockPainter(color: color),
    );
  }
}

class _ShuttlecockPainter extends CustomPainter {
  const _ShuttlecockPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Draw cork (rounded base at bottom right or tilted)
    // Tilted shuttlecock matching the branding icon:
    canvas.save();
    canvas.translate(w * 0.5, h * 0.5);
    canvas.rotate(-math.pi / 4);
    canvas.translate(-w * 0.5, -h * 0.5);

    // Feathers cone: top wide, bottom narrow
    final featherPath = Path()
      ..moveTo(w * 0.22, h * 0.2)
      ..lineTo(w * 0.78, h * 0.2)
      ..lineTo(w * 0.62, h * 0.65)
      ..lineTo(w * 0.38, h * 0.65)
      ..close();

    // Subtle feather fill with low opacity
    final softFill = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(featherPath, softFill);
    canvas.drawPath(featherPath, strokePaint);

    // Inner feather ribs
    canvas.drawLine(
        Offset(w * 0.36, h * 0.2), Offset(w * 0.44, h * 0.65), strokePaint);
    canvas.drawLine(
        Offset(w * 0.50, h * 0.2), Offset(w * 0.50, h * 0.65), strokePaint);
    canvas.drawLine(
        Offset(w * 0.64, h * 0.2), Offset(w * 0.56, h * 0.65), strokePaint);

    // Horizontal feather band
    canvas.drawLine(
        Offset(w * 0.30, h * 0.45), Offset(w * 0.70, h * 0.45), strokePaint);

    // Cork at the bottom
    final corkRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.76), width: w * 0.32, height: h * 0.26),
      bottomLeft: Radius.circular(w * 0.16),
      bottomRight: Radius.circular(w * 0.16),
      topLeft: Radius.circular(w * 0.04),
      topRight: Radius.circular(w * 0.04),
    );
    canvas.drawRRect(corkRect, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShuttlecockPainter oldDelegate) =>
      oldDelegate.color != color;
}

class PickleballPaddleIcon extends StatelessWidget {
  const PickleballPaddleIcon({
    super.key,
    this.size = 24,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PickleballPaddlePainter(color: color),
    );
  }
}

class _PickleballPaddlePainter extends CustomPainter {
  const _PickleballPaddlePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    canvas.save();
    canvas.translate(w * 0.5, h * 0.5);
    canvas.rotate(-math.pi / 4);
    canvas.translate(-w * 0.5, -h * 0.5);

    // Paddle head
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.38), width: w * 0.56, height: h * 0.52),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(headRect, strokePaint);

    // Holes in paddle
    final holePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final r = w * 0.04;
    canvas.drawCircle(Offset(w * 0.42, h * 0.32), r, holePaint);
    canvas.drawCircle(Offset(w * 0.58, h * 0.32), r, holePaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.44), r, holePaint);

    // Handle
    final handleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.78), width: w * 0.16, height: h * 0.32),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(handleRect, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PickleballPaddlePainter oldDelegate) =>
      oldDelegate.color != color;
}

class TennisBallIcon extends StatelessWidget {
  const TennisBallIcon({
    super.key,
    this.size = 24,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TennisBallPainter(color: color),
    );
  }
}

class _TennisBallPainter extends CustomPainter {
  const _TennisBallPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);
    final radius = w * 0.42;

    // Ball outline
    canvas.drawCircle(center, radius, strokePaint);

    // Curved seam 1
    final seamPath1 = Path()
      ..moveTo(w * 0.22, h * 0.20)
      ..quadraticBezierTo(w * 0.55, h * 0.35, w * 0.55, h * 0.65)
      ..quadraticBezierTo(w * 0.55, h * 0.80, w * 0.78, h * 0.88);
    canvas.drawPath(seamPath1, strokePaint);
  }

  @override
  bool shouldRepaint(_TennisBallPainter oldDelegate) =>
      oldDelegate.color != color;
}
