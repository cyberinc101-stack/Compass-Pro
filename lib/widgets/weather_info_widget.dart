import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';

class WeatherInfoWidget extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  
  const WeatherInfoWidget({
    Key? key,
    this.weatherData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Selector instead of Provider.of to prevent unnecessary rebuilds
    return Selector<SettingsService, _SettingsData>(
      selector: (_, settings) => _SettingsData(
        iconColor: settings.getIconColor(opacity: 0.85),
        textColorLight: settings.getTextColor(opacity: 0.65),
        textColorDark: settings.getTextColor(opacity: 0.95),
      ),
      builder: (context, settingsData, child) {
        final localization = Provider.of<LocalizationService>(context);
        
        // If no weather data, show placeholder immediately
        if (weatherData == null) {
          return _buildPlaceholder(settingsData, localization);
        }

        // Extract and parse data once
        final weatherInfo = _parseWeatherData(weatherData!, localization);
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherItem(
                settingsData, 
                Icons.thermostat, 
                weatherInfo.temp, 
                localization.translate('temp')
              ),
              _buildWeatherConditionItem(
                settingsData, 
                weatherInfo.conditionIcon,
                weatherInfo.conditionLabel,
                localization.translate('condition'),
              ),
              _buildWeatherItem(
                settingsData, 
                Icons.air, 
                weatherInfo.windSpeed, 
                localization.translate('wind')
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(_SettingsData settings, LocalizationService localization) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildWeatherItem(settings, Icons.thermostat, localization.translate('no_data'), localization.translate('temp')),
          _buildWeatherItem(settings, Icons.wb_sunny, localization.translate('no_data'), localization.translate('condition')),
          _buildWeatherItem(settings, Icons.air, localization.translate('no_data'), localization.translate('wind')),
        ],
      ),
    );
  }

  /// Parse weather data once to avoid repeated calculations
  _WeatherInfo _parseWeatherData(Map<String, dynamic> data, LocalizationService localization) {
    final current = data['current'];
    final temp = '${(current['temperature_2m'] as num).round()}°C';
    final windSpeed = '${(current['wind_speed_10m'] as num).round()} km/h';
    final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
    
    // Get condition data in one pass
    final conditionData = _getConditionFromCode(weatherCode, localization);
    
    return _WeatherInfo(
      temp: temp,
      windSpeed: windSpeed,
      conditionIcon: conditionData['icon'],
      conditionLabel: conditionData['label'],
    );
  }

  /// Optimized: Return both icon and label at once to avoid double lookup
  Map<String, dynamic> _getConditionFromCode(int code, LocalizationService localization) {
    if (code == 0) return {'icon': Icons.wb_sunny, 'label': localization.translate('clear')};
    if (code <= 3) return {'icon': Icons.wb_cloudy, 'label': localization.translate('partly_cloudy')};
    if (code <= 48) return {'icon': Icons.cloud_queue, 'label': localization.translate('foggy')};
    if (code <= 67) return {'icon': Icons.grain, 'label': localization.translate('rainy')};
    if (code <= 77) return {'icon': Icons.ac_unit, 'label': localization.translate('snowy')};
    if (code <= 82) return {'icon': Icons.shower, 'label': localization.translate('showers')};
    if (code <= 86) return {'icon': Icons.ac_unit, 'label': localization.translate('snowy')};
    if (code <= 99) return {'icon': Icons.thunderstorm, 'label': localization.translate('storm')};
    return {'icon': Icons.wb_sunny, 'label': localization.translate('clear')};
  }

  Widget _buildWeatherConditionItem(
    _SettingsData settings,
    IconData icon,
    String label,
    String conditionText,
  ) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: settings.iconColor,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            conditionText,
            style: TextStyle(
              color: settings.textColorLight,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: settings.textColorDark,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherItem(
    _SettingsData settings,
    IconData icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: settings.iconColor,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: settings.textColorLight,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: settings.textColorDark,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// Immutable data class to prevent unnecessary rebuilds
class _SettingsData {
  final Color iconColor;
  final Color textColorLight;
  final Color textColorDark;

  const _SettingsData({
    required this.iconColor,
    required this.textColorLight,
    required this.textColorDark,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SettingsData &&
          iconColor == other.iconColor &&
          textColorLight == other.textColorLight &&
          textColorDark == other.textColorDark;

  @override
  int get hashCode =>
      iconColor.hashCode ^
      textColorLight.hashCode ^
      textColorDark.hashCode;
}

/// Parsed weather information
class _WeatherInfo {
  final String temp;
  final String windSpeed;
  final IconData conditionIcon;
  final String conditionLabel;

  const _WeatherInfo({
    required this.temp,
    required this.windSpeed,
    required this.conditionIcon,
    required this.conditionLabel,
  });
}