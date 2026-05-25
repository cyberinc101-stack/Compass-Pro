import 'package:flutter/material.dart';
import 'dart:math' as math;

class TeleCompass extends StatelessWidget {
  final double heading;

  const TeleCompass({
    Key? key,
    required this.heading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: TeleCompassPainter(heading: heading),
      ),
    );
  }
}

class TeleCompassPainter extends CustomPainter {
  final double heading;

  TeleCompassPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.92;

    // Rotate canvas for the compass dial
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);
    canvas.translate(-center.dx, -center.dy);

    // Draw background with subtle gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [Color(0xFF1E1E1E), Color(0xFF0A0A0A)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Draw outer white circle
    final outerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, outerCirclePaint);

    // Draw inner accent ring
    final accentRing = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.95, accentRing);

    // Draw very fine degree markings
    final markPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 2) {
      final angle = (i - 90) * math.pi / 180;
      final isMajor = i % 10 == 0;
      final isVeryMajor = i % 30 == 0;
      
      final startRadius = isVeryMajor ? radius * 0.84 : (isMajor ? radius * 0.88 : radius * 0.92);
      final endRadius = radius * 0.96;
      
      if (isVeryMajor) {
        markPaint.strokeWidth = 2.5;
      } else if (isMajor) {
        markPaint.strokeWidth = 1.5;
      } else {
        markPaint.strokeWidth = 1;
      }
      
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

    // Draw degree numbers
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 360; i += 30) {
      final angle = (i - 90) * math.pi / 180;
      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFeatures: [FontFeature.tabularFigures()],
          letterSpacing: 0.5,
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + radius * 0.73 * math.cos(angle) - textPainter.width / 2,
        center.dy + radius * 0.73 * math.sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }

    // Draw cardinal directions
    final directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * math.pi / 180;
      
      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: (i == 0) ? Color(0xFFFF5252) : Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + radius * 0.56 * math.cos(angle) - textPainter.width / 2,
        center.dy + radius * 0.56 * math.sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }

    // Draw intercardinal directions
    final interDirections = ['NE', 'SE', 'SW', 'NW'];
    for (int i = 0; i < 4; i++) {
      final angle = ((i * 90 + 45) - 90) * math.pi / 180;
      textPainter.text = TextSpan(
        text: interDirections[i],
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + radius * 0.56 * math.cos(angle) - textPainter.width / 2,
        center.dy + radius * 0.56 * math.sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }

    canvas.restore();

    // Draw dotted crosshair lines extending outside compass (fixed, not rotating)
    final crosshairPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dashWidth = 5.0;
    final dashSpace = 5.0;
    final lineExtension = radius * 1.15; // Extend beyond the compass circle

    // Horizontal dotted line (left to right)
    double startX = center.dx - lineExtension;
    final endX = center.dx + lineExtension;
    
    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, center.dy),
        Offset(math.min(startX + dashWidth, endX), center.dy),
        crosshairPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // Vertical dotted line (top to bottom)
    double startY = center.dy - lineExtension;
    final endY = center.dy + lineExtension;
    
    while (startY < endY) {
      canvas.drawLine(
        Offset(center.dx, startY),
        Offset(center.dx, math.min(startY + dashWidth, endY)),
        crosshairPaint,
      );
      startY += dashWidth + dashSpace;
    }

    // Draw fixed needle pointing north - Classic Spade Design
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Draw needle shadow
    final shadowPath = Path();
    shadowPath.moveTo(0, -radius * 0.65);
    shadowPath.quadraticBezierTo(radius * 0.06, -radius * 0.50, radius * 0.08, -radius * 0.15);
    shadowPath.lineTo(radius * 0.05, 0);
    shadowPath.lineTo(radius * 0.04, radius * 0.10);
    shadowPath.lineTo(-radius * 0.04, radius * 0.10);
    shadowPath.lineTo(-radius * 0.05, 0);
    shadowPath.lineTo(-radius * 0.08, -radius * 0.15);
    shadowPath.quadraticBezierTo(-radius * 0.06, -radius * 0.50, 0, -radius * 0.65);
    shadowPath.close();

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(shadowPath.shift(Offset(2, 2)), shadowPaint);

    // Draw north pointer (spade shape) - red
    final northPath = Path();
    northPath.moveTo(0, -radius * 0.65);
    northPath.quadraticBezierTo(radius * 0.06, -radius * 0.50, radius * 0.08, -radius * 0.15);
    northPath.lineTo(radius * 0.05, 0);
    northPath.lineTo(radius * 0.04, radius * 0.10);
    northPath.lineTo(-radius * 0.04, radius * 0.10);
    northPath.lineTo(-radius * 0.05, 0);
    northPath.lineTo(-radius * 0.08, -radius * 0.15);
    northPath.quadraticBezierTo(-radius * 0.06, -radius * 0.50, 0, -radius * 0.65);
    northPath.close();

    final northPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF5252),
          Color(0xFFE53935),
          Color(0xFFBDBDBD),
        ],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromLTRB(-radius * 0.08, -radius * 0.65, radius * 0.08, radius * 0.10));
    
    canvas.drawPath(northPath, northPaint);

    // Add white outline to needle
    final needleOutline = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(northPath, needleOutline);
    
    // Add highlight line on north pointer
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final highlightPath = Path();
    highlightPath.moveTo(-radius * 0.02, -radius * 0.60);
    highlightPath.lineTo(-radius * 0.04, -radius * 0.20);
    canvas.drawPath(highlightPath, highlightPaint);

    // Draw center circle with metallic gradient
    final centerGradient = Paint()
      ..shader = RadialGradient(
        colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E), Color(0xFF757575)],
      ).createShader(Rect.fromCircle(center: Offset(0, 0), radius: radius * 0.09));
    canvas.drawCircle(Offset(0, 0), radius * 0.09, centerGradient);

    // Add highlight to center
    final centerHighlight = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-radius * 0.025, -radius * 0.025), radius * 0.035, centerHighlight);

    // Center circle outline
    final centerOutline = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(0, 0), radius * 0.09, centerOutline);

    canvas.restore();
  }

  @override
  bool shouldRepaint(TeleCompassPainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}