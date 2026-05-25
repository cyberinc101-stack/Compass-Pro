import 'package:flutter/material.dart';
import 'dart:math' as math;

class MinimalCompass extends StatelessWidget {
  final double heading;

  const MinimalCompass({
    Key? key,
    required this.heading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thin outer circle
          Container(
            width: 290,
            height: 290,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12, width: 2),
            ),
          ),
          // Inner subtle circle
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
            ),
          ),
          // Rotating minimal markers
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: Container(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _MinimalCompassPainter(),
              ),
            ),
          ),
          // Simple north indicator (refined)
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: Container(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow
                  Transform.translate(
                    offset: const Offset(2, 2),
                    child: Icon(
                      Icons.navigation,
                      size: 56,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                  // Main icon
                  Icon(
                    Icons.navigation,
                    size: 56,
                    color: Colors.red[600],
                  ),
                  // Subtle highlight
                  Transform.translate(
                    offset: const Offset(-1, -1),
                    child: Icon(
                      Icons.navigation,
                      size: 56,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Center dot for precision
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
              border: Border.all(color: Colors.grey[400]!, width: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimalCompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw minimal degree markers (only every 30 degrees)
    final paint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 30) {
      final angle = i * math.pi / 180;
      final isCardinal = i % 90 == 0;

      if (!isCardinal) {
        final startRadius = radius * 0.92;
        final endRadius = radius * 0.86;  // FIXED: Changed from 0.88 to 0.86

        final x1 = center.dx + startRadius * math.sin(angle);
        final y1 = center.dy - startRadius * math.cos(angle);
        final x2 = center.dx + endRadius * math.sin(angle);
        final y2 = center.dy - endRadius * math.cos(angle);

        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }

    // Draw only cardinal directions
    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + radius * 0.75 * math.sin(angle);  // FIXED: Changed from 0.85 to 0.75
      final y = center.dy - radius * 0.75 * math.cos(angle);  // FIXED: Changed from 0.85 to 0.75

      // Subtle shadow
      final shadowPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: Colors.black.withOpacity(0.1),
            fontSize: 28,  // FIXED: Increased from 24 to 28 for better visibility
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      shadowPainter.layout();
      shadowPainter.paint(
        canvas,
        Offset(x - shadowPainter.width / 2 + 1, y - shadowPainter.height / 2 + 1),
      );

      // Main text
      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: i == 0 ? Colors.red[600] : Colors.black54,
            fontSize: 28,  // FIXED: Increased from 24 to 28
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );

      // Subtle highlight for depth
      if (i == 0) {
        final highlightPainter = TextPainter(
          text: TextSpan(
            text: directions[i],
            style: TextStyle(
              color: Colors.red.withOpacity(0.2),
              fontSize: 28,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        highlightPainter.layout();
        highlightPainter.paint(
          canvas,
          Offset(x - highlightPainter.width / 2 - 0.5, y - highlightPainter.height / 2 - 0.5),
        );
      }
    }

    // Draw subtle degree numbers at major marks (optional enhancement)
    final degreeNumbers = ['30', '60', '120', '150', '210', '240', '300', '330'];
    final degreeAngles = [30, 60, 120, 150, 210, 240, 300, 330];

    for (int i = 0; i < degreeNumbers.length; i++) {
      final angle = degreeAngles[i] * math.pi / 180;
      final x = center.dx + radius * 0.65 * math.sin(angle);
      final y = center.dy - radius * 0.65 * math.cos(angle);

      final degreePainter = TextPainter(
        text: TextSpan(
          text: degreeNumbers[i],
          style: const TextStyle(
            color: Colors.black26,
            fontSize: 11,
            fontWeight: FontWeight.w300,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      degreePainter.layout();
      degreePainter.paint(
        canvas,
        Offset(x - degreePainter.width / 2, y - degreePainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}