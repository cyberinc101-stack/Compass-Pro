import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:torch_light/torch_light.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/settings_service.dart';
import '../services/premium_service.dart';
import '../services/localization_service.dart';
import '../services/location_service.dart';
import '../widgets/my_apps_dropdown.dart';
import 'language_selector_screen.dart';
import 'membership_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBackToCompass;

  const SettingsScreen({Key? key, this.onBackToCompass}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isTorchOn = false;

  @override
  void dispose() {
    if (_isTorchOn) {
      _toggleTorch(false);
    }
    super.dispose();
  }

  Future<void> _toggleTorch(bool value) async {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    try {
      if (value) {
        await TorchLight.enableTorch();
      } else {
        await TorchLight.disableTorch();
      }
      setState(() {
        _isTorchOn = value;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localization.translate('could_not_control_torch')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getBackgroundStartColor(String themeMode) {
    switch (themeMode) {
      case 'day':   return const Color(0xFF4A90E2);
      case 'glow':  return const Color(0xFF003355);
      case 'night': return const Color(0xFF0D1117);
      default:      return const Color(0xFF4A90E2);
    }
  }

  Color _getBackgroundEndColor(String themeMode) {
    switch (themeMode) {
      case 'day':   return const Color(0xFF63B3ED);
      case 'glow':  return const Color(0xFF004466);
      case 'night': return const Color(0xFF1C1F26);
      default:      return const Color(0xFF63B3ED);
    }
  }

  Color _cardFill(String themeMode) {
    switch (themeMode) {
      case 'night': return const Color(0xFF21262D);
      case 'glow':  return const Color(0xFF1E2A3A);
      default:      return Colors.white;
    }
  }

  Widget _divider(Color textColor) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 72,
      endIndent: 16,
      color: textColor.withOpacity(0.08),
    );
  }

  Widget _iconBadge(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color headerColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: headerColor.withOpacity(0.85)),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: headerColor.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required String themeMode,
    required Color headerColor,
    required Color accent,
  }) {
    final light = themeMode == 'day';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title, icon, headerColor),
        Material(
          color: _cardFill(themeMode),
          elevation: light ? 4 : 0,
          shadowColor: Colors.black.withOpacity(0.25),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: light ? Colors.transparent : accent.withOpacity(0.22),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildPremiumBanner(PremiumService premium, LocalizationService localization) {
    final isPro = premium.isPremium;
    final colors = isPro
        ? const [Color(0xFF00C853), Color(0xFF009688)]
        : const [Color(0xFFFFB300), Color(0xFFFF6F00)];
    final title = isPro
        ? localization.translate('pro_member')
        : localization.translate('go_pro_remove_ads');
    final subtitle = isPro
        ? (premium.subscriptionType == 'yearly'
            ? localization.translate('yearly_plan_active')
            : localization.translate('monthly_plan_active'))
        : localization.translate('go_pro_subtitle');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MembershipScreen()),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings     = Provider.of<SettingsService>(context);
    final premium      = Provider.of<PremiumService>(context);
    final localization = Provider.of<LocalizationService>(context);
    final themeMode    = settings.iconThemeMode;
    final light        = themeMode == 'day';

    final textColor = light ? Colors.black87 : settings.getTextColor(opacity: 1.0);
    final iconColor = light
        ? const Color(0xFF4A90E2)
        : settings.getIconColor(opacity: 1.0);
    final headerColor = light ? Colors.white : textColor;
    final isDark = !light;

    final settingsLabel = localization.translate('settings');
    final screenTitle =
        (settingsLabel.isEmpty || settingsLabel == 'settings') ? 'Settings' : settingsLabel;

    Widget sec(String title, IconData icon, List<Widget> kids) => _section(
          title: title,
          icon: icon,
          children: kids,
          themeMode: themeMode,
          headerColor: headerColor,
          accent: iconColor,
        );

    const gap = SizedBox(height: 22);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getBackgroundStartColor(themeMode),
              _getBackgroundEndColor(themeMode),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (widget.onBackToCompass != null) {
                          widget.onBackToCompass!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: light
                              ? Colors.white.withOpacity(0.9)
                              : Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: light
                                ? const Color(0xFF4A90E2)
                                : settings.getIconColor(opacity: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: light
                              ? const Color(0xFF4A90E2)
                              : settings.getIconColor(),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      screenTitle,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: headerColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Theme Mode ──────────────────────────────────────────
              sec(localization.translate('theme_mode'), Icons.palette, [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.translate('select_preferred_theme'),
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildThemePreview(
                              localization.translate('day'),
                              Icons.wb_sunny,
                              const Color(0xFF4A90E2),
                              settings.iconThemeMode == 'day',
                              () => _changeTheme(settings, 'day', localization),
                              themeMode,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildThemePreview(
                              localization.translate('glow'),
                              Icons.nights_stay,
                              const Color(0xFF00FF88),
                              settings.iconThemeMode == 'glow',
                              () => _changeTheme(settings, 'glow', localization),
                              themeMode,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildThemePreview(
                              localization.translate('night'),
                              Icons.nightlight_round,
                              const Color(0xFFFF3333),
                              settings.iconThemeMode == 'night',
                              () => _changeTheme(settings, 'night', localization),
                              themeMode,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
              gap,

              // ── Premium ─────────────────────────────────────────────
              _sectionHeader(localization.translate('premium'), Icons.star, headerColor),
              _buildPremiumBanner(premium, localization),
              gap,

              // ── Display Elements ────────────────────────────────────
              sec(localization.translate('display_elements'), Icons.dashboard_customize, [
                _buildSwitchListTile(
                  icon: Icons.cloud,
                  title: localization.translate('show_weather_info'),
                  subtitle: localization.translate('show_weather_info_subtitle'),
                  value: settings.showWeatherInfo,
                  onChanged: (value) => settings.setShowWeatherInfo(value),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                _divider(textColor),
                _buildSwitchListTile(
                  icon: Icons.grid_on,
                  title: localization.translate('show_coordinates'),
                  subtitle: localization.translate('show_coordinates_subtitle'),
                  value: settings.showCoordinates,
                  onChanged: (value) => settings.setShowCoordinates(value),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                _divider(textColor),
                _buildSwitchListTile(
                  icon: Icons.bubble_chart,
                  title: localization.translate('show_level_bubble'),
                  subtitle: localization.translate('show_level_bubble_subtitle'),
                  value: settings.showLevelBubble,
                  onChanged: (value) => settings.setShowLevelBubble(value),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                _divider(textColor),
                _buildSwitchListTile(
                  icon: Icons.explore,
                  title: localization.translate('show_heading_card'),
                  subtitle: localization.translate('show_heading_card_subtitle'),
                  value: settings.showHeadingCard,
                  onChanged: (value) => settings.setShowHeadingCard(value),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                _divider(textColor),
                _buildSwitchListTile(
                  icon: Icons.location_city,
                  title: localization.translate('show_location_text'),
                  subtitle: localization.translate('show_location_text_subtitle'),
                  value: settings.showLocationText,
                  onChanged: (value) => settings.setShowLocationText(value),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                _divider(textColor),
                _buildSwitchListTile(
                  icon: Icons.info_outline,
                  title: localization.translate('show_info_cards'),
                  subtitle: localization.translate('show_info_cards_subtitle'),
                  value: settings.showInfoCards,
                  onChanged: (value) => settings.setShowInfoCards(value),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                if (settings.showInfoCards) ...[
                  Container(
                    width: double.infinity,
                    color: iconColor.withOpacity(0.06),
                    padding: const EdgeInsets.only(left: 72, top: 10, bottom: 4),
                    child: Text(
                      localization.translate('always_visible_cards').toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                  _buildSwitchListTile(
                    title: localization.translate('accuracy'),
                    subtitle: localization.translate('gps_accuracy_card'),
                    value: settings.showAccuracy,
                    onChanged: (value) => settings.setShowAccuracy(value),
                    textColor: textColor,
                    iconColor: iconColor,
                    contentPadding: const EdgeInsets.only(left: 72, right: 16),
                  ),
                  _buildSwitchListTile(
                    title: localization.translate('altitude'),
                    subtitle: localization.translate('current_altitude_card'),
                    value: settings.showAltitude,
                    onChanged: (value) => settings.setShowAltitude(value),
                    textColor: textColor,
                    iconColor: iconColor,
                    contentPadding: const EdgeInsets.only(left: 72, right: 16),
                  ),
                  _buildSwitchListTile(
                    title: localization.translate('bearing'),
                    subtitle: localization.translate('current_altitude_card'),
                    value: settings.showBearing,
                    onChanged: (value) => settings.setShowBearing(value),
                    textColor: textColor,
                    iconColor: iconColor,
                    contentPadding: const EdgeInsets.only(left: 72, right: 16),
                  ),
                  _buildSwitchListTile(
                    title: localization.translate('location'),
                    subtitle: localization.translate('lat_long_coordinates_card'),
                    value: settings.showLocation,
                    onChanged: (value) => settings.setShowLocation(value),
                    textColor: textColor,
                    iconColor: iconColor,
                    contentPadding: const EdgeInsets.only(left: 72, right: 16),
                  ),
                  _buildSwitchListTile(
                    title: localization.translate('elevation'),
                    subtitle: localization.translate('height_above_sea_level_card'),
                    value: settings.showElevation,
                    onChanged: (value) => settings.setShowElevation(value),
                    textColor: textColor,
                    iconColor: iconColor,
                    contentPadding: const EdgeInsets.only(left: 72, right: 16),
                  ),
                ],
              ]),
              gap,

              // ── Tools ───────────────────────────────────────────────
              sec(localization.translate('tools'), Icons.build, [
                _buildSwitchListTile(
                  icon: Icons.flashlight_on,
                  title: localization.translate('torch'),
                  subtitle: localization.translate('torch_subtitle'),
                  value: _isTorchOn,
                  onChanged: (value) => _toggleTorch(value),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
              ]),
              gap,

              // ── Compass Settings ────────────────────────────────────
              sec(localization.translate('compass_settings'), Icons.explore, [
                _buildListTile(
                  icon: Icons.tune,
                  title: localization.translate('declination_adjustment'),
                  subtitle: '${localization.translate('declination_current')}: ${settings.magneticDeclination.toStringAsFixed(2)}°',
                  onTap: () => _showDeclinationDialog(context, settings, localization),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
              ]),
              gap,

              // ── Language ────────────────────────────────────────────
              sec(localization.translate('language'), Icons.language, [
                _buildListTile(
                  icon: Icons.language,
                  title: localization.translate('language'),
                  subtitle: _getLanguageName(settings.language, localization),
                  onTap: () => _showLanguageSelector(context, settings, localization),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
              ]),
              gap,

              // ── Units ───────────────────────────────────────────────
              sec(localization.translate('units'), Icons.straighten, [
                _buildListTile(
                  icon: Icons.thermostat,
                  title: localization.translate('temperature_unit_setting'),
                  subtitle: settings.temperatureUnit,
                  onTap: () => _showUnitPicker(context, settings, 'temperature', localization),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
              ]),
              gap,

              // ── Location Settings ───────────────────────────────────
              sec(localization.translate('location_settings'), Icons.my_location, [
                _buildListTile(
                  icon: Icons.gps_fixed,
                  title: localization.translate('gps_accuracy_setting'),
                  subtitle: settings.gpsAccuracy,
                  onTap: () => _showAccuracyPicker(context, settings, localization),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
              ]),
              gap,

              // ── Data & Privacy ──────────────────────────────────────
              sec(localization.translate('data_privacy'), Icons.shield, [
                _buildListTile(
                  icon: Icons.storage,
                  title: localization.translate('clear_cache'),
                  subtitle: localization.translate('clear_cache_subtitle'),
                  onTap: () => _showClearCacheDialog(context, settings, localization),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                _divider(textColor),
                _buildListTile(
                  icon: Icons.privacy_tip,
                  title: localization.translate('privacy_policy'),
                  onTap: () async {
                    final u = Uri.parse('https://cyberinc101-stack.github.io/compasspro-privacy/compass-pro/');
                    if (!await launchUrl(u, mode: LaunchMode.externalApplication) && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                      );
                    }
                  },
                  textColor: textColor,
                  iconColor: iconColor,
                ),
              ]),
              gap,

              // ── Legal & Support ─────────────────────────────────────
              sec(localization.translate('legal_support'), Icons.gavel, [
                _buildListTile(
                  icon: Icons.description,
                  title: localization.translate('terms_of_service'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServiceScreen(),
                      ),
                    );
                  },
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                _divider(textColor),
                _buildListTile(
                  icon: Icons.contact_support,
                  title: localization.translate('contact_report_bug'),
                  onTap: () => _composeEmail(context, localization),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
              ]),
              gap,

              // ── More Apps ───────────────────────────────────────────
              sec('More Apps', Icons.apps, [
                MyAppsDropdown(
                  currentAppId: AppId.compassPro,
                  isDark: isDark,
                  style: MyAppsDropdownStyle(
                    textColorLight: Colors.black87,
                    subtleTextColorLight: Colors.black54,
                    cardColorLight: Colors.transparent,
                    borderColorLight: Colors.transparent,
                    textColorDark: Colors.white,
                    subtleTextColorDark: Colors.white60,
                    cardColorDark: Colors.transparent,
                    borderColorDark: Colors.transparent,
                    accentColor: iconColor,
                    borderRadius: 16,
                    titleWeight: FontWeight.w600,
                    titleFontSize: 15,
                  ),
                ),
              ]),
              gap,

              // ── About ───────────────────────────────────────────────
              sec(localization.translate('about'), Icons.info, [
                _buildListTile(
                  icon: Icons.info,
                  title: localization.translate('version'),
                  subtitle: '1.0.0',
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                _divider(textColor),
                _buildListTile(
                  icon: Icons.share,
                  title: localization.translate('share_app'),
                  onTap: () => _shareApp(localization),
                  textColor: textColor,
                  iconColor: iconColor,
                ),
              ]),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    IconData? icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    required Color textColor,
    required Color iconColor,
  }) {
    return ListTile(
      leading: icon != null ? _iconBadge(icon, iconColor) : null,
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13))
          : null,
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: iconColor.withOpacity(0.6), size: 22)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSwitchListTile({
    IconData? icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required Color iconColor,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final settings  = Provider.of<SettingsService>(context, listen: false);
    final themeMode = settings.iconThemeMode;

    return SwitchListTile(
      secondary: icon != null ? _iconBadge(icon, iconColor) : null,
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13))
          : null,
      value: value,
      onChanged: onChanged,
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return themeMode == 'day' ? const Color(0xFF4A90E2) : iconColor;
        }
        return themeMode == 'day' ? Colors.white : Colors.grey[600]!;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return themeMode == 'day'
              ? const Color(0xFF4A90E2).withOpacity(0.4)
              : iconColor.withOpacity(0.5);
        }
        return themeMode == 'day' ? Colors.grey[400]! : Colors.grey[700]!;
      }),
      trackOutlineColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (themeMode == 'day') {
          return states.contains(MaterialState.selected)
              ? const Color(0xFF4A90E2)
              : Colors.grey[500];
        }
        return null;
      }),
      contentPadding:
          contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _changeTheme(SettingsService settings, String mode, LocalizationService localization) {
    settings.setIconThemeMode(mode);
    if (mode == 'day') {
      settings.setDarkMode(false);
    } else {
      settings.setDarkMode(true);
    }
    final modeNames = {
      'day':   localization.translate('day_mode'),
      'glow':  localization.translate('glow_mode'),
      'night': localization.translate('night_mode'),
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${localization.translate('theme_changed_to')} ${modeNames[mode]}'),
        duration: const Duration(seconds: 1),
        backgroundColor: settings.iconThemeMode == 'night'
            ? const Color(0xFF21262D)
            : settings.iconThemeMode == 'glow'
                ? const Color(0xFF1E2A3A)
                : null,
      ),
    );
  }

  Widget _buildThemePreview(String label, IconData icon, Color color, bool isSelected,
      VoidCallback onTap, String themeMode) {
    final labelColor = themeMode == 'day'
        ? (isSelected ? const Color(0xFF2C5282) : Colors.grey[700]!)
        : (isSelected ? color : Colors.grey[500]!);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(Colors.black, color, 0.35)!,
                  color.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? (themeMode == 'day' ? const Color(0xFF2C5282) : Colors.white)
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Stack(
              children: [
                Center(child: Icon(icon, color: Colors.white, size: 34)),
                if (isSelected)
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(Icons.check_circle, color: Colors.white, size: 18),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: labelColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
  String _getLanguageName(String code, LocalizationService localization) {
    const languageMap = {
      'en': 'English', 'es': 'Español', 'fr': 'Français', 'de': 'Deutsch',
      'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский', 'zh': '中文',
      'ja': '日本語', 'ko': '한국어', 'ar': 'العربية', 'hi': 'हिन्दी',
      'bn': 'বাংলা', 'tr': 'Türkçe', 'pl': 'Polski', 'nl': 'Nederlands',
      'sv': 'Svenska', 'da': 'Dansk', 'no': 'Norsk', 'fi': 'Suomi',
    };
    return languageMap[code] ?? 'English';
  }

  Future<void> _showLanguageSelector(BuildContext context, SettingsService settings,
      LocalizationService localization) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageSelectorScreen(currentLanguage: settings.language),
      ),
    );

    if (result != null && result != settings.language) {
      await settings.setLanguage(result);
      try {
        final locationService = Provider.of<LocationService>(context, listen: false);
        locationService.setLanguage(result);
        if (locationService.currentPosition != null) {
          locationService.refreshLocation();
        }
      } catch (e) {
        debugPrint('❌ ERROR updating LocationService in Settings: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localization.translate('language_changed_to')} ${_getLanguageName(result, localization)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showDeclinationDialog(BuildContext context, SettingsService settings,
      LocalizationService localization) {
    final controller = TextEditingController(
      text: settings.magneticDeclination.toStringAsFixed(2),
    );
    final themeMode = settings.iconThemeMode;
    final dialogBg = themeMode == 'night'
        ? const Color(0xFF21262D)
        : themeMode == 'glow'
            ? const Color(0xFF1E2A3A)
            : Colors.white;
    final textColor = themeMode == 'day' ? Colors.black87 : Colors.white;
    final iconColor = themeMode == 'day'
        ? const Color(0xFF4A90E2)
        : settings.getIconColor(opacity: 1.0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(localization.translate('magnetic_declination'), style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localization.translate('magnetic_declination_message'),
                style: TextStyle(color: textColor.withOpacity(0.8))),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: localization.translate('declination_degrees'),
                labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                hintText: localization.translate('declination_hint'),
                hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: textColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: iconColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.translate('cancel'), style: TextStyle(color: iconColor)),
          ),
          ElevatedButton(
            onPressed: () {
              settings.autoDetectDeclination();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(localization.translate('auto_detecting_declination')),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: themeMode == 'day' ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(localization.translate('auto_detect')),
          ),
          ElevatedButton(
            onPressed: () {
              final declination = double.tryParse(controller.text);
              if (declination != null) {
                settings.setMagneticDeclination(declination);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${localization.translate('declination_set_to')} ${declination.toStringAsFixed(2)}°'),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: themeMode == 'day' ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(localization.translate('save')),
          ),
        ],
      ),
    );
  }

  void _showUnitPicker(BuildContext context, SettingsService settings, String type,
      LocalizationService localization) {
    List<String> units;
    String currentValue;

    switch (type) {
      case 'distance':
        units = [
          localization.translate('meters'),
          localization.translate('feet'),
          localization.translate('kilometers'),
          localization.translate('miles'),
        ];
        currentValue = settings.distanceUnit;
        break;
      case 'speed':
        units = [
          localization.translate('m_s'),
          localization.translate('km_h'),
          localization.translate('mph'),
          localization.translate('knots'),
        ];
        currentValue = settings.speedUnit;
        break;
      case 'temperature':
        units = ['Celsius', 'Fahrenheit', localization.translate('kelvin')];
        currentValue = settings.temperatureUnit;
        break;
      default:
        units = [];
        currentValue = '';
    }

    final themeMode = settings.iconThemeMode;
    final dialogBg = themeMode == 'night'
        ? const Color(0xFF21262D)
        : themeMode == 'glow'
            ? const Color(0xFF1E2A3A)
            : Colors.white;
    final textColor = themeMode == 'day' ? Colors.black87 : Colors.white;
    final iconColor = themeMode == 'day'
        ? const Color(0xFF4A90E2)
        : settings.getIconColor(opacity: 1.0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${localization.translate('select_unit')} ${type.capitalize()}',
            style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: units.map((unit) {
            return RadioListTile<String>(
              title: Text(unit, style: TextStyle(color: textColor)),
              value: unit,
              groupValue: currentValue,
              activeColor: iconColor,
              onChanged: (value) {
                if (value != null) {
                  if (type == 'distance') {
                    settings.setDistanceUnit(value);
                  } else if (type == 'speed') {
                    settings.setSpeedUnit(value);
                  } else {
                    settings.setTemperatureUnit(value);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${type.capitalize()} ${localization.translate('unit_set_to')} $value'),
                  ));
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAccuracyPicker(BuildContext context, SettingsService settings,
      LocalizationService localization) {
    final accuracies = [
      localization.translate('gps_accuracy_low'),
      localization.translate('gps_accuracy_medium'),
      localization.translate('gps_accuracy_high'),
      localization.translate('gps_accuracy_best'),
    ];
    final themeMode = settings.iconThemeMode;
    final dialogBg = themeMode == 'night'
        ? const Color(0xFF21262D)
        : themeMode == 'glow'
            ? const Color(0xFF1E2A3A)
            : Colors.white;
    final textColor = themeMode == 'day' ? Colors.black87 : Colors.white;
    final iconColor = themeMode == 'day'
        ? const Color(0xFF4A90E2)
        : settings.getIconColor(opacity: 1.0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(localization.translate('gps_accuracy_setting'), style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: accuracies.map((accuracy) {
            return RadioListTile<String>(
              title: Text(accuracy, style: TextStyle(color: textColor)),
              subtitle: Text(_getAccuracyDescription(accuracy, localization),
                  style: TextStyle(color: textColor.withOpacity(0.6))),
              value: accuracy,
              groupValue: settings.gpsAccuracy,
              activeColor: iconColor,
              onChanged: (value) {
                if (value != null) {
                  settings.setGpsAccuracy(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${localization.translate('gps_accuracy_set_to')} $value'),
                  ));
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getAccuracyDescription(String accuracy, LocalizationService localization) {
    if (accuracy == localization.translate('gps_accuracy_low'))    return localization.translate('gps_accuracy_low_desc');
    if (accuracy == localization.translate('gps_accuracy_medium')) return localization.translate('gps_accuracy_medium_desc');
    if (accuracy == localization.translate('gps_accuracy_high'))   return localization.translate('gps_accuracy_high_desc');
    if (accuracy == localization.translate('gps_accuracy_best'))   return localization.translate('gps_accuracy_best_desc');
    return '';
  }

  void _showClearCacheDialog(BuildContext context, SettingsService settings,
      LocalizationService localization) {
    final themeMode = settings.iconThemeMode;
    final dialogBg = themeMode == 'night'
        ? const Color(0xFF21262D)
        : themeMode == 'glow'
            ? const Color(0xFF1E2A3A)
            : Colors.white;
    final textColor = themeMode == 'day' ? Colors.black87 : Colors.white;
    final iconColor = themeMode == 'day'
        ? const Color(0xFF4A90E2)
        : settings.getIconColor(opacity: 1.0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(localization.translate('clear_cache'), style: TextStyle(color: textColor)),
        content: Text(localization.translate('clear_cache_message'),
            style: TextStyle(color: textColor.withOpacity(0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.translate('cancel'), style: TextStyle(color: iconColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(localization.translate('cache_cleared')),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: themeMode == 'day' ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(localization.translate('clear')),
          ),
        ],
      ),
    );
  }

  Future<void> _composeEmail(BuildContext context, LocalizationService localization) async {
    const supportEmail = 'bossproductions86@gmail.com';
    const appName = 'Compass Safe Pro';
    final emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {'subject': '[$appName] Support', 'body': ''},
    );
    try {
      if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(localization.translate('could_not_open_email')),
            duration: const Duration(seconds: 4),
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${localization.translate('error_opening_email')}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ));
      }
    }
  }

  void _shareApp(LocalizationService localization) {
    Share.share(
      localization.translate('share_app_message'),
      subject: localization.translate('share_app_subject'),
    );
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
