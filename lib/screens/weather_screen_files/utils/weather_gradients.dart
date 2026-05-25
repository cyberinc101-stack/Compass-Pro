import 'package:flutter/material.dart';

class WeatherGradients {
  // Get dynamic gradient colors based on weather and theme mode
  static List<Color> getWeatherGradient(int? weatherCode, bool isDay, String iconThemeMode) {
    if (weatherCode == null) {
      return _getDefaultGradient(iconThemeMode);
    }

    // Clear sky
    if (weatherCode == 0) {
      return isDay 
        ? _getDayGradient(iconThemeMode)
        : _getNightGradient(iconThemeMode);
    }
    
    // Partly cloudy
    if (weatherCode <= 3) {
      return _getCloudyGradient(iconThemeMode, isDay);
    }
    
    // Fog
    if (weatherCode <= 48) {
      return _getFogGradient(iconThemeMode);
    }
    
    // Rain
    if (weatherCode <= 67 || (weatherCode >= 80 && weatherCode <= 82)) {
      return _getRainGradient(iconThemeMode);
    }
    
    // Snow
    if (weatherCode <= 77 || (weatherCode >= 85 && weatherCode <= 86)) {
      return _getSnowGradient(iconThemeMode);
    }
    
    // Thunderstorm
    if (weatherCode >= 95) {
      return _getThunderstormGradient(iconThemeMode);
    }

    return _getDefaultGradient(iconThemeMode);
  }

  static List<Color> _getDefaultGradient(String iconThemeMode) {
    switch (iconThemeMode) {
      case 'glow':
        return [const Color(0xFF003322), const Color(0xFF005544)];
      case 'night':
        return [const Color(0xFF330000), const Color(0xFF550000)];
      default:
        return [const Color(0xFF4A90E2), const Color(0xFF357ABD)];
    }
  }

  static List<Color> _getDayGradient(String iconThemeMode) {
    switch (iconThemeMode) {
      case 'glow':
        return [
          const Color(0xFF004433),
          const Color(0xFF006655),
          const Color(0xFF008877),
        ];
      case 'night':
        return [
          const Color(0xFF440000),
          const Color(0xFF660000),
          const Color(0xFF880000),
        ];
      default:
        return [
          const Color(0xFF56CCF2),
          const Color(0xFF2F80ED),
          const Color(0xFF1B4F72),
        ];
    }
  }

  static List<Color> _getNightGradient(String iconThemeMode) {
    switch (iconThemeMode) {
      case 'glow':
        return [
          const Color(0xFF001100),
          const Color(0xFF002211),
          const Color(0xFF003322),
        ];
      case 'night':
        return [
          const Color(0xFF220000),
          const Color(0xFF330000),
          const Color(0xFF440000),
        ];
      default:
        return [
          const Color(0xFF0F2027),
          const Color(0xFF203A43),
          const Color(0xFF2C5364),
        ];
    }
  }

  static List<Color> _getCloudyGradient(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return [
          const Color(0xFF003344),
          const Color(0xFF005566),
          const Color(0xFF007788),
        ];
      case 'night':
        return [
          const Color(0xFF440011),
          const Color(0xFF660022),
          const Color(0xFF880033),
        ];
      default:
        return isDay
            ? [
                const Color(0xFF89C9E8),
                const Color(0xFF5AA8D3),
                const Color(0xFF3A7CA5),
              ]
            : [
                const Color(0xFF2C3E50),
                const Color(0xFF3498DB),
                const Color(0xFF2980B9),
              ];
    }
  }

  static List<Color> _getFogGradient(String iconThemeMode) {
    switch (iconThemeMode) {
      case 'glow':
        return [
          const Color(0xFF224433),
          const Color(0xFF446655),
          const Color(0xFF668877),
        ];
      case 'night':
        return [
          const Color(0xFF442222),
          const Color(0xFF664444),
          const Color(0xFF886666),
        ];
      default:
        return [
          const Color(0xFF757F9A),
          const Color(0xFFD7DDE8),
          const Color(0xFFA8B5C7),
        ];
    }
  }

  static List<Color> _getRainGradient(String iconThemeMode) {
    switch (iconThemeMode) {
      case 'glow':
        return [
          const Color(0xFF002244),
          const Color(0xFF003355),
          const Color(0xFF004466),
        ];
      case 'night':
        return [
          const Color(0xFF331111),
          const Color(0xFF441111),
          const Color(0xFF552222),
        ];
      default:
        return [
          const Color(0xFF536976),
          const Color(0xFF292E49),
          const Color(0xFF1C1F33),
        ];
    }
  }

  static List<Color> _getSnowGradient(String iconThemeMode) {
    switch (iconThemeMode) {
      case 'glow':
        return [
          const Color(0xFF225566),
          const Color(0xFF448899),
          const Color(0xFF66AACC),
        ];
      case 'night':
        return [
          const Color(0xFF553344),
          const Color(0xFF775566),
          const Color(0xFF997788),
        ];
      default:
        return [
          const Color(0xFFE0F7FA),
          const Color(0xFF80DEEA),
          const Color(0xFF4DD0E1),
        ];
    }
  }

  static List<Color> _getThunderstormGradient(String iconThemeMode) {
    switch (iconThemeMode) {
      case 'glow':
        return [
          const Color(0xFF001133),
          const Color(0xFF002244),
          const Color(0xFF003355),
        ];
      case 'night':
        return [
          const Color(0xFF220000),
          const Color(0xFF330000),
          const Color(0xFF440000),
        ];
      default:
        return [
          const Color(0xFF2C3E50),
          const Color(0xFF34495E),
          const Color(0xFF1A252F),
        ];
    }
  }

  // Get weather icon - unchanged
  static IconData getWeatherIcon(int weatherCode, bool isDay) {
    if (weatherCode == 0) {
      return isDay ? Icons.wb_sunny : Icons.nightlight_round;
    } else if (weatherCode <= 3) {
      return Icons.cloud_queue;
    } else if (weatherCode <= 48) {
      return Icons.foggy;
    } else if (weatherCode <= 67 || (weatherCode >= 80 && weatherCode <= 82)) {
      return Icons.water_drop;
    } else if (weatherCode <= 77 || (weatherCode >= 85 && weatherCode <= 86)) {
      return Icons.ac_unit;
    } else if (weatherCode >= 95) {
      return Icons.flash_on;
    }
    return Icons.wb_cloudy;
  }

  // Get weather icon color - now theme-aware
  static Color getWeatherIconColor(int weatherCode, bool isDay, String iconThemeMode) {
    // Base colors for different weather types
    if (iconThemeMode == 'glow') {
      if (weatherCode == 0) return const Color(0xFF00FFCC);
      if (weatherCode <= 3) return const Color(0xFF00FF88);
      if (weatherCode <= 48) return const Color(0xFF88FF88);
      if (weatherCode <= 67 || (weatherCode >= 80 && weatherCode <= 82)) {
        return const Color(0xFF00DDFF);
      }
      if (weatherCode <= 77 || (weatherCode >= 85 && weatherCode <= 86)) {
        return const Color(0xFF88FFFF);
      }
      if (weatherCode >= 95) return const Color(0xFFFFFF00);
      return const Color(0xFF00FF88);
    } else if (iconThemeMode == 'night') {
      if (weatherCode == 0) return const Color(0xFFFF6666);
      if (weatherCode <= 3) return const Color(0xFFFF3333);
      if (weatherCode <= 48) return const Color(0xFFFF8888);
      if (weatherCode <= 67 || (weatherCode >= 80 && weatherCode <= 82)) {
        return const Color(0xFFFF4444);
      }
      if (weatherCode <= 77 || (weatherCode >= 85 && weatherCode <= 86)) {
        return const Color(0xFFFFAAAA);
      }
      if (weatherCode >= 95) return const Color(0xFFFFFF88);
      return const Color(0xFFFF3333);
    } else {
      // Day mode - natural colors
      if (weatherCode == 0) {
        return isDay ? Colors.amber : Colors.blue[100]!;
      } else if (weatherCode <= 3) {
        return Colors.white;
      } else if (weatherCode <= 48) {
        return Colors.grey[300]!;
      } else if (weatherCode <= 67 || (weatherCode >= 80 && weatherCode <= 82)) {
        return Colors.lightBlue[200]!;
      } else if (weatherCode <= 77 || (weatherCode >= 85 && weatherCode <= 86)) {
        return Colors.lightBlue[50]!;
      } else if (weatherCode >= 95) {
        return Colors.amber;
      }
      return Colors.white;
    }
  }
}