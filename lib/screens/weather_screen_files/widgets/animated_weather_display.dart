import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../services/weather_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/localization_service.dart';
import '../../../utils/unit_converter_helper.dart';
import '../utils/weather_particles.dart';

class AnimatedWeatherDisplay extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final int? weatherCode;
  final bool isDay;
  final WeatherService weatherService;
  final AnimationController floatController;
  final AnimationController pulseController;
  final String temperatureUnit;

  const AnimatedWeatherDisplay({
    Key? key,
    required this.weatherData,
    required this.weatherCode,
    required this.isDay,
    required this.weatherService,
    required this.floatController,
    required this.pulseController,
    required this.temperatureUnit,
  }) : super(key: key);

  // FIXED: Use LocalizationService for translation
  String translate(String key) {
    return LocalizationService.translate(key);
  }

  // FIXED: Map WMO weather codes to EXISTING translation keys
  String _getTranslatedWeatherCondition(int weatherCode) {
    String translationKey;
    
    if (weatherCode == 0) {
      translationKey = 'clear';  // Uses existing key
    } else if (weatherCode >= 1 && weatherCode <= 3) {
      translationKey = 'partly_cloudy';  // Uses existing key
    } else if (weatherCode >= 45 && weatherCode <= 48) {
      translationKey = 'foggy';  // Uses existing key
    } else if (weatherCode >= 51 && weatherCode <= 67) {
      translationKey = 'rainy';  // Uses existing key (covers both drizzle and rain)
    } else if (weatherCode >= 71 && weatherCode <= 77) {
      translationKey = 'snowy';  // Uses existing key
    } else if (weatherCode >= 80 && weatherCode <= 82) {
      translationKey = 'showers';  // Uses existing key (rain showers)
    } else if (weatherCode >= 85 && weatherCode <= 86) {
      translationKey = 'snowy';  // Uses existing key (snow showers = snowy)
    } else if (weatherCode >= 95 && weatherCode <= 99) {
      translationKey = 'storm';  // Uses existing key
    } else {
      translationKey = 'unknown';  // Uses existing key
    }
    
    return translate(translationKey);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final tempCelsius = (weatherData['current']['temperature_2m'] as num?)?.toDouble() ?? 0.0;
    final feelsLikeCelsius = (weatherData['current']['apparent_temperature'] as num?)?.toDouble() ?? 0.0;
    
    // FIXED: Use translated weather condition instead of English-only
    final condition = _getTranslatedWeatherCondition(weatherCode ?? 0);
    
    // Convert temperatures to selected unit
    final temp = UnitConverter.convertTemperature(tempCelsius, temperatureUnit);
    final feelsLike = UnitConverter.convertTemperature(feelsLikeCelsius, temperatureUnit);
    
    // Get temperature symbol
    String tempSymbol = temperatureUnit == 'Kelvin' ? ' K' : '°';
    
    return Stack(
      children: [
        // Animated particles background
        Positioned.fill(
          child: WeatherParticles(weatherCode: weatherCode ?? 0, isDay: isDay),
        ),
        
        // Main animated weather content - CENTERED
        Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([floatController, pulseController]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, math.sin(floatController.value * 2 * math.pi) * 3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 3D Animated Weather Icon (NO ROTATION)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow effect - adapts to theme mode
                        Transform.scale(
                          scale: 1 + (pulseController.value * 0.1),
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  settings.getIconColor(opacity: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Main weather icon - NO ROTATION
                        _build3DWeatherIcon(weatherCode ?? 0, isDay, settings),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Temperature with shadow effect
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Shadow
                        Transform.translate(
                          offset: const Offset(0, 4),
                          child: Text(
                            '${temp.round()}$tempSymbol',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.w200,
                              color: Colors.black.withOpacity(0.2),
                              letterSpacing: -5,
                            ),
                          ),
                        ),
                        // Main text with theme color
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              settings.getTextColor(),
                              settings.getTextColor(opacity: 0.9),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            '${temp.round()}$tempSymbol',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.w200,
                              color: settings.getTextColor(),
                              letterSpacing: -5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Weather condition with emoji
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: settings.getIconColor(opacity: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: settings.getIconColor(opacity: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            weatherService.getWeatherEmoji(weatherCode ?? 0),
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            condition,
                            style: TextStyle(
                              color: settings.getTextColor(),
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // FIXED: Feels like now translates to all languages
                    Text(
                      '${translate('feels_like')} ${feelsLike.round()}$tempSymbol',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: settings.getTextColor(opacity: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _build3DWeatherIcon(int weatherCode, bool isDay, SettingsService settings) {
    IconData icon;
    Color iconColor = settings.getIconColor();
    
    // Determine icon based on weather code
    if (weatherCode == 0) {
      icon = isDay ? Icons.wb_sunny : Icons.nightlight_round;
      iconColor = _getWeatherSpecificColor(weatherCode, isDay, settings);
    } else if (weatherCode <= 3) {
      icon = Icons.cloud_queue;
      iconColor = settings.getIconColor();
    } else if (weatherCode <= 48) {
      icon = Icons.foggy;
      iconColor = settings.getIconColor(opacity: 0.8);
    } else if (weatherCode <= 67 || (weatherCode >= 80 && weatherCode <= 82)) {
      icon = Icons.water_drop;
      iconColor = _getWeatherSpecificColor(weatherCode, isDay, settings);
    } else if (weatherCode <= 77 || (weatherCode >= 85 && weatherCode <= 86)) {
      icon = Icons.ac_unit;
      iconColor = _getWeatherSpecificColor(weatherCode, isDay, settings);
    } else if (weatherCode >= 95) {
      icon = Icons.flash_on;
      iconColor = _getWeatherSpecificColor(weatherCode, isDay, settings);
    } else {
      icon = Icons.wb_cloudy;
    }

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: settings.getIconColor(opacity: 0.15),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 100,
        color: iconColor,
      ),
    );
  }

  // Get weather-specific colors that work with the theme
  Color _getWeatherSpecificColor(int weatherCode, bool isDay, SettingsService settings) {
    // For certain weather conditions, we want specific colors that blend with the theme
    switch (settings.iconThemeMode) {
      case 'day':
        // Day mode uses natural colors
        if (weatherCode == 0) return isDay ? Colors.amber : Colors.blue[100]!;
        if (weatherCode <= 67) return Colors.lightBlue[200]!;
        if (weatherCode <= 77) return Colors.lightBlue[50]!;
        if (weatherCode >= 95) return Colors.amber;
        return Colors.white;
        
      case 'glow':
        // Glow mode uses cyan-green tints
        if (weatherCode == 0) return const Color(0xFF00FFCC);
        if (weatherCode <= 67) return const Color(0xFF00DDFF);
        if (weatherCode <= 77) return const Color(0xFF88FFFF);
        if (weatherCode >= 95) return const Color(0xFFFFFF00);
        return const Color(0xFF00FF88);
        
      case 'night':
        // Night mode uses red tints
        if (weatherCode == 0) return const Color(0xFFFF6666);
        if (weatherCode <= 67) return const Color(0xFFFF4444);
        if (weatherCode <= 77) return const Color(0xFFFFAAAA);
        if (weatherCode >= 95) return const Color(0xFFFFFF88);
        return const Color(0xFFFF3333);
        
      default:
        return settings.getIconColor();
    }
  }
}