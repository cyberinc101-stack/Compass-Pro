import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../services/settings_service.dart';

class NavCompass extends StatelessWidget {
  final double heading;

  const NavCompass({
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
        painter: NavCompassPainter(heading: heading, settings: settings),
      ),
    );
  }
}

class NavCompassPainter extends CustomPainter {
  final double heading;
  final SettingsService settings;

  NavCompassPainter({required this.heading, required this.settings});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.92;
    final themeMode = settings.iconThemeMode;

    // Get theme-aware colors
    final bgColors = _getBackgroundColors(themeMode);
    final outerCircleColor = _getOuterCircleColor(themeMode);
    final innerRingColor = _getInnerRingColor(themeMode);
    final markColor = _getMarkColor(themeMode);
    final textColor = _getTextColor(themeMode);
    final northColor = _getNorthColor(themeMode);
    final crosshairColor = _getCrosshairColor(themeMode);
    final needleColors = _getNeedleColors(themeMode);
    final needleOutlineColor = _getNeedleOutlineColor(themeMode);

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

    // Draw outer circle
    final outerCirclePaint = Paint()
      ..color = outerCircleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, outerCirclePaint);

    // Draw inner detail ring
    final innerRingPaint = Paint()
      ..color = innerRingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.96, innerRingPaint);

    // Draw fine degree markings
    final markPaint = Paint()
      ..color = markColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 2) {
      final angle = (i - 90) * math.pi / 180;
      final isMajor = i % 10 == 0;
      
      final startRadius = isMajor ? radius * 0.86 : radius * 0.90;
      final endRadius = radius * 0.96;
      
      markPaint.strokeWidth = isMajor ? 2 : 1;
      
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
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + radius * 0.75 * math.cos(angle) - textPainter.width / 2,
        center.dy + radius * 0.75 * math.sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }

    // Draw cardinal and intercardinal directions
    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45 - 90) * math.pi / 180;
      final isCardinal = i % 2 == 0;
      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: (i == 0) ? northColor : markColor,
          fontSize: isCardinal ? 22 : 16,
          fontWeight: FontWeight.bold,
          letterSpacing: isCardinal ? 1.5 : 1,
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + radius * 0.58 * math.cos(angle) - textPainter.width / 2,
        center.dy + radius * 0.58 * math.sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }

    canvas.restore();

    // Draw fixed crosshair lines (not rotating)
    final crosshairPaint = Paint()
      ..color = crosshairColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Vertical dashed line
    const dashWidth = 10.0;
    const dashSpace = 10.0;
    double startY = center.dy - radius;
    while (startY < center.dy + radius) {
      canvas.drawLine(
        Offset(center.dx, startY),
        Offset(center.dx, math.min(startY + dashWidth, center.dy + radius)),
        crosshairPaint,
      );
      startY += dashWidth + dashSpace;
    }

    // Horizontal dashed line
    double startX = center.dx - radius;
    while (startX < center.dx + radius) {
      canvas.drawLine(
        Offset(startX, center.dy),
        Offset(math.min(startX + dashWidth, center.dx + radius), center.dy),
        crosshairPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // Draw crosshair center circle
    final crosshairCenter = Paint()
      ..color = crosshairColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.12, crosshairCenter);

    // Draw fixed needle pointing north
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Draw needle shadow
    final shadowPath = Path();
    shadowPath.moveTo(0, -radius * 0.45);
    shadowPath.lineTo(radius * 0.10, -radius * 0.22);
    shadowPath.lineTo(0, -radius * 0.28);
    shadowPath.lineTo(-radius * 0.10, -radius * 0.22);
    shadowPath.close();

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(shadowPath.shift(const Offset(1, 1)), shadowPaint);

    // Draw arrow needle pointing north
    final needlePath = Path();
    needlePath.moveTo(0, -radius * 0.45);
    needlePath.lineTo(radius * 0.10, -radius * 0.22);
    needlePath.lineTo(0, -radius * 0.28);
    needlePath.lineTo(-radius * 0.10, -radius * 0.22);
    needlePath.close();

    final needlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: needleColors,
      ).createShader(Rect.fromLTRB(-radius * 0.10, -radius * 0.45, radius * 0.10, -radius * 0.22));
    canvas.drawPath(needlePath, needlePaint);

    // Add outline to arrow
    final arrowOutline = Paint()
      ..color = needleOutlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(needlePath, arrowOutline);

    canvas.restore();
  }

  List<Color> _getBackgroundColors(String themeMode) {
    switch (themeMode) {
      case 'day':
        return [const Color(0xFF2A2A2A), const Color(0xFF121212)];
      case 'glow':
        return [const Color(0xFF002A1A), const Color(0xFF001512)];
      case 'night':
        return [const Color(0xFF2A0A0A), const Color(0xFF150000)];
      default:
        return [const Color(0xFF2A2A2A), const Color(0xFF121212)];
    }
  }

  Color _getOuterCircleColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.white;
      case 'glow':
        return const Color(0xFF00FFAA);
      case 'night':
        return const Color(0xFFFF6666);
      default:
        return Colors.white;
    }
  }

  Color _getInnerRingColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.white.withOpacity(0.3);
      case 'glow':
        return const Color(0xFF00FFAA).withOpacity(0.3);
      case 'night':
        return const Color(0xFFFF6666).withOpacity(0.3);
      default:
        return Colors.white.withOpacity(0.3);
    }
  }

  Color _getMarkColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.white;
      case 'glow':
        return const Color(0xFF00DDAA);
      case 'night':
        return const Color(0xFFFF5555);
      default:
        return Colors.white;
    }
  }

  Color _getTextColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return const Color(0xFFE0E0E0);
      case 'glow':
        return const Color(0xFF88FFDD);
      case 'night':
        return const Color(0xFFFFAAAA);
      default:
        return const Color(0xFFE0E0E0);
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

  Color _getCrosshairColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.white.withOpacity(0.5);
      case 'glow':
        return const Color(0xFF00FFAA).withOpacity(0.5);
      case 'night':
        return const Color(0xFFFF6666).withOpacity(0.5);
      default:
        return Colors.white.withOpacity(0.5);
    }
  }

  List<Color> _getNeedleColors(String themeMode) {
    switch (themeMode) {
      case 'day':
        return [const Color(0xFFFF5252), const Color(0xFFE53935)];
      case 'glow':
        return [const Color(0xFF00FFCC), const Color(0xFF00CC99)];
      case 'night':
        return [const Color(0xFFFF8888), const Color(0xFFFF5555)];
      default:
        return [const Color(0xFFFF5252), const Color(0xFFE53935)];
    }
  }

  Color _getNeedleOutlineColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.white;
      case 'glow':
        return const Color(0xFF00FFEE);
      case 'night':
        return const Color(0xFFFFAAAA);
      default:
        return Colors.white;
    }
  }

  @override
  bool shouldRepaint(NavCompassPainter oldDelegate) {
    return oldDelegate.heading != heading ||
           oldDelegate.settings.iconThemeMode != settings.iconThemeMode;
  }
}