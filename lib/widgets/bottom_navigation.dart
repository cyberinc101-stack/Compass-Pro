import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onItemTapped,
    required this.isDarkMode,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final t = Provider.of<LocalizationService>(context);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            const SizedBox(width: 8),
            _buildNavButton(context, settings, t,
                index: 1,
                icon: Icons.wb_sunny_outlined,
                selectedIcon: Icons.wb_sunny,
                label: t.translate('weather')),
            _buildNavButton(context, settings, t,
                index: 2,
                icon: Icons.location_on_outlined,
                selectedIcon: Icons.location_on,
                label: t.translate('location_nav')),
            _buildNavButton(context, settings, t,
                index: 4,
                icon: Icons.bookmark_outline,
                selectedIcon: Icons.bookmark,
                label: t.translate('saved')),
            _buildNavButton(context, settings, t,
                index: 0,
                icon: Icons.explore_outlined,
                selectedIcon: Icons.explore,
                label: t.translate('compass')),
            _buildNavButton(context, settings, t,
                index: 5,
                icon: Icons.palette_outlined,
                selectedIcon: Icons.palette,
                label: t.translate('background')),
            _buildThemeToggle(context, settings, t),
            _buildNavButton(context, settings, t,
                index: 6,
                icon: Icons.tune_outlined,
                selectedIcon: Icons.tune,
                label: t.translate('calibrate')),
            _buildNavButton(context, settings, t,
                index: 7,
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: t.translate('settings')),
            _buildNavButton(context, settings, t,
                index: 9,
                icon: Icons.workspace_premium_outlined,
                selectedIcon: Icons.workspace_premium,
                label: t.translate('pro')),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    SettingsService settings,
    LocalizationService t, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    bool isPremium = false,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? settings.getIconColor(opacity: 1.0)
        : settings.getIconColor(opacity: 0.8);

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(
      BuildContext context, SettingsService settings, LocalizationService t) {
    IconData themeIcon;
    String themeLabel;

    switch (settings.iconThemeMode) {
      case 'day':
        themeIcon = Icons.wb_sunny;
        themeLabel = t.translate('day');
        break;
      case 'glow':
        themeIcon = Icons.nights_stay;
        themeLabel = t.translate('glow');
        break;
      case 'night':
        themeIcon = Icons.nightlight_round;
        themeLabel = t.translate('night');
        break;
      default:
        themeIcon = Icons.wb_sunny;
        themeLabel = t.translate('day');
    }

    return GestureDetector(
      onTap: () => settings.cycleIconThemeMode(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(themeIcon,
                color: settings.getIconColor(opacity: 0.85), size: 26),
            const SizedBox(height: 4),
            Text(
              themeLabel,
              style: TextStyle(
                fontSize: 10,
                color: settings.getTextColor(opacity: 0.85),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}