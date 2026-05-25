import 'package:flutter/material.dart';
import 'dart:math' as math;

class GradientCompass extends StatelessWidget {
  final double heading;

  const GradientCompass({
    Key? key,
    required this.heading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Main compass circle with animated gradient
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Colors.purple,
                  Colors.blue,
                  Colors.cyan,
                  Colors.green,
                  Colors.yellow,
                  Colors.orange,
                  Colors.red,
                  Colors.pink,
                  Colors.purple,
                ],
                transform: GradientRotation(-heading * math.pi / 180),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Inner circle
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black87,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: -5,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          // Rotating markers
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: Container(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _GradientCompassPainter(),
              ),
            ),
          ),
          // Enhanced center circle with 3D effect
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  Colors.purple[300]!,
                  Colors.purple[600]!,
                  Colors.purple[900]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
          ),
          // Inner rim for depth
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.pink.withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
          // Navigation icon with glow
          Container(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Icon glow
                Icon(
                  Icons.navigation,
                  color: Colors.white.withOpacity(0.3),
                  size: 36,
                ),
                // Main icon
                Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 32,
                  shadows: [
                    Shadow(
                      color: Colors.purple,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientCompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw degree markers FIRST (behind text)
    for (int i = 0; i < 360; i += 10) {
      final angle = i * math.pi / 180;
      final isMajor = i % 30 == 0;
      final isCardinal = i % 90 == 0;

      final startRadius = radius * 0.88;  // FIXED: Moved from 0.85 to 0.88
      final endRadius = isCardinal
          ? radius * 0.73  // FIXED: Changed from 0.75 to 0.73 (cardinal marks)
          : isMajor
              ? radius * 0.78  // FIXED: Changed from 0.75 to 0.78 (major marks)
              : radius * 0.83;  // FIXED: Changed from 0.8 to 0.83 (minor marks)

      final x1 = center.dx + startRadius * math.sin(angle);
      final y1 = center.dy - startRadius * math.cos(angle);
      final x2 = center.dx + endRadius * math.sin(angle);
      final y2 = center.dy - endRadius * math.cos(angle);

      // Glow effect on major marks
      if (isMajor) {
        canvas.drawLine(
          Offset(x1, y1),
          Offset(x2, y2),
          Paint()
            ..color = Colors.purple.withOpacity(0.3)
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }

      // Main line
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = Colors.white
          ..strokeWidth = isCardinal ? 4 : isMajor ? 3 : 2
          ..strokeCap = StrokeCap.round,
      );
    }

    // Draw cardinal directions (on top of markers)
    final directions = ['N', 'E', 'S', 'W'];
    final colors = [Colors.red, Colors.cyan, Colors.white, Colors.yellow];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + radius * 0.60 * math.sin(angle);  // FIXED: Changed from 0.7 to 0.60
      final y = center.dy - radius * 0.60 * math.cos(angle);  // FIXED: Changed from 0.7 to 0.60

      // Outer glow
      final glowPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: colors[i].withOpacity(0.5),
            fontSize: 30,  // FIXED: Reduced from 32 to 30
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

      // Shadow for depth
      final shadowPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: const TextStyle(
            color: Colors.black,
            fontSize: 30,  // FIXED: Reduced from 32 to 30
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      shadowPainter.layout();
      shadowPainter.paint(
        canvas,
        Offset(x - shadowPainter.width / 2 + 2, y - shadowPainter.height / 2 + 2),
      );

      // Main text
      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: colors[i],
            fontSize: 30,  // FIXED: Reduced from 32 to 30
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(
                color: Colors.black,
                blurRadius: 8,
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

      // Highlight for 3D effect
      final highlightPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 30,  // FIXED: Reduced from 32 to 30
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      highlightPainter.layout();
      highlightPainter.paint(
        canvas,
        Offset(x - highlightPainter.width / 2 - 1, y - highlightPainter.height / 2 - 1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}   


// last compass for night and day