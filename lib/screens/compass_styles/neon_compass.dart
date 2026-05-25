import 'package:flutter/material.dart';
import 'dart:math' as math;

class NeonCompass extends StatelessWidget {
  final double heading;

  const NeonCompass({
    Key? key,
    required this.heading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer neon glow layers
          Container(
            width: 310,
            height: 310,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.6),
                  blurRadius: 50,
                  spreadRadius: 15,
                ),
                BoxShadow(
                  color: Colors.pink.withOpacity(0.5),
                  blurRadius: 70,
                  spreadRadius: 20,
                ),
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 90,
                  spreadRadius: 25,
                ),
              ],
            ),
          ),
          // Rotating neon rings
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: Container(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _NeonCompassPainter(),
              ),
            ),
          ),
          // Center glow with pulse effect
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.pink.withOpacity(0.8),
                  Colors.purple.withOpacity(0.6),
                  Colors.cyan.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Middle glow ring
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.cyan.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.8),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Center circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: Colors.cyan, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan,
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.pink.withOpacity(0.5),
                  blurRadius: 30,
                ),
              ],
            ),
          ),
          // Center dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  Colors.cyan,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonCompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw neon circles with multiple layers
    for (double r = 0.92; r > 0.3; r -= 0.12) {
      // Outer glow
      canvas.drawCircle(
        center,
        radius * r,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.cyan.withOpacity(0.15)
          ..strokeWidth = 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      
      // Main line
      canvas.drawCircle(
        center,
        radius * r,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.cyan.withOpacity(0.4)
          ..strokeWidth = 1
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    // Draw neon degree markers FIRST (behind text)
    for (int i = 0; i < 360; i += 10) {
      final angle = i * math.pi / 180;
      final isMajor = i % 30 == 0;
      final isCardinal = i % 90 == 0;

      final startRadius = radius * 0.90;  // FIXED: Changed from 0.88 to 0.90
      final endRadius = isCardinal
          ? radius * 0.72  // FIXED: Changed from 0.75 to 0.72 (cardinal marks shorter)
          : isMajor
              ? radius * 0.78  // FIXED: Changed from 0.75 to 0.78
              : radius * 0.85;  // FIXED: Changed from 0.82 to 0.85

      final x1 = center.dx + startRadius * math.sin(angle);
      final y1 = center.dy - startRadius * math.cos(angle);
      final x2 = center.dx + endRadius * math.sin(angle);
      final y2 = center.dy - endRadius * math.cos(angle);

      final glowColor = isCardinal
          ? Colors.pink
          : isMajor
              ? Colors.cyan
              : Colors.cyan;

      // Outer glow
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = glowColor.withOpacity(0.3)
          ..strokeWidth = isMajor ? 6 : 4
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, isMajor ? 8 : 5),
      );

      // Main line
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = isMajor ? glowColor : glowColor.withOpacity(0.6)
          ..strokeWidth = isMajor ? 3 : 2
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, isMajor ? 4 : 2),
      );

      // Inner bright core
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round,
      );
    }

    // Draw cardinal directions with intense neon effect (ON TOP)
    final directions = ['N', 'E', 'S', 'W'];
    final colors = [
      Colors.pink,
      Colors.cyan,
      Colors.purple,
      Colors.greenAccent
    ];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + radius * 0.58 * math.sin(angle);  // FIXED: Changed from 0.7 to 0.58
      final y = center.dy - radius * 0.58 * math.cos(angle);

      // Multiple glow layers for intense neon effect
      for (int layer = 0; layer < 3; layer++) {
        final glowPainter = TextPainter(
          text: TextSpan(
            text: directions[i],
            style: TextStyle(
              foreground: Paint()
                ..color = colors[i].withOpacity(0.3 - (layer * 0.1))
                ..maskFilter = MaskFilter.blur(
                  BlurStyle.normal,
                  30.0 + (layer * 10),
                ),
              fontSize: 32,  // FIXED: Reduced from 36 to 32
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        glowPainter.layout();
        glowPainter.paint(
          canvas,
          Offset(x - glowPainter.width / 2, y - glowPainter.height / 2),
        );
      }

      // Main neon text
      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: colors[i],
            fontSize: 32,  // FIXED: Reduced from 36 to 32
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: colors[i],
                blurRadius: 15,
              ),
              Shadow(
                color: colors[i],
                blurRadius: 30,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );

      // Bright white core
      final corePainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      corePainter.layout();
      corePainter.paint(
        canvas,
        Offset(x - corePainter.width / 2, y - corePainter.height / 2),
      );
    }

    // Draw neon needle with enhanced glow
    final needlePaint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // North pointer (pink) with multiple glow layers
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        center,
        Offset(center.dx, center.dy - radius * 0.55),  // FIXED: Changed from 0.6 to 0.55
        Paint()
          ..color = Colors.pink.withOpacity(0.3 - (i * 0.08))
          ..strokeWidth = 8 + (i * 4)
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 + (i * 5)),
      );
    }
    
    // Main north needle
    needlePaint.color = Colors.pink;
    needlePaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius * 0.55),
      needlePaint,
    );
    
    // Bright core
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius * 0.55),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // South pointer (cyan) with glow
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        center,
        Offset(center.dx, center.dy + radius * 0.55),
        Paint()
          ..color = Colors.cyan.withOpacity(0.3 - (i * 0.08))
          ..strokeWidth = 8 + (i * 4)
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 + (i * 5)),
      );
    }
    
    // Main south needle
    needlePaint.color = Colors.cyan;
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy + radius * 0.55),
      needlePaint,
    );
    
    // Bright core
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy + radius * 0.55),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}