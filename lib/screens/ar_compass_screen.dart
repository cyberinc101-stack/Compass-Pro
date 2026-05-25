import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/compass_service.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import 'dart:math' as math;

class ARCompassScreen extends StatefulWidget {
  const ARCompassScreen({Key? key}) : super(key: key);

  @override
  State<ARCompassScreen> createState() => _ARCompassScreenState();
}

class _ARCompassScreenState extends State<ARCompassScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // TODO: Add translation getter - replace with your actual translation service
  Map<String, String> get translations {
    // This is a placeholder - replace with your actual translation service
    // Example: TranslationService.getTranslations(currentLanguage)
    return {
      'ar_compass': 'AR COMPASS',
      'gps_label': 'GPS',
      'speed_label': 'Speed',
      'altitude_label': 'Altitude',
      'no_data': '--',
      'meters_abbr': 'm',
      'km_h': 'km/h',
      // Cardinal directions (already exist in the main translation file)
      'n': 'N',
      'nne': 'NNE',
      'ne': 'NE',
      'ene': 'ENE',
      'e': 'E',
      'ese': 'ESE',
      'se': 'SE',
      'sse': 'SSE',
      's': 'S',
      'ssw': 'SSW',
      'sw': 'SW',
      'wsw': 'WSW',
      'w': 'W',
      'wnw': 'WNW',
      'nw': 'NW',
      'nnw': 'NNW',
    };
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Get gradient colors based on theme mode
  List<Color> _getBackgroundGradient(String themeMode) {
    switch (themeMode) {
      case 'day':
        return [
          const Color(0xFF87CEEB), // Sky blue
          const Color(0xFF4A90E2), // Medium blue
          const Color(0xFF2E5C8A), // Deep blue
        ];
      case 'glow':
        return [
          const Color(0xFF1A237E), // Deep indigo
          const Color(0xFF311B92), // Purple
          const Color(0xFF4A148C), // Deep purple
        ];
      case 'night':
        return [
          Colors.black,
          const Color(0xFF1a1a2e),
          const Color(0xFF0f3460),
        ];
      default:
        return [
          Colors.black,
          const Color(0xFF1a1a2e),
          const Color(0xFF0f3460),
        ];
    }
  }

  // Get camera simulation gradient based on theme
  List<Color> _getCameraSimulationGradient(String themeMode) {
    switch (themeMode) {
      case 'day':
        return [
          const Color(0xFFB3D9F2), // Light blue
          const Color(0xFF87CEEB), // Sky blue
        ];
      case 'glow':
        return [
          const Color(0xFF311B92), // Purple
          const Color(0xFF1A237E), // Deep indigo
        ];
      case 'night':
        return [
          const Color(0xFF1a1a2e),
          const Color(0xFF0f0f1e),
        ];
      default:
        return [
          const Color(0xFF1a1a2e),
          const Color(0xFF0f0f1e),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final compassService = Provider.of<CompassService>(context);
    final locationService = Provider.of<LocationService>(context);
    final settings = Provider.of<SettingsService>(context);
    final themeMode = settings.iconThemeMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getBackgroundGradient(themeMode),
        ),
      ),
      child: Stack(
        children: [
          // Camera simulation background
          _buildCameraSimulation(settings, themeMode),

          // AR Compass overlay
          CustomPaint(
            size: Size.infinite,
            painter: ARCompassPainter(
              heading: compassService.currentHeading,
              animation: _animationController,
              iconColor: settings.getIconColor(opacity: 1.0),
            ),
          ),

          // Directional markers
          _buildDirectionalMarkers(compassService.currentHeading, settings),

          // Information overlay
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: _buildTopInfo(compassService, locationService, settings, themeMode),
          ),

          // Bottom information
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildBottomInfo(locationService, settings, themeMode),
          ),

          // Reticle center
          Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: settings.getIconColor(opacity: 1.0),
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSimulation(SettingsService settings, String themeMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: _getCameraSimulationGradient(themeMode),
        ),
      ),
      child: CustomPaint(
        size: Size.infinite,
        painter: GridPainter(
          gridColor: settings.getIconColor(opacity: 0.1),
        ),
      ),
    );
  }

  Widget _buildDirectionalMarkers(double heading, SettingsService settings) {
    return Stack(
      children: [
        _buildDirectionMarker(translations['n'] ?? 'N', 0, heading, Colors.red, settings),
        _buildDirectionMarker(translations['e'] ?? 'E', 90, heading, Colors.green, settings),
        _buildDirectionMarker(translations['s'] ?? 'S', 180, heading, Colors.blue, settings),
        _buildDirectionMarker(translations['w'] ?? 'W', 270, heading, Colors.orange, settings),
      ],
    );
  }

  Widget _buildDirectionMarker(
      String direction, double angle, double heading, Color color, SettingsService settings) {
    final screenWidth = MediaQuery.of(context).size.width;
    final relativeAngle = (angle - heading + 360) % 360;

    // Only show if within view (±60 degrees)
    if (relativeAngle > 60 && relativeAngle < 300) {
      return const SizedBox.shrink();
    }

    // Calculate horizontal position
    double xPosition = screenWidth / 2 +
        (relativeAngle > 180 ? relativeAngle - 360 : relativeAngle) *
            (screenWidth / 120);

    final textColor = settings.getTextColor(opacity: 1.0);
    final themeMode = settings.iconThemeMode;
    final overlayBackgroundColor = themeMode == 'night'
        ? Colors.black.withOpacity(0.7)
        : themeMode == 'glow'
            ? const Color(0xFF1A237E).withOpacity(0.7)
            : Colors.black.withOpacity(0.5);

    return Positioned(
      left: xPosition - 30,
      top: MediaQuery.of(context).size.height * 0.3,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_animationController.value * 0.1),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.3),
                    border: Border.all(color: color, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      direction,
                      style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: overlayBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${angle.toInt()}°',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopInfo(
      CompassService compassService, LocationService locationService, SettingsService settings, String themeMode) {
    final textColor = settings.getTextColor(opacity: 1.0);
    final textColorLight = settings.getTextColor(opacity: 0.7);
    final iconColor = settings.getIconColor(opacity: 1.0);
    final overlayBackgroundColor = themeMode == 'night'
        ? Colors.black.withOpacity(0.7)
        : themeMode == 'glow'
            ? const Color(0xFF1A237E).withOpacity(0.7)
            : Colors.black.withOpacity(0.5);
    
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: overlayBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: iconColor.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translations['ar_compass'] ?? 'AR COMPASS',
              style: TextStyle(
                color: iconColor,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${compassService.currentHeading.toInt()}°',
              style: TextStyle(
                color: textColor,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              _getCardinalDirection(compassService.currentHeading),
              style: TextStyle(
                color: textColorLight,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo(LocationService locationService, SettingsService settings, String themeMode) {
    final overlayBackgroundColor = themeMode == 'night'
        ? Colors.black.withOpacity(0.7)
        : themeMode == 'glow'
            ? const Color(0xFF1A237E).withOpacity(0.7)
            : Colors.black.withOpacity(0.5);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: overlayBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoChip(
            icon: Icons.gps_fixed,
            label: translations['gps_label'] ?? 'GPS',
            value: locationService.currentPosition != null
                ? '${locationService.currentPosition!.accuracy.toStringAsFixed(0)}${translations['meters_abbr'] ?? 'm'}'
                : translations['no_data'] ?? '--',
            settings: settings,
          ),
          _buildInfoChip(
            icon: Icons.speed,
            label: translations['speed_label'] ?? 'Speed',
            value: locationService.currentPosition != null
                ? '${(locationService.currentPosition!.speed * 3.6).toStringAsFixed(1)} ${translations['km_h'] ?? 'km/h'}'
                : translations['no_data'] ?? '--',
            settings: settings,
          ),
          _buildInfoChip(
            icon: Icons.terrain,
            label: translations['altitude_label'] ?? 'Altitude',
            value: locationService.currentPosition != null
                ? '${locationService.currentPosition!.altitude.toStringAsFixed(0)}${translations['meters_abbr'] ?? 'm'}'
                : translations['no_data'] ?? '--',
            settings: settings,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required SettingsService settings,
  }) {
    final iconColor = settings.getIconColor(opacity: 1.0);
    final textColor = settings.getTextColor(opacity: 1.0);
    final textColorLight = settings.getTextColor(opacity: 0.7);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: textColorLight, fontSize: 10),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getCardinalDirection(double heading) {
    final directions = [
      translations['n'] ?? 'N',
      translations['nne'] ?? 'NNE',
      translations['ne'] ?? 'NE',
      translations['ene'] ?? 'ENE',
      translations['e'] ?? 'E',
      translations['ese'] ?? 'ESE',
      translations['se'] ?? 'SE',
      translations['sse'] ?? 'SSE',
      translations['s'] ?? 'S',
      translations['ssw'] ?? 'SSW',
      translations['sw'] ?? 'SW',
      translations['wsw'] ?? 'WSW',
      translations['w'] ?? 'W',
      translations['wnw'] ?? 'WNW',
      translations['nw'] ?? 'NW',
      translations['nnw'] ?? 'NNW',
    ];

    int index = ((heading + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }
}

class ARCompassPainter extends CustomPainter {
  final double heading;
  final Animation<double> animation;
  final Color iconColor;

  ARCompassPainter({
    required this.heading,
    required this.animation,
    required this.iconColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = iconColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw horizon line
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint..color = iconColor.withOpacity(0.3),
    );

    // Draw degree markers
    for (int i = 0; i < 360; i += 10) {
      final angle = (i - heading) * math.pi / 180;
      final x = center.dx + math.cos(angle) * size.width * 0.4;
      final y = center.dy + math.sin(angle) * size.width * 0.4;

      if ((i - heading).abs() % 360 < 90 || (i - heading).abs() % 360 > 270) {
        canvas.drawCircle(
          Offset(x, y),
          3,
          Paint()..color = iconColor.withOpacity(0.5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(ARCompassPainter oldDelegate) =>
      heading != oldDelegate.heading || iconColor != oldDelegate.iconColor;
}

class GridPainter extends CustomPainter {
  final Color gridColor;

  GridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // Draw grid
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => gridColor != oldDelegate.gridColor;
}