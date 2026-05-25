import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';
import 'dart:math' as math;

class TransparentCompassOverlay extends StatelessWidget {
  final double heading;

  const TransparentCompassOverlay({Key? key, required this.heading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final localization = Provider.of<LocalizationService>(context);
    final iconThemeMode = settings.iconThemeMode ?? 'default';
    
    return CustomPaint(
      painter: TransparentCompassPainter(
        heading: heading,
        iconThemeMode: iconThemeMode,
        northLabel: localization.translate('n'),
      ),
    );
  }
}

class TransparentCompassPainter extends CustomPainter {
  final double heading;
  final String iconThemeMode;
  final String northLabel;

  TransparentCompassPainter({
    required this.heading,
    required this.iconThemeMode,
    required this.northLabel,
  });

  // Determine if it's day or night based on current time
  bool _isDay() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 20;
  }

  // Get background color based on icon theme mode
  Color _getBackgroundColor(bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay 
            ? Colors.black.withOpacity(0.3)
            : const Color(0xFF001100).withOpacity(0.5);
      case 'night':
        return isDay
            ? const Color(0xFF330000).withOpacity(0.3)
            : const Color(0xFF220000).withOpacity(0.5);
      default:
        return Colors.black.withOpacity(0.3);
    }
  }

  // Get ring color based on icon theme mode
  Color _getRingColor(bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00FFAA).withOpacity(0.7)
            : const Color(0xFF00FF88).withOpacity(0.7);
      case 'night':
        return isDay
            ? const Color(0xFFFF8888).withOpacity(0.7)
            : const Color(0xFFFF6666).withOpacity(0.7);
      default:
        return Colors.white.withOpacity(0.7);
    }
  }

  // Get cardinal mark color based on icon theme mode
  Color _getCardinalMarkColor(bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00FFCC)
            : const Color(0xFF00FFAA);
      case 'night':
        return isDay
            ? const Color(0xFFFFAAAA)
            : const Color(0xFFFF8888);
      default:
        return Colors.white;
    }
  }

  // Get north indicator color based on icon theme mode
  Color _getNorthColor(bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00FFFF)
            : const Color(0xFF00FFCC);
      case 'night':
        return isDay
            ? const Color(0xFFFF6666)
            : const Color(0xFFFF4444);
      default:
        return Colors.red;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;
    final isDay = _isDay();

    // Semi-transparent background
    final bgPaint = Paint()
      ..color = _getBackgroundColor(isDay)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Compass ring
    final ringPaint = Paint()
      ..color = _getRingColor(isDay)
      ..style = PaintingStyle.stroke
      ..strokeWidth = iconThemeMode != 'default' ? 3.5 : 3;
    canvas.drawCircle(center, radius - 10, ringPaint);

    // Add glow effect for ring if in glow or night mode
    if (iconThemeMode == 'glow' || iconThemeMode == 'night') {
      final glowPaint = Paint()
        ..color = _getRingColor(isDay).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, radius - 10, glowPaint);
    }

    // Cardinal marks
    for (int i = 0; i < 360; i += 45) {
      final angle = (i - heading) * math.pi / 180;
      final x1 = center.dx + (radius - 30) * math.cos(angle);
      final y1 = center.dy + (radius - 30) * math.sin(angle);
      final x2 = center.dx + (radius - 15) * math.cos(angle);
      final y2 = center.dy + (radius - 15) * math.sin(angle);

      final isNorth = i == 0;
      final markPaint = Paint()
        ..color = isNorth ? _getNorthColor(isDay) : _getCardinalMarkColor(isDay)
        ..strokeWidth = i % 90 == 0 ? 3 : 2;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), markPaint);

      // Add glow to marks in glow/night mode
      if (iconThemeMode == 'glow' || iconThemeMode == 'night') {
        final glowMarkPaint = Paint()
          ..color = (isNorth ? _getNorthColor(isDay) : _getCardinalMarkColor(isDay)).withOpacity(0.5)
          ..strokeWidth = i % 90 == 0 ? 6 : 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), glowMarkPaint);
      }
    }

    // North indicator
    final northAngle = -heading * math.pi / 180;
    final northX = center.dx + (radius - 40) * math.cos(northAngle);
    final northY = center.dy + (radius - 40) * math.sin(northAngle);

    final textPainter = TextPainter(
      text: TextSpan(
        text: northLabel,
        style: TextStyle(
          color: _getNorthColor(isDay),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: iconThemeMode == 'glow'
              ? [
                  Shadow(
                    color: _getNorthColor(isDay).withOpacity(0.6),
                    blurRadius: 10,
                  ),
                ]
              : iconThemeMode == 'night'
                  ? [
                      Shadow(
                        color: _getNorthColor(isDay).withOpacity(0.6),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(northX - textPainter.width / 2, northY - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(TransparentCompassPainter oldDelegate) =>
      heading != oldDelegate.heading || 
      iconThemeMode != oldDelegate.iconThemeMode ||
      northLabel != oldDelegate.northLabel;
}