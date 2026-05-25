import 'package:flutter/material.dart';
import 'dart:math' as math;

class VintageCompass extends StatelessWidget {
  final double heading;

  const VintageCompass({
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
          // Aged paper background with texture
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFF5E6D3),
                  const Color(0xFFE8D4B8),
                  const Color(0xFFD4B896),
                  const Color(0xFFC4A882),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: const Color(0xFF8B7355).withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: -5,
                ),
              ],
            ),
          ),
          // Weathered edge with 3D effect
          Container(
            width: 294,
            height: 294,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF9B8265),
                  const Color(0xFF8B7355),
                  const Color(0xFF6B5845),
                ],
              ),
            ),
          ),
          Container(
            width: 286,
            height: 286,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8D4B8),
            ),
          ),
          // Rotating vintage compass rose
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: Container(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _VintageCompassPainter(),
              ),
            ),
          ),
          // Center ornament with depth
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  const Color(0xFF9B8265),
                  const Color(0xFF8B7355),
                  const Color(0xFF6B5845),
                ],
              ),
              border: Border.all(color: const Color(0xFFD4AF37), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B7355),
            ),
            child: const Center(
              child: Text(
                '✶',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 32,
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
          ),
        ],
      ),
    );
  }
}

class _VintageCompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw decorative circles FIRST (behind everything)
    canvas.drawCircle(
      center,
      radius * 0.88,  // FIXED: Changed from 0.92 to 0.88
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF8B7355)
        ..strokeWidth = 1.5,
    );

    canvas.drawCircle(
      center,
      radius * 0.85,  // FIXED: Changed from 0.9 to 0.85
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF8B7355)
        ..strokeWidth = 2.5,
    );

    // Draw ornate compass rose
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw 16 points (traditional compass rose)
    for (int i = 0; i < 16; i++) {
      final angle = (i * 22.5) * math.pi / 180;
      final isCardinal = i % 4 == 0;
      final isIntercardinal = i % 2 == 0;

      final pointLength = isCardinal
          ? radius * 0.68  // FIXED: Changed from 0.75 to 0.68
          : isIntercardinal
              ? radius * 0.52  // FIXED: Changed from 0.55 to 0.52
              : radius * 0.35;

      final path = Path();
      path.moveTo(
        center.dx + pointLength * math.sin(angle),
        center.dy - pointLength * math.cos(angle),
      );

      final sideAngle = isCardinal ? math.pi / 16 : math.pi / 24;

      path.lineTo(
        center.dx + radius * 0.2 * math.sin(angle + sideAngle),
        center.dy - radius * 0.2 * math.cos(angle + sideAngle),
      );
      path.lineTo(
        center.dx + radius * 0.2 * math.sin(angle - sideAngle),
        center.dy - radius * 0.2 * math.cos(angle - sideAngle),
      );
      path.close();

      // Shadow for depth
      canvas.drawPath(
        path.shift(const Offset(1.5, 1.5)),
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      // Alternating colors for vintage look
      paint.color = (i == 0)
          ? const Color(0xFF8B0000)
          : (isCardinal)
              ? const Color(0xFF2F4F4F)
              : (isIntercardinal)
                  ? const Color(0xFF8B7355)
                  : const Color(0xFFA0826D);

      canvas.drawPath(path, paint);

      // Highlight for 3D effect
      if (isCardinal || isIntercardinal) {
        final highlightPath = Path();
        highlightPath.moveTo(
          center.dx + pointLength * math.sin(angle),
          center.dy - pointLength * math.cos(angle),
        );
        highlightPath.lineTo(
          center.dx + radius * 0.2 * math.sin(angle - sideAngle),
          center.dy - radius * 0.2 * math.cos(angle - sideAngle),
        );
        
        canvas.drawPath(
          highlightPath,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.white.withOpacity(0.3)
            ..strokeWidth = 1.5,
        );
      }

      // Outline for aged effect
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFF654321)
          ..strokeWidth = 1.5,
      );
    }

    // Draw cardinal letters in vintage script style (ON TOP)
    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + radius * 0.75 * math.sin(angle);  // FIXED: Changed from 0.85 to 0.75
      final y = center.dy - radius * 0.75 * math.cos(angle);  // FIXED: Changed from 0.85 to 0.75

      // Drop shadow
      final shadowPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: Colors.black.withOpacity(0.3),
            fontSize: 30,  // FIXED: Reduced from 32 to 30
            fontWeight: FontWeight.w900,
            fontFamily: 'serif',
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
            color: i == 0 ? const Color(0xFF8B0000) : const Color(0xFF2F4F4F),
            fontSize: 30,  // FIXED: Reduced from 32 to 30
            fontWeight: FontWeight.w900,
            fontFamily: 'serif',
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 2,
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

      // Highlight for embossed effect
      final highlightPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 30,
            fontWeight: FontWeight.w900,
            fontFamily: 'serif',
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

    // Draw age spots/texture (optional vintage detail)
    final random = math.Random(42);
    for (int i = 0; i < 30; i++) {
      final spotAngle = random.nextDouble() * 2 * math.pi;
      final spotRadius = random.nextDouble() * radius * 0.8;
      final spotX = center.dx + spotRadius * math.cos(spotAngle);
      final spotY = center.dy + spotRadius * math.sin(spotAngle);
      
      canvas.drawCircle(
        Offset(spotX, spotY),
        random.nextDouble() * 1.5 + 0.5,
        Paint()
          ..color = const Color(0xFF8B7355).withOpacity(0.1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}