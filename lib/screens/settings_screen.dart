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

  @override
  Widget build(BuildContext context) {
    final settings     = Provider.of<SettingsService>(context);
    final premium      = Provider.of<PremiumService>(context);
    final localization = Provider.of<LocalizationService>(context);
    final themeMode    = settings.iconThemeMode;

    final textColor = themeMode == 'day'
        ? Colors.black87
        : settings.getTextColor(opacity: 1.0);
    final iconColor = themeMode == 'day'
        ? const Color(0xFF4A90E2)
        : settings.getIconColor(opacity: 1.0);
    final cardBackgroundColor = themeMode == 'night'
        ? const Color(0xFF21262D)
        : themeMode == 'glow'
            ? const Color(0xFF1E2A3A)
            : Colors.white.withOpacity(0.95);
    final cardElevation = themeMode == 'day' ? 4.0 : 0.0;

    // isDark for the dropdown: anything that isn't the bright day theme
    final isDark = themeMode != 'day';

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
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
                children: [
                  const SizedBox(height: 10),

                  // ── Theme Mode ──────────────────────────────────────────
                  _buildSectionHeader(localization.translate('theme_mode'), textColor),
                  Card(
                    elevation: cardElevation,
                    color: cardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
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
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  ),

                  const SizedBox(height: 20),

                  // ── Display Elements ────────────────────────────────────
                  _buildSectionHeader(localization.translate('display_elements'), textColor),
                  Card(
                    elevation: cardElevation,
                    color: cardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildSwitchListTile(
                          icon: Icons.cloud,
                          title: localization.translate('show_weather_info'),
                          subtitle: localization.translate('show_weather_info_subtitle'),
                          value: settings.showWeatherInfo,
                          onChanged: (value) => settings.setShowWeatherInfo(value),
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                        _buildSwitchListTile(
                          icon: Icons.grid_on,
                          title: localization.translate('show_coordinates'),
                          subtitle: localization.translate('show_coordinates_subtitle'),
                          value: settings.showCoordinates,
                          onChanged: (value) => settings.setShowCoordinates(value),
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                        _buildSwitchListTile(
                          icon: Icons.bubble_chart,
                          title: localization.translate('show_level_bubble'),
                          subtitle: localization.translate('show_level_bubble_subtitle'),
                          value: settings.showLevelBubble,
                          onChanged: (value) => settings.setShowLevelBubble(value),
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                        _buildSwitchListTile(
                          icon: Icons.explore,
                          title: localization.translate('show_heading_card'),
                          subtitle: localization.translate('show_heading_card_subtitle'),
                          value: settings.showHeadingCard,
                          onChanged: (value) => settings.setShowHeadingCard(value),
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                        _buildSwitchListTile(
                          icon: Icons.location_city,
                          title: localization.translate('show_location_text'),
                          subtitle: localization.translate('show_location_text_subtitle'),
                          value: settings.showLocationText,
                          onChanged: (value) => settings.setShowLocationText(value),
                          textColor: textColor,
                          iconColor: iconColor,
                        ),

                        const Divider(),

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
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                localization.translate('always_visible_cards'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: textColor.withOpacity(0.6),
                                ),
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
                            contentPadding: const EdgeInsets.only(left: 56, right: 16),
                          ),
                          _buildSwitchListTile(
                            title: localization.translate('altitude'),
                            subtitle: localization.translate('current_altitude_card'),
                            value: settings.showAltitude,
                            onChanged: (value) => settings.setShowAltitude(value),
                            textColor: textColor,
                            iconColor: iconColor,
                            contentPadding: const EdgeInsets.only(left: 56, right: 16),
                          ),
                          _buildSwitchListTile(
                            title: localization.translate('bearing'),
                            subtitle: localization.translate('current_altitude_card'),
                            value: settings.showBearing,
                            onChanged: (value) => settings.setShowBearing(value),
                            textColor: textColor,
                            iconColor: iconColor,
                            contentPadding: const EdgeInsets.only(left: 56, right: 16),
                          ),
                          _buildSwitchListTile(
                            title: localization.translate('location'),
                            subtitle: localization.translate('lat_long_coordinates_card'),
                            value: settings.showLocation,
                            onChanged: (value) => settings.setShowLocation(value),
                            textColor: textColor,
                            iconColor: iconColor,
                            contentPadding: const EdgeInsets.only(left: 56, right: 16),
                          ),
                          _buildSwitchListTile(
                            title: localization.translate('elevation'),
                            subtitle: localization.translate('height_above_sea_level_card'),
                            value: settings.showElevation,
                            onChanged: (value) => settings.setShowElevation(value),
                            textColor: textColor,
                            iconColor: iconColor,
                            contentPadding: const EdgeInsets.only(left: 56, right: 16),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Tools ───────────────────────────────────────────────
                  _buildSectionHeader(localization.translate('tools'), textColor),
                  Card(
                    elevation: cardElevation,
                    color: cardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildSwitchListTile(
                          icon: Icons.flashlight_on,
                          title: localization.translate('torch'),
                          subtitle: localization.translate('torch_subtitle'),
                          value: _isTorchOn,
                          onChanged: (value) => _toggleTorch(value),
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Compass Settings ────────────────────────────────────
                  _buildSectionHeader(localization.translate('compass_settings'), textColor),
                  Card(
                    elevation: cardElevation,
                    color: cardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.tune,
                          title: localization.translate('declination_adjustment'),
                          subtitle: '${localization.translate('declination_current')}: ${settings.magneticDeclination.toStringAsFixed(2)}°',
                          onTap: () => _showDeclinationDialog(context, settings, localization),
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Language ────────────────────────────────────────────
                  _buildSectionHeader(localization.translate('language'), textColor),
                  Card(
                    elevation: cardElevation,
                    color: cardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: _buildListTile(
                      icon: Icons.language,
                      title: localization.translate('language'),
                      subtitle: _getLanguageName(settings.language, localization),
                      onTap: () => _showLanguageSelector(context, settings, localization),
                      textColor: textColor,
                      iconColor: iconColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Units ───────────────────────────────────────────────
                  _buildSectionHeader(localization.translate('units'), textColor),
                  Card(
                    elevation: cardElevation,
                    color: cardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.thermostat,
                          title: localization.translate('temperature_unit_setting'),
                          subtitle: settings.temperatureUnit,
                          onTap: () => _showUnitPicker(context, settings, 'temperature', localization),
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Location Settings ───────────────────────────────────
                  _buildSectionHeader(localization.translate('location_settings'), textColor),
                  Card(
                    elevation: cardElevation,
                    color: cardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.gps_fixed,
                          title: localization.translate('gps_accuracy_setting'),
                          subtitle: settings.gpsAccuracy,
                          onTap: () => _showAccuracyPicker(context, settings, localization),
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Premium ─────────────────────────────────────────────
                  _buildSectionHeader(localization.translate('premium'), textColor),
                  Card(
                    elevation: cardElevation,
                    color: cardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: _buildListTile(
                      icon: Icons.workspace_premium,
                      title: premium.isPremium
                          ? localization.translate('pro_member')
                          : localization.translate('go_pro_remove_ads'),
                      subtitle: premium.isPremium
                          ? (premium.subscriptionType == 'yearly'
                              ? localization.translate('yearly_plan_active')
                              : localization.translate('monthly_plan_active'))
                          : localization.translate('go_pro_subtitle'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MembershipScreen(),
                          ),
                        );
                      },
                      textColor: textColor,
                      iconColor: premium.isPremium
                          ? const Color(0xFF00C853)
                          : const Color(0xFFFFB300),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Data & Privacy ──────────────────────────────────────
                  _buildSectionHeader(localization.translate('data_privacy'), textColor),
                  Card(
                    elevation: cardElevation,
                    color: cardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.storage,
                          title: localization.translate('clear_cache'),
                          subtitle: localization.translate('clear_cache_subtitle'),
                          onTap: () => _showClearCacheDialog(context, settings, localization),
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                        _buildListTile(
                          icon: Icons.privacy_tip,
                          title: localization.translate('privacy_policy'),
                          onTap: () async { final u = Uri.parse('https://YOUR-USERNAME.github.io/happyappsforyou-policies/compass-pro/'); if (!await launchUrl(u, mode: LaunchMode.externalApplication) && context.mounted) { Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())); } },
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Legal & Support ─────────────────────────────────────
                  _buildSectionHeader(localization.translate('legal_support'), textColor),
                  Card(
                    elevation: cardElevation,
                    color: cardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
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
                        _buildListTile(
                          icon: Icons.contact_support,
                          title: localization.translate('contact_report_bug'),
                          onTap: () => _composeEmail(context, localization),
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── More Apps ───────────────────────────────────────────
                  _buildSectionHeader('More Apps'.toUpperCase(), textColor),
                  Card(
                    elevation: cardElevation,
                    color: cardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    child: MyAppsDropdown(
                      currentAppId: AppId.compassPro,
                      isDark: isDark,
                      style: MyAppsDropdownStyle(
                        // Day: dark text on white card
                        textColorLight: Colors.black87,
                        subtleTextColorLight: Colors.black54,
                        cardColorLight: Colors.transparent,
                        borderColorLight: Colors.transparent,
                        // Glow/Night: light text on dark card
                        textColorDark: Colors.white,
                        subtleTextColorDark: Colors.white60,
                        cardColorDark: Colors.transparent,
                        borderColorDark: Colors.transparent,
                        // Accent follows the app's current icon colour
                        accentColor: iconColor,
                        borderRadius: 16,
                        titleWeight: FontWeight.w600,
                        titleFontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── About ───────────────────────────────────────────────
                  _buildSectionHeader(localization.translate('about'), textColor),
                  Card(
                    elevation: cardElevation,
                    color: cardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.info,
                          title: localization.translate('version'),
                          subtitle: '1.0.0',
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                        _buildListTile(
                          icon: Icons.share,
                          title: localization.translate('share_app'),
                          onTap: () => _shareApp(localization),
                          textColor: textColor,
                          iconColor: iconColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),

              // Back button
              Positioned(
                top: 10,
                left: 10,
                child: Material(
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
                        color: themeMode == 'day'
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeMode == 'day'
                              ? const Color(0xFF4A90E2)
                              : settings.getIconColor(opacity: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: themeMode == 'day'
                            ? const Color(0xFF4A90E2)
                            : settings.getIconColor(),
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

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor.withOpacity(0.6),
          letterSpacing: 1.2,
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
      leading: icon != null ? Icon(icon, color: iconColor, size: 24) : null,
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13))
          : null,
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: iconColor.withOpacity(0.5), size: 20)
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
      secondary: icon != null ? Icon(icon, color: iconColor, size: 24) : null,
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
    final backgroundColor = isSelected
        ? (themeMode == 'day' ? Colors.grey[200]! : Colors.black.withOpacity(0.5))
        : (themeMode == 'day' ? Colors.grey[100]! : Colors.black.withOpacity(0.2));
    final borderColor = isSelected
        ? color
        : (themeMode == 'day' ? Colors.grey[400]! : Colors.grey[700]!);
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: isSelected ? 3 : 2),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Icon(icon, color: color, size: 36),
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
