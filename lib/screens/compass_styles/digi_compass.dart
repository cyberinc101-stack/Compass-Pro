import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../services/settings_service.dart';

class DigiCompass extends StatelessWidget {
  final double heading;

  const DigiCompass({
    Key? key,
    required this.heading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    
    return Container(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: DigiCompassPainter(heading: heading, settings: settings),
      ),
    );
  }
}

class DigiCompassPainter extends CustomPainter {
  final double heading;
  final SettingsService settings;

  DigiCompassPainter({required this.heading, required this.settings});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.92;
    final themeMode = settings.iconThemeMode;

    // Get theme-aware colors
    final bgColors = _getBackgroundColors(themeMode);
    final primaryColor = _getPrimaryColor(themeMode);
    final accentColor = _getAccentColor(themeMode);
    final textColor = _getTextColor(themeMode);
    final northColor = _getNorthColor(themeMode);
    final needleColors = _getNeedleColors(themeMode);

    // Rotate canvas for the compass dial
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);
    canvas.translate(-center.dx, -center.dy);

    // Draw background with subtle gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: bgColors,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Draw outer circle with glow
    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius + 4, glowPaint);

    final outerCirclePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, outerCirclePaint);

    // Draw inner accent circle
    final accentCircle = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.95, accentCircle);

    // Draw grid pattern on outer ring
    final gridPaint = Paint()
      ..color = primaryColor.withOpacity(0.4)
      ..strokeWidth = 1;

    for (int i = 0; i < 360; i += 10) {
      final angle = (i - 90) * math.pi / 180;
      
      final start = Offset(
        center.dx + radius * 0.85 * math.cos(angle),
        center.dy + radius * 0.85 * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * 0.96 * math.cos(angle),
        center.dy + radius * 0.96 * math.sin(angle),
      );

      canvas.drawLine(start, end, gridPaint);
    }

    // Draw fine degree markings
    final markPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 2) {
      final angle = (i - 90) * math.pi / 180;
      final isMajor = i % 10 == 0;
      final isVeryMajor = i % 30 == 0;
      
      final startRadius = isVeryMajor ? radius * 0.70 : (isMajor ? radius * 0.76 : radius * 0.80);
      final endRadius = radius * 0.85;
      
      if (isVeryMajor) {
        markPaint.strokeWidth = 2.5;
        markPaint.color = accentColor;
      } else if (isMajor) {
        markPaint.strokeWidth = 1.5;
        markPaint.color = primaryColor;
      } else {
        markPaint.strokeWidth = 1;
        markPaint.color = primaryColor.withOpacity(0.6);
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
          color: accentColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
          letterSpacing: 0.5,
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + radius * 0.60 * math.cos(angle) - textPainter.width / 2,
        center.dy + radius * 0.60 * math.sin(angle) - textPainter.height / 2,
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
          color: (i == 0) ? northColor : textColor,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: accentColor.withOpacity(0.5),
              blurRadius: 8,
            ),
          ],
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + radius * 0.42 * math.cos(angle) - textPainter.width / 2,
        center.dy + radius * 0.42 * math.sin(angle) - textPainter.height / 2,
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
          color: textColor.withOpacity(0.8),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + radius * 0.42 * math.cos(angle) - textPainter.width / 2,
        center.dy + radius * 0.42 * math.sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }

    canvas.restore();

    // Draw dotted crosshair lines (fixed, not rotating)
    final crosshairPaint = Paint()
      ..color = primaryColor.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Horizontal dotted line
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = center.dx - radius * 0.25;
    final endX = center.dx + radius * 0.25;
    
    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, center.dy),
        Offset(startX + dashWidth, center.dy),
        crosshairPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // Vertical dotted line
    double startY = center.dy - radius * 0.25;
    final endY = center.dy + radius * 0.25;
    
    while (startY < endY) {
      canvas.drawLine(
        Offset(center.dx, startY),
        Offset(center.dx, startY + dashWidth),
        crosshairPaint,
      );
      startY += dashWidth + dashSpace;
    }

    // Draw fixed needle pointing north - Modern Angular Design
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Draw needle glow
    final glowPath = Path();
    glowPath.moveTo(0, -radius * 0.70);
    glowPath.lineTo(radius * 0.04, -radius * 0.65);
    glowPath.lineTo(radius * 0.06, -radius * 0.10);
    glowPath.lineTo(radius * 0.04, 0);
    glowPath.lineTo(radius * 0.03, radius * 0.08);
    glowPath.lineTo(-radius * 0.03, radius * 0.08);
    glowPath.lineTo(-radius * 0.04, 0);
    glowPath.lineTo(-radius * 0.06, -radius * 0.10);
    glowPath.lineTo(-radius * 0.04, -radius * 0.65);
    glowPath.close();

    final needleGlow = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(glowPath, needleGlow);

    // Draw needle shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(glowPath.shift(const Offset(2, 2)), shadowPaint);

    // Draw needle - modern angular design
    final needlePath = Path();
    needlePath.moveTo(0, -radius * 0.70);
    needlePath.lineTo(radius * 0.04, -radius * 0.65);
    needlePath.lineTo(radius * 0.06, -radius * 0.10);
    needlePath.lineTo(radius * 0.04, 0);
    needlePath.lineTo(radius * 0.03, radius * 0.08);
    needlePath.lineTo(-radius * 0.03, radius * 0.08);
    needlePath.lineTo(-radius * 0.04, 0);
    needlePath.lineTo(-radius * 0.06, -radius * 0.10);
    needlePath.lineTo(-radius * 0.04, -radius * 0.65);
    needlePath.close();

    final redPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: needleColors,
        stops: const [0.0, 0.48, 0.52, 1.0],
      ).createShader(Rect.fromLTRB(-radius * 0.06, -radius * 0.70, radius * 0.06, radius * 0.08));
    
    canvas.drawPath(needlePath, redPaint);

    // Add outline to needle top
    final needleOutline = Paint()
      ..color = accentColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final topNeedlePath = Path();
    topNeedlePath.moveTo(0, -radius * 0.70);
    topNeedlePath.lineTo(radius * 0.04, -radius * 0.65);
    topNeedlePath.lineTo(radius * 0.06, -radius * 0.10);
    topNeedlePath.lineTo(radius * 0.04, 0);
    topNeedlePath.lineTo(-radius * 0.04, 0);
    topNeedlePath.lineTo(-radius * 0.06, -radius * 0.10);
    topNeedlePath.lineTo(-radius * 0.04, -radius * 0.65);
    topNeedlePath.close();
    canvas.drawPath(topNeedlePath, needleOutline);

    // Add full vertical line detail through the entire needle
    final centerLinePaint = Paint()
      ..color = accentColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, -radius * 0.70),
      Offset(0, radius * 0.08),
      centerLinePaint,
    );

    // Draw center circle with accent
    final centerGradient = Paint()
      ..shader = RadialGradient(
        colors: [accentColor, primaryColor, _getDarkColor(themeMode)],
      ).createShader(Rect.fromCircle(center: const Offset(0, 0), radius: radius * 0.10));
    canvas.drawCircle(const Offset(0, 0), radius * 0.10, centerGradient);

    // Add glow to center
    final centerGlow = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(const Offset(0, 0), radius * 0.10, centerGlow);

    // Center highlight
    final centerHighlight = Paint()
      ..color = accentColor.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-radius * 0.03, -radius * 0.03), radius * 0.04, centerHighlight);

    // Center circle outline
    final centerOutline = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(const Offset(0, 0), radius * 0.10, centerOutline);

    canvas.restore();
  }

  List<Color> _getBackgroundColors(String themeMode) {
    switch (themeMode) {
      case 'day':
        return [const Color(0xFF1A0000), const Color(0xFF000000)];
      case 'glow':
        return [const Color(0xFF001A11), const Color(0xFF000000)];
      case 'night':
        return [const Color(0xFF1A0000), const Color(0xFF000000)];
      default:
        return [const Color(0xFF1A0000), const Color(0xFF000000)];
    }
  }

  Color _getPrimaryColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return const Color(0xFFD32F2F);
      case 'glow':
        return const Color(0xFF00CC88);
      case 'night':
        return const Color(0xFFFF4444);
      default:
        return const Color(0xFFD32F2F);
    }
  }

  Color _getAccentColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return const Color(0xFFFF5252);
      case 'glow':
        return const Color(0xFF00FFAA);
      case 'night':
        return const Color(0xFFFF6666);
      default:
        return const Color(0xFFFF5252);
    }
  }

  Color _getTextColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return const Color(0xFFD32F2F);
      case 'glow':
        return const Color(0xFF00BB88);
      case 'night':
        return const Color(0xFFFF5555);
      default:
        return const Color(0xFFD32F2F);
    }
  }

  Color _getNorthColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return const Color(0xFFFF5252);
      case 'glow':
        return const Color(0xFF00FFCC);
      case 'night':
        return const Color(0xFFFF8888);
      default:
        return const Color(0xFFFF5252);
    }
  }

  List<Color> _getNeedleColors(String themeMode) {
    switch (themeMode) {
      case 'day':
        return [
          const Color(0xFFFF5252),
          const Color(0xFFD32F2F),
          const Color(0xFF616161),
          const Color(0xFF424242),
        ];
      case 'glow':
        return [
          const Color(0xFF00FFAA),
          const Color(0xFF00CC88),
          const Color(0xFF006655),
          const Color(0xFF004433),
        ];
      case 'night':
        return [
          const Color(0xFFFF8888),
          const Color(0xFFFF5555),
          const Color(0xFF884444),
          const Color(0xFF662222),
        ];
      default:
        return [
          const Color(0xFFFF5252),
          const Color(0xFFD32F2F),
          const Color(0xFF616161),
          const Color(0xFF424242),
        ];
    }
  }

  Color _getDarkColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return const Color(0xFF424242);
      case 'glow':
        return const Color(0xFF003322);
      case 'night':
        return const Color(0xFF331111);
      default:
        return const Color(0xFF424242);
    }
  }

  @override
  bool shouldRepaint(DigiCompassPainter oldDelegate) {
    return oldDelegate.heading != heading ||
           oldDelegate.settings.iconThemeMode != settings.iconThemeMode;
  }
}