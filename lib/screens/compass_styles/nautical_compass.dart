import 'package:flutter/material.dart';
import 'dart:math' as math;

class NauticalCompass extends StatelessWidget {
  final double heading;

  const NauticalCompass({
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
          // Ocean background with waves effect
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blue.shade100,
                  Colors.blue.shade300,
                  Colors.blue.shade600,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Outer brass ring with 3D effect
          Container(
            width: 294,
            height: 294,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFDAA520),
                  const Color(0xFFB8860B),
                  const Color(0xFF8B6914),
                  const Color(0xFFB8860B),
                ],
              ),
            ),
          ),
          // Middle brass ring
          Container(
            width: 286,
            height: 286,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFB8860B),
            ),
          ),
          // Inner white circle with subtle texture
          Container(
            width: 270,
            height: 270,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: -5,
                ),
              ],
            ),
          ),
          // Rotating compass rose
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: Container(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: _NauticalCompassPainter(),
              ),
            ),
          ),
          // Center anchor with 3D effect
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  const Color(0xFFDAA520),
                  const Color(0xFFB8860B),
                  const Color(0xFF8B6914),
                ],
              ),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.anchor,
              color: Colors.white,
              size: 28,
            ),
          ),
          // Anchor shadow for depth
          Positioned(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFB8860B).withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NauticalCompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw degree markings FIRST (behind everything)
    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final isMajor = i % 30 == 0;
      final isCardinal = i % 90 == 0;

      if (!isCardinal) {  // Don't draw marks at cardinal positions (covered by rose)
        final startRadius = radius * 0.96;  // FIXED: Changed from 0.95 to 0.96
        final endRadius = isMajor 
            ? radius * 0.80  // FIXED: Changed from 0.88 to 0.80 (much shorter)
            : radius * 0.88;  // FIXED: Changed from 0.92 to 0.88

        final x1 = center.dx + startRadius * math.sin(angle);
        final y1 = center.dy - startRadius * math.cos(angle);
        final x2 = center.dx + endRadius * math.sin(angle);
        final y2 = center.dy - endRadius * math.cos(angle);

        canvas.drawLine(
          Offset(x1, y1),
          Offset(x2, y2),
          Paint()
            ..color = const Color(0xFFB8860B)
            ..strokeWidth = isMajor ? 2.5 : 1.5
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // Draw compass rose points with 3D effect
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw 8 main points (cardinal and intercardinal)
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * math.pi / 180;
      final isCardinal = i % 2 == 0;
      final isNorth = i == 0;

      final path = Path();
      path.moveTo(
        center.dx + radius * 0.75 * math.sin(angle),  // FIXED: Changed from 0.8 to 0.75
        center.dy - radius * 0.75 * math.cos(angle),
      );
      path.lineTo(
        center.dx + radius * 0.15 * math.sin(angle + math.pi / 8),
        center.dy - radius * 0.15 * math.cos(angle + math.pi / 8),
      );
      path.lineTo(
        center.dx + radius * 0.15 * math.sin(angle - math.pi / 8),
        center.dy - radius * 0.15 * math.cos(angle - math.pi / 8),
      );
      path.close();

      // Shadow
      canvas.drawPath(
        path.shift(const Offset(2, 2)),
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Main color with gradient effect
      paint.color = isNorth
          ? Colors.red.shade700
          : isCardinal
              ? Colors.blue.shade800
              : Colors.blue.shade400;

      canvas.drawPath(path, paint);

      // Highlight for 3D effect
      final highlightPath = Path();
      highlightPath.moveTo(
        center.dx + radius * 0.75 * math.sin(angle),
        center.dy - radius * 0.75 * math.cos(angle),
      );
      highlightPath.lineTo(
        center.dx + radius * 0.15 * math.sin(angle - math.pi / 8),
        center.dy - radius * 0.15 * math.cos(angle - math.pi / 8),
      );
      
      canvas.drawPath(
        highlightPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white.withOpacity(0.4)
          ..strokeWidth = 2,
      );

      // Gold outline
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFB8860B)
          ..strokeWidth = 2,
      );
    }

    // Draw cardinal letters (on top of everything)
    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + radius * 0.64 * math.sin(angle);  // FIXED: Changed from 0.88 to 0.64
      final y = center.dy - radius * 0.64 * math.cos(angle);

      // Shadow for depth
      final shadowPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: Colors.black.withOpacity(0.3),
            fontSize: 26,  // FIXED: Reduced from 28 to 26
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      shadowPainter.layout();
      shadowPainter.paint(
        canvas,
        Offset(x - shadowPainter.width / 2 + 1.5, y - shadowPainter.height / 2 + 1.5),
      );

      // Main text
      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: i == 0 ? Colors.red.shade700 : const Color(0xFF1565C0),
            fontSize: 26,  // FIXED: Reduced from 28 to 26
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 2,
                offset: const Offset(-1, -1),
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

      // Gold outline for letters
      final outlinePainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5
              ..color = const Color(0xFFB8860B),
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      outlinePainter.layout();
      outlinePainter.paint(
        canvas,
        Offset(x - outlinePainter.width / 2, y - outlinePainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}