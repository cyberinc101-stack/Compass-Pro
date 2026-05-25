import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';

class DirectionCard extends StatelessWidget {
  final double heading;

  const DirectionCard({Key? key, required this.heading}) : super(key: key);

  bool _isDay() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 20;
  }

  Map<String, dynamic> _getDirection(double heading, String iconThemeMode, LocalizationService localization) {
    String name;
    Color color;

    // Determine direction name
    if (heading >= 337.5 || heading < 22.5) {
      name = localization.translate('north');
      color = iconThemeMode == 'glow' ? const Color(0xFF00FFCC) :
              iconThemeMode == 'night' ? const Color(0xFFFF6666) : Colors.red;
    } else if (heading >= 22.5 && heading < 67.5) {
      name = localization.translate('northeast');
      color = iconThemeMode == 'glow' ? const Color(0xFF00FFAA) :
              iconThemeMode == 'night' ? const Color(0xFFFF7777) : Colors.orange;
    } else if (heading >= 67.5 && heading < 112.5) {
      name = localization.translate('east');
      color = iconThemeMode == 'glow' ? const Color(0xFF00FF88) :
              iconThemeMode == 'night' ? const Color(0xFFFF8888) : Colors.yellow;
    } else if (heading >= 112.5 && heading < 157.5) {
      name = localization.translate('southeast');
      color = iconThemeMode == 'glow' ? const Color(0xFF00DD88) :
              iconThemeMode == 'night' ? const Color(0xFFFF9999) : Colors.lightGreen;
    } else if (heading >= 157.5 && heading < 202.5) {
      name = localization.translate('south');
      color = iconThemeMode == 'glow' ? const Color(0xFF00BBAA) :
              iconThemeMode == 'night' ? const Color(0xFFFFAAAA) : Colors.blue;
    } else if (heading >= 202.5 && heading < 247.5) {
      name = localization.translate('southwest');
      color = iconThemeMode == 'glow' ? const Color(0xFF00AACC) :
              iconThemeMode == 'night' ? const Color(0xFFFFBBBB) : Colors.indigo;
    } else if (heading >= 247.5 && heading < 292.5) {
      name = localization.translate('west');
      color = iconThemeMode == 'glow' ? const Color(0xFF00CCAA) :
              iconThemeMode == 'night' ? const Color(0xFFFFCCCC) : Colors.purple;
    } else {
      name = localization.translate('northwest');
      color = iconThemeMode == 'glow' ? const Color(0xFF00DDBB) :
              iconThemeMode == 'night' ? const Color(0xFFFFDDDD) : Colors.pink;
    }

    return {'name': name, 'color': color};
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final localization = Provider.of<LocalizationService>(context);
    final iconThemeMode = settings.iconThemeMode ?? 'default';
    final isDay = _isDay();
    final direction = _getDirection(heading, iconThemeMode, localization);
    
    final bgColor = iconThemeMode == 'glow' ? Colors.black.withOpacity(0.25) :
                    iconThemeMode == 'night' ? const Color(0xFF330000).withOpacity(0.3) :
                    Colors.white.withOpacity(0.15);
    
    final borderColor = iconThemeMode == 'glow' ? const Color(0xFF00FFAA).withOpacity(0.3) :
                        iconThemeMode == 'night' ? const Color(0xFFFF6666).withOpacity(0.3) :
                        Colors.white.withOpacity(0.3);
    
    final textColor = iconThemeMode == 'glow' ? const Color(0xFF00FFCC) :
                      iconThemeMode == 'night' ? const Color(0xFFFFAAAA) :
                      Colors.white;
    
    final glowColor = iconThemeMode == 'glow' ? const Color(0xFF00FFAA) :
                      iconThemeMode == 'night' ? const Color(0xFFFF6666) : null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: iconThemeMode != 'default' ? 1.5 : 1),
        boxShadow: glowColor != null ? [
          BoxShadow(
            color: glowColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_upward, 
            color: direction['color'],
            size: 28,
            shadows: glowColor != null ? [
              Shadow(color: direction['color'], blurRadius: 12),
            ] : null,
          ),
          const SizedBox(width: 12),
          Text(
            '${localization.translate('heading')} ${direction['name']}',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              shadows: glowColor != null ? [
                Shadow(color: textColor.withOpacity(0.5), blurRadius: 8),
              ] : null,
            ),
          ),
        ],
      ),
    );
  }
}