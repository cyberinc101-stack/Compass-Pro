import 'package:flutter/material.dart';
import 'dart:math' as math;

class HighTechCompass extends StatelessWidget {
  final double heading;

  const HighTechCompass({
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
          // Outer futuristic ring
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0A0E27),
                  const Color(0xFF1A1F3A),
                ],
              ),
              border: Border.all(color: Colors.cyanAccent, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Inner glow ring
          Container(
            width: 286,
            height: 286,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.cyan.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          // Dark background
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0D1117),
            ),
          ),
          // Rotating compass face
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: Container(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _HighTechCompassPainter(),
              ),
            ),
          ),
          // HUD overlay
          CustomPaint(
            size: const Size(300, 300),
            painter: _HUDPainter(),
          ),
          // Center circle indicator (replaces the coordinate display)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.cyanAccent,
                  Colors.cyan,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          // Small center dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0D1117),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighTechCompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw digital-style degree markers
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;

    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final isMajor = i % 45 == 0;
      final isMinor = i % 15 == 0;

      final startRadius = radius * 0.90;
      final endRadius = isMajor
          ? radius * 0.72
          : isMinor
              ? radius * 0.78
              : radius * 0.85;

      final x1 = center.dx + startRadius * math.sin(angle);
      final y1 = center.dy - startRadius * math.cos(angle);
      final x2 = center.dx + endRadius * math.sin(angle);
      final y2 = center.dy - endRadius * math.cos(angle);

      // Glow effect on major marks
      if (isMajor || isMinor) {
        canvas.drawLine(
          Offset(x1, y1),
          Offset(x2, y2),
          Paint()
            ..color = Colors.cyanAccent.withOpacity(0.3)
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.square
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }

      paint.strokeWidth = isMajor ? 3 : isMinor ? 2 : 1.5;
      paint.color = isMajor 
          ? Colors.cyanAccent 
          : isMinor 
              ? Colors.cyan 
              : Colors.cyan.withOpacity(0.5);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw cardinal directions
    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + radius * 0.56 * math.sin(angle);
      final y = center.dy - radius * 0.56 * math.cos(angle);

      final fontSize = 24.0;
      
      // Shadow for depth
      final shadowPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: Colors.black.withOpacity(0.7),
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
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
              ..color = (i == 0 ? Colors.redAccent : Colors.cyanAccent)
                  .withOpacity(0.5)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
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
            color: i == 0 ? Colors.redAccent : Colors.cyanAccent,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            shadows: [
              Shadow(
                color: i == 0 
                    ? Colors.redAccent.withOpacity(0.8)
                    : Colors.cyanAccent.withOpacity(0.8),
                blurRadius: 6,
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
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HUDPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.3)
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.6)
      ..strokeWidth = 1.5;

    // Top targeting line with glow
    canvas.drawLine(
      Offset(center.dx, center.dy - 60),
      Offset(center.dx, center.dy - 170),
      glowPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 60),
      Offset(center.dx, center.dy - 170),
      paint,
    );

    // Corner brackets
    final bracketPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;

    final bracketSize = 12.0;
    
    // Top-left bracket
    canvas.drawLine(
      Offset(center.dx - 150, center.dy - 150),
      Offset(center.dx - 150 + bracketSize, center.dy - 150),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx - 150, center.dy - 150),
      Offset(center.dx - 150, center.dy - 150 + bracketSize),
      bracketPaint,
    );
    
    // Top-right bracket
    canvas.drawLine(
      Offset(center.dx + 150, center.dy - 150),
      Offset(center.dx + 150 - bracketSize, center.dy - 150),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 150, center.dy - 150),
      Offset(center.dx + 150, center.dy - 150 + bracketSize),
      bracketPaint,
    );
    
    // Bottom-left bracket
    canvas.drawLine(
      Offset(center.dx - 150, center.dy + 150),
      Offset(center.dx - 150 + bracketSize, center.dy + 150),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx - 150, center.dy + 150),
      Offset(center.dx - 150, center.dy + 150 - bracketSize),
      bracketPaint,
    );
    
    // Bottom-right bracket
    canvas.drawLine(
      Offset(center.dx + 150, center.dy + 150),
      Offset(center.dx + 150 - bracketSize, center.dy + 150),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 150, center.dy + 150),
      Offset(center.dx + 150, center.dy + 150 - bracketSize),
      bracketPaint,
    );

    // Top marker
    canvas.drawLine(
      Offset(center.dx - 5, center.dy - 165),
      Offset(center.dx + 5, center.dy - 165),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}