// my_apps_dropdown.dart
//
// Shared "More Apps" dropdown — identical copy lives in every app's
// lib/widgets/ folder. Do not edit per-app; styling is passed in via
// MyAppsDropdownStyle from each settings screen instead.
//
// Each app passes its own AppId as currentAppId so its own row is hidden
// from its own list. CV Builder Pro's settings screen is not edited, but
// it still appears inside every other app's dropdown (isLive: true).
//
// Romance Wheel, Precision Level, and Compass Pro don't have Play Store
// links yet — they're isLive: false below and render greyed out with a
// clock icon until a packageId is added.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

// ── App identifiers ───────────────────────────────────────────────────────────

enum AppId {
  unitConvertPro,
  soundMeterPro,
  cvBuilderPro,
  qrScannerBoss,
  romanceWheel,
  precisionLevel,
  compassPro,
}

// ── App registry (single source of truth for all 7 apps) ─────────────────────

class _AppEntry {
  final AppId id;
  final String title;
  final String iconAsset;
  final String? packageId;
  final bool isLive;

  const _AppEntry({
    required this.id,
    required this.title,
    required this.iconAsset,
    required this.packageId,
    required this.isLive,
  });

  String get playStoreUrl =>
      'https://play.google.com/store/apps/details?id=$packageId';
}

const List<_AppEntry> _allApps = [
  _AppEntry(
    id: AppId.unitConvertPro,
    title: 'Unit Convert Pro',
    iconAsset: 'assets/app_icons/unit_convert_pro.png',
    packageId: 'com.happyappsforyou.convertpro',
    isLive: true,
  ),
  _AppEntry(
    id: AppId.soundMeterPro,
    title: 'Sound Meter Pro',
    iconAsset: 'assets/app_icons/sound_meter_pro.png',
    packageId: 'com.happyappsforyou.soundmeterpro',
    isLive: true,
  ),
  _AppEntry(
    id: AppId.cvBuilderPro,
    title: 'Resume Builder - CV Maker',
    iconAsset: 'assets/app_icons/cv_builder_pro.png',
    packageId: 'com.cyberinc.cvbuilderpro',
    isLive: true,
  ),
  _AppEntry(
    id: AppId.qrScannerBoss,
    title: 'QR Code Scanner:Barcode Reader',
    iconAsset: 'assets/app_icons/qr_scanner_boss.png',
    packageId: 'com.bossproductions.qrscanboss',
    isLive: true,
  ),
  _AppEntry(
    id: AppId.romanceWheel,
    title: 'Romance Wheel',
    iconAsset: 'assets/app_icons/romance_wheel.png',
    packageId: null,
    isLive: false,
  ),
  _AppEntry(
    id: AppId.precisionLevel,
    title: 'Precision Level',
    iconAsset: 'assets/app_icons/precision_level.png',
    packageId: null,
    isLive: false,
  ),
  _AppEntry(
    id: AppId.compassPro,
    title: 'Compass Pro',
    iconAsset: 'assets/app_icons/compass_pro.png',
    packageId: null,
    isLive: false,
  ),
];

// ── Per-app visual styling (so the dropdown matches each app's UI) ───────────

class MyAppsDropdownStyle {
  final String? fontFamily;
  final Color textColorLight;
  final Color textColorDark;
  final Color subtleTextColorLight;
  final Color subtleTextColorDark;
  final Color cardColorLight;
  final Color cardColorDark;
  final Color borderColorLight;
  final Color borderColorDark;
  final Color accentColor;
  final double borderRadius;
  final FontWeight titleWeight;
  final double titleFontSize;

  const MyAppsDropdownStyle({
    this.fontFamily,
    this.textColorLight = const Color(0xFF1A1A1A),
    this.textColorDark = Colors.white,
    this.subtleTextColorLight = const Color(0x99000000),
    this.subtleTextColorDark = const Color(0x99FFFFFF),
    this.cardColorLight = Colors.white,
    this.cardColorDark = const Color(0xFF1A1A2E),
    this.borderColorLight = const Color(0x14000000),
    this.borderColorDark = const Color(0x1AFFFFFF),
    this.accentColor = const Color(0xFF2196F3),
    this.borderRadius = 16,
    this.titleWeight = FontWeight.w600,
    this.titleFontSize = 15,
  });
}

// ── The dropdown widget ────────────────────────────────────────────────────

class MyAppsDropdown extends StatefulWidget {
  final AppId currentAppId;
  final bool isDark;
  final MyAppsDropdownStyle style;

  const MyAppsDropdown({
    super.key,
    required this.currentAppId,
    required this.isDark,
    this.style = const MyAppsDropdownStyle(),
  });

  @override
  State<MyAppsDropdown> createState() => _MyAppsDropdownState();
}

class _MyAppsDropdownState extends State<MyAppsDropdown> {
  bool _expanded = false;

  List<_AppEntry> get _otherApps =>
      _allApps.where((a) => a.id != widget.currentAppId).toList();

  Future<void> _openPlayStore(_AppEntry app) async {
    if (!app.isLive || app.packageId == null) return;
    final uri = Uri.parse(app.playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareApp(_AppEntry app) {
    if (!app.isLive || app.packageId == null) return;
    Share.share(app.playStoreUrl, subject: app.title);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final isDark = widget.isDark;

    final textColor = isDark ? s.textColorDark : s.textColorLight;
    final subtleColor = isDark ? s.subtleTextColorDark : s.subtleTextColorLight;
    final cardColor = isDark ? s.cardColorDark : s.cardColorLight;
    final borderColor = isDark ? s.borderColorDark : s.borderColorLight;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(s.borderRadius),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.apps_rounded, color: s.accentColor, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'More Apps',
                      style: TextStyle(
                        fontFamily: s.fontFamily,
                        fontSize: s.titleFontSize,
                        fontWeight: s.titleWeight,
                        color: textColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: subtleColor),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(
                    children: [
                      Divider(height: 1, color: borderColor),
                      ..._otherApps.map((app) => _buildAppRow(
                            app,
                            textColor,
                            subtleColor,
                            borderColor,
                            s,
                          )),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildAppRow(
    _AppEntry app,
    Color textColor,
    Color subtleColor,
    Color borderColor,
    MyAppsDropdownStyle s,
  ) {
    final disabled = !app.isLive;

    return InkWell(
      onTap: disabled ? null : () => _openPlayStore(app),
      child: Opacity(
        opacity: disabled ? 0.4 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  app.iconAsset,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 36,
                    height: 36,
                    color: borderColor,
                    child: Icon(Icons.image_not_supported_outlined,
                        size: 16, color: subtleColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  app.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: s.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (!disabled)
                IconButton(
                  icon: Icon(Icons.share_outlined, size: 19, color: subtleColor),
                  onPressed: () => _shareApp(app),
                  splashRadius: 18,
                  visualDensity: VisualDensity.compact,
                )
              else
                Icon(Icons.schedule_rounded, size: 18, color: subtleColor),
            ],
          ),
        ),
      ),
    );
  }
}
