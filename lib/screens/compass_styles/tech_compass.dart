import 'package:flutter/material.dart';
import 'dart:math' as math;

class TechCompass extends StatelessWidget {
  final double heading;

  const TechCompass({
    Key? key,
    required this.heading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: TechCompassPainter(heading: heading),
      ),
    );
  }
}

class TechCompassPainter extends CustomPainter {
  final double heading;

  TechCompassPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.92;

    // Rotate canvas for the compass dial
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);
    canvas.translate(-center.dx, -center.dy);

    // Draw outer metallic ring with gradient - THINNER RIM
    final outerRingPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFBDBDBD), Color(0xFF757575), Color(0xFF9E9E9E)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    // Changed from 0.88 to 0.94 to make rim thinner
    final outerRingPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..addOval(Rect.fromCircle(center: center, radius: radius * 0.94))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(outerRingPath, outerRingPaint);

    // Draw inner shadow on ring - adjusted for new rim size
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, radius * 0.94, shadowPaint);

    // Draw black background - adjusted for new rim size
    final bgPaint = Paint()
      ..color = Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.94, bgPaint);

    // Draw fine inner circle detail - adjusted
    final detailCircle = Paint()
      ..color = Color(0xFF2A2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.91, detailCircle);

    // Draw degree markings
    final markPaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 10) {
      final angle = (i - 90) * math.pi / 180;
      final isMajor = i % 30 == 0;
      
      if (isMajor) {
        markPaint.color = Colors.white;
        markPaint.strokeWidth = 2.5;
      } else {
        markPaint.color = Color(0xFF757575);
        markPaint.strokeWidth = 1.5;
      }
      
      // Adjusted for thinner rim
      final startRadius = isMajor ? radius * 0.78 : radius * 0.83;
      final endRadius = radius * 0.91;
      
      final start = Offset(
        center.dx + startRadius * math.cos(angle),
        center.dy + startRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + endRadius * math.cos(angle),
        center.dy + endRadius * math.sin(angle),
      );

      canvas.drawLine(start, end, markPaint);
    }

    // Draw degree numbers - SKIP 0, 90, 180, 270 to avoid clash with cardinal directions
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 360; i += 30) {
      // Skip cardinal direction positions (0, 90, 180, 270)
      if (i == 0 || i == 90 || i == 180 || i == 270) continue;
      
      final angle = (i - 90) * math.pi / 180;
      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + radius * 0.68 * math.cos(angle) - textPainter.width / 2,
        center.dy + radius * 0.68 * math.sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }

    // Draw cardinal directions - positioned where 0, 90, 180, 270 would be
    final directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * math.pi / 180;
      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: i == 0 ? Color(0xFFFF5252) : Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      );
      textPainter.layout();

      // Positioned at same radius as numbers would be
      final textOffset = Offset(
        center.dx + radius * 0.68 * math.cos(angle) - textPainter.width / 2,
        center.dy + radius * 0.68 * math.sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }

    canvas.restore();

    // Draw fixed needle pointing north
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Draw needle shadow
    final shadowNeedlePath = Path();
    shadowNeedlePath.moveTo(0, -radius * 0.70);
    shadowNeedlePath.lineTo(radius * 0.06, 0);
    shadowNeedlePath.lineTo(0, radius * 0.20);
    shadowNeedlePath.lineTo(-radius * 0.06, 0);
    shadowNeedlePath.close();

    final needleShadow = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(shadowNeedlePath.shift(Offset(2, 2)), needleShadow);

    // Draw north pointer (red)
    final needlePathRed = Path();
    needlePathRed.moveTo(0, -radius * 0.70);
    needlePathRed.lineTo(radius * 0.06, 0);
    needlePathRed.lineTo(0, radius * 0.05);
    needlePathRed.lineTo(-radius * 0.06, 0);
    needlePathRed.close();

    final redPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF5252), Color(0xFFE53935)],
      ).createShader(Rect.fromLTRB(-radius * 0.06, -radius * 0.70, radius * 0.06, radius * 0.05));
    canvas.drawPath(needlePathRed, redPaint);

    // Draw south pointer (white/gray)
    final needlePathWhite = Path();
    needlePathWhite.moveTo(0, radius * 0.20);
    needlePathWhite.lineTo(radius * 0.06, 0);
    needlePathWhite.lineTo(0, -radius * 0.05);
    needlePathWhite.lineTo(-radius * 0.06, 0);
    needlePathWhite.close();

    final whitePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
      ).createShader(Rect.fromLTRB(-radius * 0.06, -radius * 0.05, radius * 0.06, radius * 0.20));
    canvas.drawPath(needlePathWhite, whitePaint);

    // Draw center circle with metallic look
    final centerGradient = Paint()
      ..shader = RadialGradient(
        colors: [Color(0xFFBDBDBD), Color(0xFF757575)],
      ).createShader(Rect.fromCircle(center: Offset(0, 0), radius: radius * 0.10));
    canvas.drawCircle(Offset(0, 0), radius * 0.10, centerGradient);

    final centerHighlight = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-radius * 0.03, -radius * 0.03), radius * 0.04, centerHighlight);

    canvas.restore();
  }

  @override
  bool shouldRepaint(TechCompassPainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}