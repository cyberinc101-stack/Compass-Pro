import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../services/settings_service.dart';

class DigitalCompass extends StatelessWidget {
  final double heading;

  const DigitalCompass({
    Key? key,
    required this.heading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    
    return Container(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arrow pointing north (rotates to always point north)
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _DigitalArrowPainter(settings: settings),
            ),
          ),
        ],
      ),
    );
  }
}

class _DigitalArrowPainter extends CustomPainter {
  final SettingsService settings;

  _DigitalArrowPainter({required this.settings});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final themeMode = settings.iconThemeMode;

    // Get theme-aware colors
    final glowColor = _getGlowColor(themeMode);
    final gradientColors = _getGradientColors(themeMode);
    final outlineColor = _getOutlineColor(themeMode);
    final highlightColor = _getHighlightColor(themeMode);
    final centerCircleOuter = _getCenterCircleOuterColor(themeMode);
    final centerCircleInner = _getCenterCircleInnerColor(themeMode);
    final centerDot = _getCenterDotColor(themeMode);

    // Create sleek modern arrow path
    final arrowPath = Path();
    arrowPath.moveTo(center.dx, center.dy - 80); // Sharp top point
    arrowPath.lineTo(center.dx - 28, center.dy - 20); // Left wing outer
    arrowPath.lineTo(center.dx - 12, center.dy - 20); // Left wing inner
    arrowPath.lineTo(center.dx - 12, center.dy + 80); // Left shaft
    arrowPath.lineTo(center.dx + 12, center.dy + 80); // Right shaft
    arrowPath.lineTo(center.dx + 12, center.dy - 20); // Right wing inner
    arrowPath.lineTo(center.dx + 28, center.dy - 20); // Right wing outer
    arrowPath.close();

    // Outer glow effect
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = glowColor.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Shadow for depth
    canvas.drawPath(
      arrowPath.shift(const Offset(4, 4)),
      Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Main arrow with sleek gradient
    final rect = Rect.fromLTWH(
      center.dx - 30,
      center.dy - 85,
      60,
      170,
    );
    
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: gradientColors,
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    canvas.drawPath(
      arrowPath,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill,
    );

    // Left edge highlight for 3D effect
    final highlightPath = Path();
    highlightPath.moveTo(center.dx, center.dy - 80);
    highlightPath.lineTo(center.dx - 28, center.dy - 20);
    highlightPath.lineTo(center.dx - 12, center.dy - 20);
    highlightPath.lineTo(center.dx - 12, center.dy + 80);
    
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = highlightColor.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Crisp outline
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    // Inner accent line
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = outlineColor.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Polished center circle
    canvas.drawCircle(
      Offset(center.dx, center.dy + 25),
      6,
      Paint()
        ..color = centerCircleOuter
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      Offset(center.dx, center.dy + 25),
      4,
      Paint()
        ..color = centerCircleInner
        ..style = PaintingStyle.fill,
    );

    // Center dot
    canvas.drawCircle(
      Offset(center.dx, center.dy + 25),
      1.5,
      Paint()
        ..color = centerDot
        ..style = PaintingStyle.fill,
    );
  }

  Color _getGlowColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.red;
      case 'glow':
        return const Color(0xFF00FFAA);
      case 'night':
        return const Color(0xFFFF5555);
      default:
        return Colors.red;
    }
  }

  List<Color> _getGradientColors(String themeMode) {
    switch (themeMode) {
      case 'day':
        return [
          Colors.red[200]!,
          Colors.red[400]!,
          Colors.red[700]!,
          Colors.red[900]!,
        ];
      case 'glow':
        return [
          const Color(0xFF88FFDD),
          const Color(0xFF55DDAA),
          const Color(0xFF33BB88),
          const Color(0xFF009966),
        ];
      case 'night':
        return [
          const Color(0xFFFFAAAA),
          const Color(0xFFFF8888),
          const Color(0xFFFF5555),
          const Color(0xFFCC3333),
        ];
      default:
        return [
          Colors.red[200]!,
          Colors.red[400]!,
          Colors.red[700]!,
          Colors.red[900]!,
        ];
    }
  }

  Color _getOutlineColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.white;
      case 'glow':
        return const Color(0xFF00FFCC);
      case 'night':
        return const Color(0xFFFF8888);
      default:
        return Colors.white;
    }
  }

  Color _getHighlightColor(String themeMode) {
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

  Color _getCenterCircleOuterColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.white;
      case 'glow':
        return const Color(0xFF00FFCC);
      case 'night':
        return const Color(0xFFFF8888);
      default:
        return Colors.white;
    }
  }

  Color _getCenterCircleInnerColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.red[900]!;
      case 'glow':
        return const Color(0xFF006655);
      case 'night':
        return const Color(0xFF882222);
      default:
        return Colors.red[900]!;
    }
  }

  Color _getCenterDotColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.white;
      case 'glow':
        return const Color(0xFF00FFCC);
      case 'night':
        return const Color(0xFFFFAAAA);
      default:
        return Colors.white;
    }
  }

  @override
  bool shouldRepaint(covariant _DigitalArrowPainter oldDelegate) =>
      settings.iconThemeMode != oldDelegate.settings.iconThemeMode;
}