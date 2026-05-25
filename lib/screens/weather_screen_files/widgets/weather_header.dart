import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/settings_service.dart';
import '../../../services/localization_service.dart'; // ADDED

class WeatherHeader extends StatelessWidget {
  final String? locationName;
  final bool hasWeatherData;
  final bool isCurrentLocation;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onSearchLocation;

  const WeatherHeader({
    Key? key,
    required this.locationName,
    required this.hasWeatherData,
    required this.isCurrentLocation,
    required this.onUseCurrentLocation,
    required this.onSearchLocation,
  }) : super(key: key);

  // FIXED: Use LocalizationService for translation
  String translate(String key) {
    return LocalizationService.translate(key);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    
    return Column(
      children: [
        // Top row with centered buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Current location button
              IconButton(
                onPressed: onUseCurrentLocation,
                icon: Icon(
                  Icons.my_location,
                  color: isCurrentLocation 
                      ? settings.getIconColor()
                      : settings.getIconColor(opacity: 0.7),
                  size: 28,
                  shadows: [
                    Shadow(
                      color: isCurrentLocation 
                          ? settings.getIconColor(opacity: 0.5)
                          : Colors.black26,
                      offset: const Offset(1, 1),
                      blurRadius: isCurrentLocation ? 8 : 3,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Search button
              IconButton(
                onPressed: onSearchLocation,
                icon: Icon(
                  Icons.search,
                  color: settings.getIconColor(),
                  size: 28,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Centered location display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                settings.getIconColor(opacity: 0.25),
                settings.getIconColor(opacity: 0.15),
                settings.getIconColor(opacity: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: settings.getIconColor(opacity: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: settings.getIconColor(),
                    size: 22,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  if (isCurrentLocation)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getLiveBadgeColor(settings).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _getLiveBadgeColor(settings).withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: _getLiveBadgeColor(settings),
                          ),
                          const SizedBox(width: 4),
                          // FIXED: "Live" now translates
                          Text(
                            translate('live'),
                            style: TextStyle(
                              color: settings.getTextColor(opacity: 0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                locationName ?? translate('loading_location'),
                style: TextStyle(
                  color: settings.getTextColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              if (hasWeatherData) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 13,
                      color: settings.getIconColor(opacity: 0.8),
                    ),
                    const SizedBox(width: 5),
                    // FIXED: "Updated" now translates
                    Text(
                      '${translate('updated')} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: settings.getTextColor(opacity: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getLiveBadgeColor(SettingsService settings) {
    // Keep green for day mode, adjust for glow and night modes
    switch (settings.iconThemeMode) {
      case 'day':
        return Colors.green;
      case 'glow':
        return const Color(0xFF00FF88); // Match glow theme
      case 'night':
        return const Color(0xFFFF3333); // Match night theme
      default:
        return Colors.green;
    }
  }
}