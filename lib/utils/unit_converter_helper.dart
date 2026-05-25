// Unit Conversion Helper for Compass Pro
// This helper should be used across all screens to ensure consistent unit conversion
// and language support across 20 different languages

class UnitConverter {
  // Distance Conversions
  static double convertDistance(double meters, String targetUnit) {
    switch (targetUnit) {
      case 'Meters':
        return meters;
      case 'Feet':
        return meters * 3.28084;
      case 'Kilometers':
        return meters / 1000;
      case 'Miles':
        return meters * 0.000621371;
      default:
        return meters;
    }
  }

  static String formatDistance(double meters, String unit) {
    final converted = convertDistance(meters, unit);
    switch (unit) {
      case 'Meters':
        return '${converted.toStringAsFixed(0)} m';
      case 'Feet':
        return '${converted.toStringAsFixed(0)} ft';
      case 'Kilometers':
        return '${converted.toStringAsFixed(2)} km';
      case 'Miles':
        return '${converted.toStringAsFixed(2)} mi';
      default:
        return '${converted.toStringAsFixed(0)} m';
    }
  }

  // Speed Conversions
  static double convertSpeed(double metersPerSecond, String targetUnit) {
    switch (targetUnit) {
      case 'm/s':
        return metersPerSecond;
      case 'km/h':
        return metersPerSecond * 3.6;
      case 'mph':
        return metersPerSecond * 2.23694;
      case 'knots':
        return metersPerSecond * 1.94384;
      default:
        return metersPerSecond;
    }
  }

  static String formatSpeed(double metersPerSecond, String unit) {
    final converted = convertSpeed(metersPerSecond, unit);
    return '${converted.toStringAsFixed(1)} $unit';
  }

  // Temperature Conversions
  static double convertTemperature(double celsius, String targetUnit) {
    switch (targetUnit) {
      case 'Celsius':
        return celsius;
      case 'Fahrenheit':
        return (celsius * 9 / 5) + 32;
      case 'Kelvin':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  static String formatTemperature(double celsius, String unit) {
    final converted = convertTemperature(celsius, unit);
    switch (unit) {
      case 'Celsius':
        return '${converted.toStringAsFixed(1)}°C';
      case 'Fahrenheit':
        return '${converted.toStringAsFixed(1)}°F';
      case 'Kelvin':
        return '${converted.toStringAsFixed(1)} K';
      default:
        return '${converted.toStringAsFixed(1)}°C';
    }
  }

  // Altitude/Elevation (same as distance)
  static String formatAltitude(double meters, String unit) {
    return formatDistance(meters, unit);
  }
}

// Usage Examples:
// 
// In any screen that displays distance:
// final settings = Provider.of<SettingsService>(context);
// final distanceText = UnitConverter.formatDistance(1500.0, settings.distanceUnit);
// // Returns: "1500 m" or "4921 ft" or "1.50 km" or "0.93 mi"
//
// In any screen that displays speed:
// final speedText = UnitConverter.formatSpeed(5.5, settings.speedUnit);
// // Returns: "5.5 m/s" or "19.8 km/h" or "12.3 mph" or "10.7 knots"
//
// In any screen that displays temperature:
// final tempText = UnitConverter.formatTemperature(22.0, settings.temperatureUnit);
// // Returns: "22.0°C" or "71.6°F" or "295.2 K"

/* 
SCREENS THAT NEED UNIT CONVERSION IMPLEMENTATION:

1. compass_screen.dart - Altitude in info cards
2. weather_screen.dart - Temperature, wind speed
3. location_screen.dart - Distance calculations
4. tracking_screen.dart - Distance, speed, altitude
5. saved_locations_screen.dart - Distance to saved locations
6. swipeable_info_cards.dart - Speed, altitude, distance, elevation
7. safety_tracking_screen.dart - Distance tracking

LANGUAGE SUPPORT NOTES:

For the 20 languages, unit labels should remain in their standard international format:
- Distance: m, ft, km, mi (universal)
- Speed: m/s, km/h, mph, knots (universal)
- Temperature: °C, °F, K (universal)

Only the UI text/labels need translation, not the unit abbreviations.
The unit conversion system is language-agnostic.

Example for Spanish language:
- "Distance" → "Distancia"
- "Speed" → "Velocidad"
- But "5.5 km/h" stays as "5.5 km/h" in all languages

SETTINGS SERVICE REQUIREMENTS:

The SettingsService needs to have these properties:
- String distanceUnit (default: 'Meters')
- String speedUnit (default: 'km/h')
- String temperatureUnit (default: 'Celsius')
- String language (default: 'en')

And these methods:
- void setDistanceUnit(String unit)
- void setSpeedUnit(String unit)
- void setTemperatureUnit(String unit)
- void setLanguage(String code)

All settings should persist using SharedPreferences.
*/