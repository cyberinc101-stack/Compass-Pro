import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';
import 'compass_styles/classic_compass.dart';
import 'compass_styles/digital_compass.dart';
import 'compass_styles/gradient_compass.dart';
import 'compass_styles/high_tech.dart';
import 'compass_styles/minimal_compass.dart';
import 'compass_styles/modern_compass.dart';
import 'compass_styles/nautical_compass.dart';
import 'compass_styles/neon_compass.dart';
import 'compass_styles/vintage_compass.dart';
import 'compass_styles/3d_compass.dart';
import 'compass_styles/tech_compass.dart';
import 'compass_styles/nav_compass.dart';
import 'compass_styles/tele_compass.dart';
import 'compass_styles/digi_compass.dart';

class CompassStyleSelectorScreen extends StatefulWidget {
  final String currentStyle;

  const CompassStyleSelectorScreen({
    Key? key,
    required this.currentStyle,
  }) : super(key: key);

  @override
  State<CompassStyleSelectorScreen> createState() =>
      _CompassStyleSelectorScreenState();
}

class _CompassStyleSelectorScreenState
    extends State<CompassStyleSelectorScreen> {
  late String selectedStyle;

  List<CompassStyleInfo> get compassStyles => [
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_tech'),
          id: 'tech',
          description: LocalizationService.translate('compass_desc_tech'),
          widget: TechCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_nav'),
          id: 'nav',
          description: LocalizationService.translate('compass_desc_nav'),
          widget: NavCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_tele'),
          id: 'tele',
          description: LocalizationService.translate('compass_desc_tele'),
          widget: TeleCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_digi'),
          id: 'digi',
          description: LocalizationService.translate('compass_desc_digi'),
          widget: DigiCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_classic'),
          id: 'classic',
          description: LocalizationService.translate('compass_desc_classic'),
          widget: ClassicCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_digital'),
          id: 'digital',
          description: LocalizationService.translate('compass_desc_digital'),
          widget: DigitalCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_modern'),
          id: 'modern',
          description: LocalizationService.translate('compass_desc_modern'),
          widget: ModernCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_minimal'),
          id: 'minimal',
          description: LocalizationService.translate('compass_desc_minimal'),
          widget: MinimalCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_gradient'),
          id: 'gradient',
          description: LocalizationService.translate('compass_desc_gradient'),
          widget: GradientCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_high_tech'),
          id: 'military',
          description: LocalizationService.translate('compass_desc_high_tech'),
          widget: HighTechCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_nautical'),
          id: 'nautical',
          description: LocalizationService.translate('compass_desc_nautical'),
          widget: NauticalCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_neon'),
          id: 'neon',
          description: LocalizationService.translate('compass_desc_neon'),
          widget: NeonCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_vintage'),
          id: 'vintage',
          description: LocalizationService.translate('compass_desc_vintage'),
          widget: VintageCompass(heading: 45),
        ),
        CompassStyleInfo(
          name: LocalizationService.translate('compass_style_3d'),
          id: '3d',
          description: LocalizationService.translate('compass_desc_3d'),
          widget: ThreeDCompass(heading: 45),
        ),
      ];

  @override
  void initState() {
    super.initState();
    selectedStyle = widget.currentStyle;
  }

  Future<void> _saveStylePreference(String styleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('compass_style', styleId);
  }

  /// Screen background gradient — matches background_selector_screen.dart
  List<Color> _screenGradient(String themeMode) {
    switch (themeMode) {
      case 'night':
        return const [Color(0xFF1a0000), Color(0xFF2d0000)];
      case 'glow':
        return const [Color(0xFF001a0d), Color(0xFF003320)];
      case 'day':
      default:
        return const [Color(0xFF4A90E2), Color(0xFF63B3ED)];
    }
  }

  /// Card preview area background
  Color _cardPreviewBackground(String themeMode) {
    switch (themeMode) {
      case 'night':
        return const Color(0xFF2d0000);
      case 'glow':
        return const Color(0xFF001a0d);
      case 'day':
      default:
        return Colors.white.withOpacity(0.95);
    }
  }

  /// Card label strip background (unselected)
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

  /// Primary text colour inside the label strip
  Color _cardLabelText(bool isSelected, String themeMode, Color iconColor) {
    if (isSelected) {
      switch (themeMode) {
        case 'night':
        case 'glow':
          return Colors.black;
        case 'day':
        default:
          return Colors.white;
      }
    }
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

  /// Secondary/description text colour inside the label strip
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

  /// Card border colour (unselected)
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
    final themeMode = settings.iconThemeMode;

    final iconColor = settings.getIconColor(opacity: 1.0);
    final textColor = settings.getTextColor(opacity: 1.0);
    final textColorMuted = settings.getTextColor(opacity: 0.7);

    final gradientColors = _screenGradient(themeMode);

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
                  // ── Header ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(70, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocalizationService.translate('choose_compass_style'),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LocalizationService.translate('select_preferred_design'),
                          style: TextStyle(
                            fontSize: 13,
                            color: textColorMuted,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // ── Grid ──────────────────────────────────────────────
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      cacheExtent: 2000,
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: compassStyles.length,
                      itemBuilder: (context, index) {
                        final style = compassStyles[index];
                        final isSelected = selectedStyle == style.id;

                        return _CompassStyleCard(
                          key: ValueKey(style.id),
                          style: style,
                          isSelected: isSelected,
                          cardPreviewBackground:
                              _cardPreviewBackground(themeMode),
                          labelBackground: _cardLabelBackground(
                              isSelected, themeMode, iconColor),
                          labelText:
                              _cardLabelText(isSelected, themeMode, iconColor),
                          subText:
                              _cardSubText(isSelected, themeMode, iconColor),
                          borderColor:
                              _borderColor(isSelected, themeMode, iconColor),
                          iconColor: iconColor,
                          onTap: () async {
                            setState(() => selectedStyle = style.id);
                            await _saveStylePreference(style.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${style.name} ${LocalizationService.translate('compass_selected')}',
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
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              // ── Back button ───────────────────────────────────────────
              Positioned(
                top: 10,
                left: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context, selectedStyle),
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

// ── Card widget ─────────────────────────────────────────────────────────────

class _CompassStyleCard extends StatefulWidget {
  final CompassStyleInfo style;
  final bool isSelected;
  final Color cardPreviewBackground;
  final Color labelBackground;
  final Color labelText;
  final Color subText;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _CompassStyleCard({
    Key? key,
    required this.style,
    required this.isSelected,
    required this.cardPreviewBackground,
    required this.labelBackground,
    required this.labelText,
    required this.subText,
    required this.borderColor,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_CompassStyleCard> createState() => _CompassStyleCardState();
}

class _CompassStyleCardState extends State<_CompassStyleCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.cardPreviewBackground,
            border: Border.all(
              color: widget.borderColor,
              width: widget.isSelected ? 3 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.iconColor.withOpacity(0.35),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Compass preview
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: RepaintBoundary(
                    child: IgnorePointer(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Transform.scale(
                            scale: 0.7,
                            child: widget.style.widget,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Label strip
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.labelBackground,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.style.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: widget.labelText,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        widget.style.description,
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.subText,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.isSelected) ...[
                      const SizedBox(height: 4),
                      Icon(
                        Icons.check_circle,
                        color: widget.labelText,
                        size: 18,
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
  }
}

// ── Data class ───────────────────────────────────────────────────────────────

class CompassStyleInfo {
  final String name;
  final String id;
  final String description;
  final Widget widget;

  CompassStyleInfo({
    required this.name,
    required this.id,
    required this.description,
    required this.widget,
  });
}