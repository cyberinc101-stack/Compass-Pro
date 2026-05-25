import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../services/settings_service.dart';

class ClassicCompass extends StatelessWidget {
  final double heading;

  const ClassicCompass({
    Key? key,
    required this.heading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final themeMode = settings.iconThemeMode;
    
    // Get theme-aware colors
    final outerBorderColor = _getOuterBorderColor(themeMode);
    final gradientColors = _getGradientColors(themeMode);
    final centerPinColor = _getCenterPinColor(themeMode);
    final centerPinBorderColor = _getCenterPinBorderColor(themeMode);
    
    return Container(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: outerBorderColor, width: 8),
              gradient: RadialGradient(
                colors: gradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Rotating compass face
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: Container(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _ClassicCompassPainter(settings: settings),
              ),
            ),
          ),
          // Center pin
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: centerPinColor,
              border: Border.all(color: centerPinBorderColor, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Color _getOuterBorderColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.brown.shade800;
      case 'glow':
        return const Color(0xFF00AA77);
      case 'night':
        return const Color(0xFFAA4444);
      default:
        return Colors.brown.shade800;
    }
  }

  List<Color> _getGradientColors(String themeMode) {
    switch (themeMode) {
      case 'day':
        return [
          Colors.brown.shade100,
          Colors.brown.shade300,
        ];
      case 'glow':
        return [
          const Color(0xFF00DDAA),
          const Color(0xFF009977),
        ];
      case 'night':
        return [
          const Color(0xFFDD6666),
          const Color(0xFF993333),
        ];
      default:
        return [
          Colors.brown.shade100,
          Colors.brown.shade300,
        ];
    }
  }

  Color _getCenterPinColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.brown.shade800;
      case 'glow':
        return const Color(0xFF00AA77);
      case 'night':
        return const Color(0xFFAA4444);
      default:
        return Colors.brown.shade800;
    }
  }

  Color _getCenterPinBorderColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.amber;
      case 'glow':
        return const Color(0xFF00FFCC);
      case 'night':
        return const Color(0xFFFF8888);
      default:
        return Colors.amber;
    }
  }
}

class _ClassicCompassPainter extends CustomPainter {
  final SettingsService settings;

  _ClassicCompassPainter({required this.settings});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final themeMode = settings.iconThemeMode;

    // Get theme-aware colors
    final markerColor = _getMarkerColor(themeMode);
    final northColor = _getNorthColor(themeMode);
    final southColor = _getSouthColor(themeMode);
    final southBorderColor = _getSouthBorderColor(themeMode);
    final cardinalColor = _getCardinalColor(themeMode);

    // Draw degree markers FIRST (so text appears on top)
    final paint = Paint()
      ..color = markerColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;

      final startRadius = radius * 0.88;
      final endRadius = isCardinal
          ? radius * 0.72
          : isMajor
              ? radius * 0.78
              : radius * 0.83;

      final x1 = center.dx + startRadius * math.sin(angle);
      final y1 = center.dy - startRadius * math.cos(angle);
      final x2 = center.dx + endRadius * math.sin(angle);
      final y2 = center.dy - endRadius * math.cos(angle);

      paint.strokeWidth = isCardinal ? 4 : isMajor ? 3 : 2;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw cardinal directions (on top of tick marks)
    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + radius * 0.60 * math.sin(angle);
      final y = center.dy - radius * 0.60 * math.cos(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: i == 0 ? northColor : cardinalColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
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

    // Draw compass needle
    final needlePaint = Paint()..style = PaintingStyle.fill;

    // North (red/themed)
    final northPath = Path();
    northPath.moveTo(center.dx, center.dy - radius * 0.5);
    northPath.lineTo(center.dx - 8, center.dy + 10);
    northPath.lineTo(center.dx + 8, center.dy + 10);
    northPath.close();
    needlePaint.color = northColor;
    canvas.drawPath(northPath, needlePaint);

    // South (white/themed)
    final southPath = Path();
    southPath.moveTo(center.dx, center.dy + radius * 0.5);
    southPath.lineTo(center.dx - 8, center.dy - 10);
    southPath.lineTo(center.dx + 8, center.dy - 10);
    southPath.close();
    needlePaint.color = southColor;
    canvas.drawPath(southPath, needlePaint);
    canvas.drawPath(
      southPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = southBorderColor
        ..strokeWidth = 2,
    );
  }

  Color _getMarkerColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.brown.shade800;
      case 'glow':
        return const Color(0xFF00AA77);
      case 'night':
        return const Color(0xFFAA4444);
      default:
        return Colors.brown.shade800;
    }
  }

  Color _getNorthColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.red.shade700;
      case 'glow':
        return const Color(0xFF00FFCC);
      case 'night':
        return const Color(0xFFFF6666);
      default:
        return Colors.red.shade700;
    }
  }

  Color _getSouthColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.white;
      case 'glow':
        return const Color(0xFF003322);
      case 'night':
        return const Color(0xFF220000);
      default:
        return Colors.white;
    }
  }

  Color _getSouthBorderColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.brown.shade800;
      case 'glow':
        return const Color(0xFF00AA77);
      case 'night':
        return const Color(0xFFAA4444);
      default:
        return Colors.brown.shade800;
    }
  }

  Color _getCardinalColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.brown.shade800;
      case 'glow':
        return const Color(0xFF00BB88);
      case 'night':
        return const Color(0xFFBB5555);
      default:
        return Colors.brown.shade800;
    }
  }

  @override
  bool shouldRepaint(covariant _ClassicCompassPainter oldDelegate) =>
      settings.iconThemeMode != oldDelegate.settings.iconThemeMode;
}