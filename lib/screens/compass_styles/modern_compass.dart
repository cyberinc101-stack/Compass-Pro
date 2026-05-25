import 'package:flutter/material.dart';
import 'dart:math' as math;

class ModernCompass extends StatelessWidget {
  final double heading;

  const ModernCompass({
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
          // Outer glow ring
          Container(
            width: 310,
            height: 310,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Main circle
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.blue.shade700, width: 4),
            ),
          ),
          // Inner gradient circle
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                ],
              ),
            ),
          ),
          // Rotating compass face
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: Container(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _ModernCompassPainter(),
              ),
            ),
          ),
          // Enhanced center design
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blue.shade500,
                  Colors.blue.shade700,
                  Colors.blue.shade900,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade700,
            ),
            child: Center(
              child: Icon(
                Icons.my_location,
                color: Colors.white,
                size: 32,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
          // Center dot for precision
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernCompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw sleek degree markers
    for (int i = 0; i < 360; i += 6) {
      final angle = i * math.pi / 180;
      final isMajor = i % 30 == 0;
      final isCardinal = i % 90 == 0;

      final startRadius = radius * 0.92;  // FIXED: Changed from 0.9 to 0.92
      final endRadius = isCardinal
          ? radius * 0.73  // FIXED: Changed from 0.7 to 0.73
          : isMajor
              ? radius * 0.80  // FIXED: Same as 0.8
              : radius * 0.87;  // FIXED: Changed from 0.85 to 0.87

      final x1 = center.dx + startRadius * math.sin(angle);
      final y1 = center.dy - startRadius * math.cos(angle);
      final x2 = center.dx + endRadius * math.sin(angle);
      final y2 = center.dy - endRadius * math.cos(angle);

      final paint = Paint()
        ..color = isCardinal
            ? Colors.blue.shade700
            : isMajor
                ? Colors.blue.shade400
                : Colors.blue.shade200
        ..strokeWidth = isCardinal ? 3 : isMajor ? 2 : 1
        ..strokeCap = StrokeCap.round;

      // Add subtle glow to cardinal marks
      if (isCardinal) {
        canvas.drawLine(
          Offset(x1, y1),
          Offset(x2, y2),
          Paint()
            ..color = Colors.blue.withOpacity(0.3)
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw cardinal directions
    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + radius * 0.56 * math.sin(angle);  // FIXED: Changed from 0.62 to 0.56
      final y = center.dy - radius * 0.56 * math.cos(angle);  // FIXED: Changed from 0.62 to 0.56

      // Shadow for depth
      final shadowPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: Colors.black.withOpacity(0.15),
            fontSize: 30,  // FIXED: Reduced from 32 to 30
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      shadowPainter.layout();
      shadowPainter.paint(
        canvas,
        Offset(x - shadowPainter.width / 2 + 1.5, y - shadowPainter.height / 2 + 1.5),
      );

      // Glow effect
      final glowPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            foreground: Paint()
              ..color = (i == 0 ? Colors.red.shade600 : Colors.blue.shade700)
                  .withOpacity(0.4)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      glowPainter.layout();
      glowPainter.paint(
        canvas,
        Offset(x - glowPainter.width / 2, y - glowPainter.height / 2),
      );

      // Main text
      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: i == 0 ? Colors.red.shade600 : Colors.blue.shade700,
            fontSize: 30,  // FIXED: Reduced from 32 to 30
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );

      // Highlight
      final highlightPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 30,
            fontWeight: FontWeight.w600,
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

    // Draw degree numbers
    for (int i = 0; i < 360; i += 30) {
      if (i % 90 != 0) {
        final angle = i * math.pi / 180;
        final x = center.dx + radius * 0.68 * math.sin(angle);  // FIXED: Changed from 0.65 to 0.68
        final y = center.dy - radius * 0.68 * math.cos(angle);  // FIXED: Changed from 0.65 to 0.68

        // Shadow
        final shadowPainter = TextPainter(
          text: TextSpan(
            text: '$i°',
            style: TextStyle(
              color: Colors.black.withOpacity(0.1),
              fontSize: 13,  // FIXED: Reduced from 14 to 13
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        shadowPainter.layout();
        shadowPainter.paint(
          canvas,
          Offset(x - shadowPainter.width / 2 + 0.5, y - shadowPainter.height / 2 + 0.5),
        );

        // Main text
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$i°',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 13,  // FIXED: Reduced from 14 to 13
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}