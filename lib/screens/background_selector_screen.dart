import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';

class BackgroundSelectorScreen extends StatefulWidget {
  final String currentBackground;

  const BackgroundSelectorScreen({
    Key? key,
    required this.currentBackground,
  }) : super(key: key);

  @override
  State<BackgroundSelectorScreen> createState() =>
      _BackgroundSelectorScreenState();
}

class _BackgroundSelectorScreenState extends State<BackgroundSelectorScreen> {
  late String selectedBackground;

  List<BackgroundStyleInfo> _getBackgroundStyles(LocalizationService localization) {
    return [
      BackgroundStyleInfo(
        name: localization.translate('bg_night_sky'),
        id: 'night',
        description: localization.translate('bg_night_sky_desc'),
        colors: const [Color(0xFF0a0e27), Color(0xFF1a1f3a)],
        icon: Icons.nights_stay,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_aurora'),
        id: 'aurora',
        description: localization.translate('bg_aurora_desc'),
        colors: const [Color(0xFF1a2332), Color(0xFF2d4a5a), Color(0xFF1a3a4a)],
        icon: Icons.light_mode,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_black'),
        id: 'black',
        description: localization.translate('bg_black_desc'),
        colors: const [Color(0xFF000000), Color(0xFF0a0a0a)],
        icon: Icons.brightness_2,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_galaxy'),
        id: 'galaxy',
        description: localization.translate('bg_galaxy_desc'),
        colors: const [Color(0xFF1a0033), Color(0xFF330066), Color(0xFF1a0033)],
        icon: Icons.stars,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_cosmic'),
        id: 'cosmic',
        description: localization.translate('bg_cosmic_desc'),
        colors: const [Color(0xFF0d001a), Color(0xFF1a0033), Color(0xFF2d0052)],
        icon: Icons.auto_awesome,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_nebula'),
        id: 'nebula',
        description: localization.translate('bg_nebula_desc'),
        colors: const [Color(0xFF1a0a33), Color(0xFF331a52), Color(0xFF52247a)],
        icon: Icons.blur_on,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_classic'),
        id: 'classic',
        description: localization.translate('bg_classic_desc'),
        colors: const [Color(0xFF4A90E2), Color(0xFF63B3ED)],
        icon: Icons.gradient,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_map'),
        id: 'map',
        description: localization.translate('bg_map_desc'),
        colors: const [Color(0xFF2d3e50), Color(0xFF3d5a73)],
        icon: Icons.map,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_transparent'),
        id: 'transparent',
        description: localization.translate('bg_transparent_desc'),
        colors: const [Color(0xFFf5f5f5), Color(0xFFe0e0e0)],
        icon: Icons.filter_none,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_weather'),
        id: 'weather',
        description: localization.translate('bg_weather_desc'),
        colors: const [Color(0xFF4A90E2), Color(0xFF5fb3f5), Color(0xFF87CEEB)],
        icon: Icons.wb_cloudy,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_dark'),
        id: 'dark',
        description: localization.translate('bg_dark_desc'),
        colors: const [Color(0xFF0D1117), Color(0xFF1C1F26)],
        icon: Icons.dark_mode,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_sunset'),
        id: 'sunset',
        description: localization.translate('bg_sunset_desc'),
        colors: const [Color(0xFFff6b35), Color(0xFFf7931e), Color(0xFFffd700)],
        icon: Icons.wb_twilight,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_ocean'),
        id: 'ocean',
        description: localization.translate('bg_ocean_desc'),
        colors: const [Color(0xFF003d5c), Color(0xFF006994), Color(0xFF0099cc)],
        icon: Icons.waves,
      ),
      BackgroundStyleInfo(
        name: localization.translate('bg_mountain'),
        id: 'mountain',
        description: localization.translate('bg_mountain_desc'),
        colors: const [Color(0xFF2c3e50), Color(0xFF4a5f7f), Color(0xFF6c8099)],
        icon: Icons.terrain,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    selectedBackground = widget.currentBackground;
  }

  Future<void> _saveBackgroundPreference(String backgroundId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('background_style', backgroundId);
    } catch (e) {
      debugPrint('Error saving background preference: $e');
    }
  }

  /// Returns the two gradient colours used for the screen background,
  /// driven entirely by [SettingsService.iconThemeMode].
  List<Color> _screenGradient(String themeMode) {
    switch (themeMode) {
      case 'night':
        // Deep red-tinted dark background for night vision
        return const [Color(0xFF1a0000), Color(0xFF2d0000)];
      case 'glow':
        // Deep teal-green for glow mode
        return const [Color(0xFF001a0d), Color(0xFF003320)];
      case 'day':
      default:
        return const [Color(0xFF4A90E2), Color(0xFF63B3ED)];
    }
  }

  /// Colour for the card label strip at the bottom of each grid tile.
  Color _cardLabelBackground(bool isSelected, String themeMode, Color iconColor) {
    if (isSelected) return iconColor;
    switch (themeMode) {
      case 'night':
        return const Color(0xFF2d0000);
      case 'glow':
        return const Color(0xFF001a0d);
      case 'day':
      default:
        return const Color(0xFF1a2a3a);
    }
  }

  /// Text colour inside the card label strip.
  Color _cardLabelText(bool isSelected, String themeMode, Color iconColor) {
    if (isSelected) {
      // Make selected label text legible against the accent colour
      switch (themeMode) {
        case 'night':
          return Colors.black;
        case 'glow':
          return Colors.black;
        case 'day':
        default:
          return Colors.white;
      }
    }
    // Unselected: use the theme's text colour (already bright enough)
    switch (themeMode) {
      case 'night':
        return const Color(0xFFFF4444);
      case 'glow':
        return const Color(0xFF00FFAA);
      case 'day':
      default:
        return Colors.white;
    }
  }

  Color _cardSubText(bool isSelected, String themeMode, Color iconColor) {
    if (isSelected) {
      return _cardLabelText(true, themeMode, iconColor).withOpacity(0.75);
    }
    switch (themeMode) {
      case 'night':
        return const Color(0xFFFF4444).withOpacity(0.6);
      case 'glow':
        return const Color(0xFF00FFAA).withOpacity(0.6);
      case 'day':
      default:
        return Colors.white60;
    }
  }

  Color _borderColor(bool isSelected, String themeMode, Color iconColor) {
    if (isSelected) return iconColor;
    switch (themeMode) {
      case 'night':
        return const Color(0xFFFF3333).withOpacity(0.25);
      case 'glow':
        return const Color(0xFF00FF88).withOpacity(0.25);
      case 'day':
      default:
        return Colors.white.withOpacity(0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final localization = Provider.of<LocalizationService>(context);
    final themeMode = settings.iconThemeMode;

    final iconColor = settings.getIconColor(opacity: 1.0);
    final textColor = settings.getTextColor(opacity: 1.0);
    final textColorMuted = settings.getTextColor(opacity: 0.7);

    final gradientColors = _screenGradient(themeMode);
    final backgroundStyles = _getBackgroundStyles(localization);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(70, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.translate('choose_background'),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localization.translate('select_preferred_style'),
                          style: TextStyle(
                            fontSize: 14,
                            color: textColorMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Grid ────────────────────────────────────────────────
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: backgroundStyles.length,
                      itemBuilder: (context, index) {
                        final style = backgroundStyles[index];
                        final isSelected = selectedBackground == style.id;

                        final cardBorder =
                            _borderColor(isSelected, themeMode, iconColor);
                        final labelBg = _cardLabelBackground(
                            isSelected, themeMode, iconColor);
                        final labelText =
                            _cardLabelText(isSelected, themeMode, iconColor);
                        final subText =
                            _cardSubText(isSelected, themeMode, iconColor);

                        return GestureDetector(
                          onTap: () async {
                            if (!mounted) return;
                            setState(() => selectedBackground = style.id);
                            await _saveBackgroundPreference(style.id);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${style.name} ${localization.translate('background_selected')}',
                                ),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: themeMode == 'night'
                                    ? const Color(0xFF2d0000)
                                    : themeMode == 'glow'
                                        ? const Color(0xFF001a0d)
                                        : null,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: cardBorder,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: iconColor.withOpacity(0.35),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Column(
                                children: [
                                  // Gradient preview tile
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: style.colors,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          style.icon,
                                          size: 48,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Label strip
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: labelBg,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(18),
                                        bottomRight: Radius.circular(18),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          style.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: labelText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          style.description,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: subText,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(height: 4),
                                          Icon(
                                            Icons.check_circle,
                                            color: labelText,
                                            size: 20,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // ── Back button ─────────────────────────────────────────────
              Positioned(
                top: 10,
                left: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (mounted) Navigator.pop(context, selectedBackground);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: iconColor.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackgroundStyleInfo {
  final String name;
  final String id;
  final String description;
  final List<Color> colors;
  final IconData icon;

  BackgroundStyleInfo({
    required this.name,
    required this.id,
    required this.description,
    required this.colors,
    required this.icon,
  });
}