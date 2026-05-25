import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';

class HeadingCard extends StatelessWidget {
  final double heading;

  const HeadingCard({
    Key? key,
    required this.heading,
  }) : super(key: key);

  // Determine if it's day or night based on current time
  bool _isDay() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 20;
  }

  // Get heading text color based on icon theme mode
  Color _getHeadingColor(String iconThemeMode, bool isDay) {
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

  // Get cardinal direction text color based on icon theme mode
  Color _getCardinalColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00FFAA).withOpacity(0.9)
            : const Color(0xFF00FF88).withOpacity(0.9);
      case 'night':
        return isDay
            ? const Color(0xFFFF8888).withOpacity(0.9)
            : const Color(0xFFFF6666).withOpacity(0.9);
      default:
        return Colors.white.withOpacity(0.9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final localization = Provider.of<LocalizationService>(context);
    final iconThemeMode = settings.iconThemeMode ?? 'default';
    final isDay = _isDay();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              '${heading.toInt()}°',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: _getHeadingColor(iconThemeMode, isDay),
                letterSpacing: 2,
                shadows: iconThemeMode == 'glow'
                    ? [
                        Shadow(
                          color: _getHeadingColor(iconThemeMode, isDay).withOpacity(0.6),
                          blurRadius: 10,
                        ),
                      ]
                    : iconThemeMode == 'night'
                        ? [
                            Shadow(
                              color: _getHeadingColor(iconThemeMode, isDay).withOpacity(0.6),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getCardinalDirection(heading, localization),
              style: TextStyle(
                fontSize: 16,
                color: _getCardinalColor(iconThemeMode, isDay),
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                shadows: iconThemeMode == 'glow'
                    ? [
                        Shadow(
                          color: const Color(0xFF00FFAA).withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : iconThemeMode == 'night'
                        ? [
                            Shadow(
                              color: const Color(0xFFFF6666).withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getCardinalDirection(double heading, LocalizationService localization) {
    final directions = [
      localization.translate('n'), 
      localization.translate('nne'), 
      localization.translate('ne'), 
      localization.translate('ene'),
      localization.translate('e'), 
      localization.translate('ese'), 
      localization.translate('se'), 
      localization.translate('sse'),
      localization.translate('s'), 
      localization.translate('ssw'), 
      localization.translate('sw'), 
      localization.translate('wsw'),
      localization.translate('w'), 
      localization.translate('wnw'), 
      localization.translate('nw'), 
      localization.translate('nnw')
    ];
    
    int index = ((heading + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }
}