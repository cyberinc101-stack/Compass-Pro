import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../services/settings_service.dart';

class ThreeDCompass extends StatelessWidget {
  final double heading;

  const ThreeDCompass({
    Key? key,
    required this.heading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final themeMode = settings.iconThemeMode;
    
    // Get theme-aware colors
    final outerRingColors = _getOuterRingColors(themeMode);
    final middleRingColors = _getMiddleRingColors(themeMode);
    final centerSphereColors = _getCenterSphereColors(themeMode);
    final shadowColor = _getShadowColor(themeMode);
    
    return ClipOval(
      child: Container(
        width: 300,
        height: 300,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer 3D ring
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: outerRingColors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(5, 10),
                  ),
                  BoxShadow(
                    color: settings.getIconColor(opacity: 0.3),
                    blurRadius: 10,
                    offset: const Offset(-3, -5),
                  ),
                ],
              ),
            ),
            // Middle 3D ring
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: middleRingColors,
                ),
              ),
            ),
            // Rotating compass face with 3D effect
            ClipOval(
              child: Transform.rotate(
                angle: -heading * math.pi / 180,
                child: Container(
                  width: 260,
                  height: 260,
                  child: CustomPaint(
                    painter: _ThreeDCompassPainter(settings: settings),
                  ),
                ),
              ),
            ),
            // Center 3D sphere
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: centerSphereColors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(3, 5),
                  ),
                ],
              ),
            ),
            // Highlight on sphere
            Positioned(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      settings.getIconColor(opacity: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getOuterRingColors(String themeMode) {
    switch (themeMode) {
      case 'day':
        return [
          Colors.grey.shade400,
          Colors.grey.shade600,
          Colors.grey.shade800,
          Colors.grey.shade600,
          Colors.grey.shade400,
        ];
      case 'glow':
        return [
          const Color(0xFF00AA77),
          const Color(0xFF008866),
          const Color(0xFF006655),
          const Color(0xFF008866),
          const Color(0xFF00AA77),
        ];
      case 'night':
        return [
          const Color(0xFFAA4444),
          const Color(0xFF883333),
          const Color(0xFF662222),
          const Color(0xFF883333),
          const Color(0xFFAA4444),
        ];
      default:
        return [
          Colors.grey.shade400,
          Colors.grey.shade600,
          Colors.grey.shade800,
          Colors.grey.shade600,
          Colors.grey.shade400,
        ];
    }
  }

  List<Color> _getMiddleRingColors(String themeMode) {
    switch (themeMode) {
      case 'day':
        return [
          Colors.white,
          Colors.grey.shade200,
          Colors.grey.shade300,
        ];
      case 'glow':
        return [
          const Color(0xFF00DDAA),
          const Color(0xFF00BB88),
          const Color(0xFF009977),
        ];
      case 'night':
        return [
          const Color(0xFFDD6666),
          const Color(0xFFBB4444),
          const Color(0xFF993333),
        ];
      default:
        return [
          Colors.white,
          Colors.grey.shade200,
          Colors.grey.shade300,
        ];
    }
  }

  List<Color> _getCenterSphereColors(String themeMode) {
    switch (themeMode) {
      case 'day':
        return [
          Colors.blue.shade200,
          Colors.blue.shade600,
          Colors.blue.shade900,
        ];
      case 'glow':
        return [
          const Color(0xFF00FFCC),
          const Color(0xFF00CC99),
          const Color(0xFF009966),
        ];
      case 'night':
        return [
          const Color(0xFFFF8888),
          const Color(0xFFFF5555),
          const Color(0xFFCC3333),
        ];
      default:
        return [
          Colors.blue.shade200,
          Colors.blue.shade600,
          Colors.blue.shade900,
        ];
    }
  }

  Color _getShadowColor(String themeMode) {
    switch (themeMode) {
      case 'night':
        return Colors.black;
      case 'glow':
        return const Color(0xFF003322);
      default:
        return Colors.black;
    }
  }
}

class _ThreeDCompassPainter extends CustomPainter {
  final SettingsService settings;

  _ThreeDCompassPainter({required this.settings});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final themeMode = settings.iconThemeMode;

    // Clip to circle to prevent any leakage
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    // Get theme-aware colors
    final markerColors = _getMarkerColors(themeMode);
    final shadowColor = _getShadowColor(themeMode);
    final highlightColor = _getHighlightColor(themeMode);
    final backgroundColor = _getBackgroundColor(themeMode);

    // Draw background circle to fill any gaps
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = backgroundColor,
    );

    // Draw 3D raised markers
    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final isMajor = i % 30 == 0;
      final isCardinal = i % 90 == 0;

      final startRadius = radius * 0.88;
      final endRadius = isCardinal
          ? radius * 0.70
          : isMajor
              ? radius * 0.78
              : radius * 0.83;

      final x1 = center.dx + startRadius * math.sin(angle);
      final y1 = center.dy - startRadius * math.cos(angle);
      final x2 = center.dx + endRadius * math.sin(angle);
      final y2 = center.dy - endRadius * math.cos(angle);

      // Shadow
      canvas.drawLine(
        Offset(x1 + 1, y1 + 1),
        Offset(x2 + 1, y2 + 1),
        Paint()
          ..color = shadowColor
          ..strokeWidth = isCardinal ? 6 : isMajor ? 4 : 3
          ..strokeCap = StrokeCap.round,
      );

      // Main line with gradient effect
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: markerColors,
      );

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..shader = gradient.createShader(Rect.fromLTWH(x2, y2, x1 - x2, y1 - y2))
          ..strokeWidth = isCardinal ? 5 : isMajor ? 3 : 2
          ..strokeCap = StrokeCap.round,
      );

      // Highlight
      canvas.drawLine(
        Offset(x1 - 0.5, y1 - 0.5),
        Offset(x2 - 0.5, y2 - 0.5),
        Paint()
          ..color = highlightColor
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round,
      );
    }

    // Draw 3D cardinal directions
    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + radius * 0.52 * math.sin(angle);
      final y = center.dy - radius * 0.52 * math.cos(angle);

      // Shadow
      final shadowPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: shadowColor.withOpacity(0.5),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      shadowPainter.layout();
      shadowPainter.paint(
        canvas,
        Offset(x - shadowPainter.width / 2 + 2, y - shadowPainter.height / 2 + 2),
      );

      // Main text with theme-aware colors
      final textColors = _getDirectionColors(themeMode, i == 0);
      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            foreground: Paint()
              ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: textColors,
              ).createShader(Rect.fromLTWH(x, y, 32, 32)),
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

      // Highlight
      final highlightPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: highlightColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
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
  }

  Color _getBackgroundColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.grey.shade300;
      case 'glow':
        return const Color(0xFF009977);
      case 'night':
        return const Color(0xFF993333);
      default:
        return Colors.grey.shade300;
    }
  }

  List<Color> _getMarkerColors(String themeMode) {
    switch (themeMode) {
      case 'day':
        return [
          Colors.grey.shade700,
          Colors.grey.shade400,
          Colors.grey.shade600,
        ];
      case 'glow':
        return [
          const Color(0xFF00AA77),
          const Color(0xFF00FFAA),
          const Color(0xFF00CC88),
        ];
      case 'night':
        return [
          const Color(0xFFAA4444),
          const Color(0xFFFF6666),
          const Color(0xFFCC5555),
        ];
      default:
        return [
          Colors.grey.shade700,
          Colors.grey.shade400,
          Colors.grey.shade600,
        ];
    }
  }

  Color _getShadowColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.black26;
      case 'glow':
        return const Color(0xFF003322).withOpacity(0.5);
      case 'night':
        return Colors.black.withOpacity(0.7);
      default:
        return Colors.black26;
    }
  }

  Color _getHighlightColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return Colors.white.withOpacity(0.5);
      case 'glow':
        return const Color(0xFF00FFAA).withOpacity(0.3);
      case 'night':
        return const Color(0xFFFF8888).withOpacity(0.3);
      default:
        return Colors.white.withOpacity(0.5);
    }
  }

  List<Color> _getDirectionColors(String themeMode, bool isNorth) {
    switch (themeMode) {
      case 'day':
        return isNorth
            ? [Colors.red.shade300, Colors.red.shade700]
            : [Colors.blue.shade300, Colors.blue.shade700];
      case 'glow':
        return isNorth
            ? [const Color(0xFF00FFCC), const Color(0xFF00AA88)]
            : [const Color(0xFF00DDBB), const Color(0xFF009977)];
      case 'night':
        return isNorth
            ? [const Color(0xFFFF9999), const Color(0xFFFF4444)]
            : [const Color(0xFFFFAAAA), const Color(0xFFFF6666)];
      default:
        return isNorth
            ? [Colors.red.shade300, Colors.red.shade700]
            : [Colors.blue.shade300, Colors.blue.shade700];
    }
  }

  @override
  bool shouldRepaint(covariant _ThreeDCompassPainter oldDelegate) => 
      settings.iconThemeMode != oldDelegate.settings.iconThemeMode;
}