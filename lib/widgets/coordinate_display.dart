import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';

class CoordinateDisplay extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;

  const CoordinateDisplay({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
  }) : super(key: key);

  // Determine if it's day or night based on current time
  bool _isDay() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 20;
  }

  // Get background color based on icon theme mode
  Color _getBackgroundColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay 
            ? Colors.black.withOpacity(0.35)
            : const Color(0xFF001100).withOpacity(0.6);
      case 'night':
        return isDay
            ? const Color(0xFF330000).withOpacity(0.4)
            : const Color(0xFF220000).withOpacity(0.6);
      default:
        return Colors.black.withOpacity(0.3);
    }
  }

  // Get label text color based on icon theme mode
  Color _getLabelColor(String iconThemeMode, bool isDay) {
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

  // Get value text color based on icon theme mode
  Color _getValueColor(String iconThemeMode, bool isDay) {
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

  // Get border color based on icon theme mode
  Color? _getBorderColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00FFAA).withOpacity(0.3)
            : const Color(0xFF00FF88).withOpacity(0.3);
      case 'night':
        return isDay
            ? const Color(0xFFFF6666).withOpacity(0.3)
            : const Color(0xFFFF4444).withOpacity(0.3);
      default:
        return null; // No border for default mode
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final localization = Provider.of<LocalizationService>(context);
    final iconThemeMode = settings.iconThemeMode ?? 'default';
    final isDay = _isDay();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(iconThemeMode, isDay),
        borderRadius: BorderRadius.circular(12),
        border: _getBorderColor(iconThemeMode, isDay) != null
            ? Border.all(
                color: _getBorderColor(iconThemeMode, isDay)!,
                width: 1.5,
              )
            : null,
        boxShadow: iconThemeMode == 'glow'
            ? [
                BoxShadow(
                  color: const Color(0xFF00FFAA).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : iconThemeMode == 'night'
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF6666).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCoordinate(iconThemeMode, isDay, localization.translate('lat'), latitude),
              _buildCoordinate(iconThemeMode, isDay, localization.translate('lng'), longitude),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinate(String iconThemeMode, bool isDay, String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: _getLabelColor(iconThemeMode, isDay),
            fontSize: 12,
            fontWeight: iconThemeMode != 'default' ? FontWeight.w600 : FontWeight.normal,
            letterSpacing: iconThemeMode == 'glow' ? 1.2 : 0.5,
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
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(6),
          style: TextStyle(
            color: _getValueColor(iconThemeMode, isDay),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            shadows: iconThemeMode == 'glow'
                ? [
                    Shadow(
                      color: const Color(0xFF00FFCC).withOpacity(0.6),
                      blurRadius: 10,
                    ),
                  ]
                : iconThemeMode == 'night'
                    ? [
                        Shadow(
                          color: const Color(0xFFFF8888).withOpacity(0.6),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
          ),
        ),
      ],
    );
  }
}