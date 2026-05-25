import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import '../models/saved_location.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../services/saved_locations_service.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';
import 'dart:math' as math;

class SavedLocationDetailScreen extends StatefulWidget {
  final SavedLocation location;

  const SavedLocationDetailScreen({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  State<SavedLocationDetailScreen> createState() =>
      _SavedLocationDetailScreenState();
}

class _SavedLocationDetailScreenState extends State<SavedLocationDetailScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;
  late String _locationName;
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey _screenshotKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _locationName = widget.location.name;
    _nameController.text = _locationName;
    _loadWeather();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isDay() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 20;
  }

  Future<void> _loadWeather() async {
    final data = await _weatherService.getWeatherForLocation(
      widget.location.latitude,
      widget.location.longitude,
    );
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoadingWeather = false;
      });
    }
  }

  Color _getBackgroundColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay ? const Color(0xFFE8F5F1) : const Color(0xFF000a08);
      case 'night':
        return isDay ? const Color(0xFFFFF5F5) : const Color(0xFF0a0000);
      default:
        return isDay ? const Color(0xFFE3F2FD) : const Color(0xFF1a2a3a);
    }
  }

  Color _getCardBackgroundColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay ? Colors.white : const Color(0xFF001510).withOpacity(0.8);
      case 'night':
        return isDay ? Colors.white : const Color(0xFF150000).withOpacity(0.8);
      default:
        return isDay ? Colors.white : const Color(0xFF2a3a4a).withOpacity(0.8);
    }
  }

  Color _getTextColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay ? const Color(0xFF004D3D) : const Color(0xFF00FFAA);
      case 'night':
        return isDay ? const Color(0xFF8B1A1A) : const Color(0xFFE57373);
      default:
        return isDay ? const Color(0xFF1A237E) : Colors.white;
    }
  }

  Color _getSecondaryTextColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00695C)
            : const Color(0xFF00FF88).withOpacity(0.7);
      case 'night':
        return isDay
            ? const Color(0xFFC62828)
            : const Color(0xFFF44336).withOpacity(0.7);
      default:
        return isDay ? const Color(0xFF424242) : Colors.white.withOpacity(0.7);
    }
  }

  Color _getAccentColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay ? const Color(0xFF00BFA5) : const Color(0xFF00FFAA);
      case 'night':
        return isDay ? const Color(0xFFD32F2F) : const Color(0xFFE57373);
      default:
        return isDay ? const Color(0xFF2196F3) : const Color(0xFF4A90E2);
    }
  }

  Color _getOverlayColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00BFA5).withOpacity(0.1)
            : const Color(0xFF00FF88).withOpacity(0.15);
      case 'night':
        return isDay
            ? const Color(0xFFE57373).withOpacity(0.1)
            : const Color(0xFFF44336).withOpacity(0.15);
      default:
        return isDay
            ? const Color(0xFF2196F3).withOpacity(0.08)
            : Colors.white.withOpacity(0.1);
    }
  }

  void _showEditNameDialog() {
    final settings = Provider.of<SettingsService>(context, listen: false);
    final translations = Provider.of<TranslationService>(context, listen: false);
    final savedLocationsService =
        Provider.of<SavedLocationsService>(context, listen: false);
    final iconThemeMode = settings.iconThemeMode ?? 'default';
    final isDay = _isDay();
    final cardBgColor = _getCardBackgroundColor(iconThemeMode, isDay);
    final textColor = _getTextColor(iconThemeMode, isDay);
    final accentColor = _getAccentColor(iconThemeMode, isDay);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withOpacity(0.2),
                    accentColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.edit_rounded, color: accentColor, size: 24),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                translations.translate('edit_location_name'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          style: TextStyle(color: textColor),
          maxLength: 40,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          buildCounter: (context,
                  {required currentLength,
                  required isFocused,
                  maxLength}) =>
              null,
          decoration: InputDecoration(
            labelText: translations.translate('location_name'),
            labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: textColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: textColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              translations.translate('cancel'),
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final newName = _nameController.text.trim();
              if (newName.isEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(translations
                            .translate('location_name_empty_error')),
                      ],
                    ),
                    backgroundColor: const Color(0xFFB71C1C),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                return;
              }

              final updatedLocation = SavedLocation(
                id: widget.location.id,
                name: newName,
                latitude: widget.location.latitude,
                longitude: widget.location.longitude,
                altitude: widget.location.altitude,
                accuracy: widget.location.accuracy,
                timestamp: widget.location.timestamp,
                address: widget.location.address,
                notes: widget.location.notes,
                category: widget.location.category,
              );

              await savedLocationsService.updateLocation(updatedLocation);

              setState(() {
                _locationName = newName;
              });

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: textColor),
                        const SizedBox(width: 12),
                        Text(
                          translations.translate('location_name_updated'),
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                    backgroundColor: cardBgColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: Text(
              translations.translate('save'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final settings = Provider.of<SettingsService>(context, listen: false);
    final translations =
        Provider.of<TranslationService>(context, listen: false);
    final iconThemeMode = settings.iconThemeMode ?? 'default';
    final isDay = _isDay();
    final cardBgColor = _getCardBackgroundColor(iconThemeMode, isDay);
    final textColor = _getTextColor(iconThemeMode, isDay);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB71C1C).withOpacity(0.2),
                    const Color(0xFFB71C1C).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_rounded,
                  color: Color(0xFFB71C1C), size: 24),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                translations.translate('delete_location'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '${translations.translate('delete_location_confirmation')} "$_locationName"? ${translations.translate('delete_action_cannot_undone')}',
          style: TextStyle(
            height: 1.5,
            fontSize: 15,
            color: textColor.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              translations.translate('cancel'),
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final savedLocationsService =
                  Provider.of<SavedLocationsService>(context, listen: false);
              await savedLocationsService.deleteLocation(widget.location.id);

              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                            '$_locationName ${translations.translate('deleted')}'),
                      ],
                    ),
                    backgroundColor: const Color(0xFFB71C1C),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: Text(
              translations.translate('delete'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final translations = Provider.of<TranslationService>(context);
    final iconThemeMode = settings.iconThemeMode ?? 'default';
    final isDay = _isDay();

    final bgColor = _getBackgroundColor(iconThemeMode, isDay);
    final cardBgColor = _getCardBackgroundColor(iconThemeMode, isDay);
    final textColor = _getTextColor(iconThemeMode, isDay);
    final secondaryTextColor = _getSecondaryTextColor(iconThemeMode, isDay);
    final accentColor = _getAccentColor(iconThemeMode, isDay);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: RepaintBoundary(
                key: _screenshotKey,
                child: Container(
                  color: bgColor,
                  child: Column(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 60),
                          // Avatar Icon
                          Hero(
                            tag: 'location_icon_${widget.location.id}',
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getCategoryColor(
                                        widget.location.category ?? 'Other',
                                        iconThemeMode),
                                    _getCategoryColor(
                                            widget.location.category ?? 'Other',
                                            iconThemeMode)
                                        .withOpacity(0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDay
                                      ? accentColor.withOpacity(0.2)
                                      : accentColor.withOpacity(0.3),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getCategoryColor(
                                            widget.location.category ?? 'Other',
                                            iconThemeMode)
                                        .withOpacity(isDay ? 0.25 : 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getCategoryIcon(widget.location.category),
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Location Name
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _locationName,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                                height: 1.2,
                                color: textColor,
                                shadows: iconThemeMode != 'default' && !isDay
                                    ? [
                                        Shadow(
                                          color: textColor.withOpacity(0.5),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Weather Badge
                          if (_weatherData != null)
                            _buildWeatherBadge(
                                iconThemeMode, isDay, accentColor),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),

                                // Weather Card
                                if (_weatherData != null) ...[
                                  _buildWeatherCard(
                                      iconThemeMode,
                                      isDay,
                                      cardBgColor,
                                      textColor,
                                      secondaryTextColor,
                                      accentColor,
                                      translations),
                                  const SizedBox(height: 24),
                                ],

                                // Location Information
                                _buildSectionHeader(
                                    translations.translate('location_details'),
                                    textColor),
                                const SizedBox(height: 12),
                                _buildInfoCard(
                                  iconThemeMode,
                                  isDay,
                                  cardBgColor,
                                  textColor,
                                  secondaryTextColor,
                                  accentColor,
                                  [
                                    _buildInfoRow(
                                      Icons.my_location_rounded,
                                      translations.translate('coordinates'),
                                      '${widget.location.latitude.toStringAsFixed(6)}, ${widget.location.longitude.toStringAsFixed(6)}',
                                      accentColor,
                                      textColor,
                                      secondaryTextColor,
                                      onTap: () => _copyCoordinates(
                                          cardBgColor, textColor),
                                    ),
                                    if (widget.location.address != null)
                                      _buildInfoRow(
                                        Icons.location_on_rounded,
                                        translations.translate('address'),
                                        widget.location.address!,
                                        accentColor,
                                        textColor,
                                        secondaryTextColor,
                                        onTap: () => _copyAddress(cardBgColor,
                                            textColor, translations),
                                      ),
                                    if (widget.location.altitude != null)
                                      _buildInfoRow(
                                        Icons.terrain_rounded,
                                        translations.translate('altitude'),
                                        '${widget.location.altitude!.toStringAsFixed(1)} ${translations.translate('m')}',
                                        accentColor,
                                        textColor,
                                        secondaryTextColor,
                                      ),
                                    if (widget.location.accuracy != null)
                                      _buildInfoRow(
                                        Icons.gps_fixed_rounded,
                                        translations.translate('accuracy'),
                                        '${translations.translate('plus_minus')}${widget.location.accuracy!.toStringAsFixed(1)} ${translations.translate('m')}',
                                        accentColor,
                                        textColor,
                                        secondaryTextColor,
                                      ),
                                    _buildInfoRow(
                                      Icons.access_time_rounded,
                                      translations.translate('saved'),
                                      DateFormat('MMM dd, yyyy • HH:mm')
                                          .format(widget.location.timestamp),
                                      accentColor,
                                      textColor,
                                      secondaryTextColor,
                                    ),
                                    if (widget.location.category != null)
                                      _buildInfoRow(
                                        Icons.category_rounded,
                                        translations.translate('category'),
                                        translations.translate(widget
                                            .location.category!
                                            .toLowerCase()
                                            .replaceAll(' ', '_')),
                                        accentColor,
                                        textColor,
                                        secondaryTextColor,
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Notes
                                if (widget.location.notes != null &&
                                    widget.location.notes!.isNotEmpty) ...[
                                  _buildSectionHeader(
                                      translations.translate('notes'),
                                      textColor),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          accentColor.withOpacity(0.15),
                                          accentColor.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isDay
                                            ? accentColor.withOpacity(0.2)
                                            : accentColor.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                accentColor.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.note_rounded,
                                            color: accentColor,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            widget.location.notes!,
                                            style: TextStyle(
                                              fontSize: 15,
                                              height: 1.6,
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],

                                // Coordinate Formats
                                _buildSectionHeader(
                                    translations
                                        .translate('coordinate_formats'),
                                    textColor),
                                const SizedBox(height: 12),
                                _buildInfoCard(
                                  iconThemeMode,
                                  isDay,
                                  cardBgColor,
                                  textColor,
                                  secondaryTextColor,
                                  accentColor,
                                  [
                                    _buildInfoRow(
                                      Icons.pin_drop_rounded,
                                      translations
                                          .translate('decimal_degrees'),
                                      '${widget.location.latitude.toStringAsFixed(6)}, ${widget.location.longitude.toStringAsFixed(6)}',
                                      accentColor,
                                      textColor,
                                      secondaryTextColor,
                                      onTap: () => _copyCoordinates(
                                          cardBgColor, textColor, 'decimal',
                                          translations),
                                    ),
                                    _buildInfoRow(
                                      Icons.format_list_numbered_rounded,
                                      translations.translate('dms_format'),
                                      _toDMS(widget.location.latitude,
                                          widget.location.longitude),
                                      accentColor,
                                      textColor,
                                      secondaryTextColor,
                                      onTap: () => _copyCoordinates(
                                          cardBgColor, textColor, 'dms',
                                          translations),
                                    ),
                                    _buildInfoRow(
                                      Icons.link_rounded,
                                      translations
                                          .translate('google_maps_url'),
                                      'maps.google.com/?q=${widget.location.latitude},${widget.location.longitude}',
                                      accentColor,
                                      textColor,
                                      secondaryTextColor,
                                      onTap: () => _copyCoordinates(
                                          cardBgColor, textColor, 'link',
                                          translations),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 10,
              left: 10,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDay
                          ? Colors.white.withOpacity(0.95)
                          : Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDay
                            ? accentColor.withOpacity(0.15)
                            : accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(isDay ? 0.08 : 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.arrow_back, color: textColor, size: 24),
                  ),
                ),
              ),
            ),

            // Menu button
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.transparent,
                child: PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDay
                          ? Colors.white.withOpacity(0.95)
                          : Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDay
                            ? accentColor.withOpacity(0.15)
                            : accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(isDay ? 0.08 : 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.more_vert_rounded,
                        color: textColor, size: 24),
                  ),
                  color: cardBgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 12,
                  offset: const Offset(0, 10),
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded,
                              size: 20, color: accentColor),
                          const SizedBox(width: 12),
                          Text(
                            translations.translate('edit_name'),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: textColor),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_rounded,
                              color: Color(0xFFB71C1C), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            translations.translate('delete'),
                            style: const TextStyle(
                                color: Color(0xFFB71C1C),
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditNameDialog();
                    } else if (value == 'delete') {
                      _showDeleteDialog();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Action Buttons
      bottomNavigationBar: Builder(
        builder: (context) {
          final settings = Provider.of<SettingsService>(context);
          final translations = Provider.of<TranslationService>(context);
          final iconThemeMode = settings.iconThemeMode ?? 'default';
          final isDay = _isDay();
          final cardBgColor = _getCardBackgroundColor(iconThemeMode, isDay);
          final textColor = _getTextColor(iconThemeMode, isDay);
          final accentColor = _getAccentColor(iconThemeMode, isDay);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              border: Border(
                top: BorderSide(
                  color: isDay
                      ? accentColor.withOpacity(0.15)
                      : accentColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDay ? 0.08 : 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: _buildBottomButton(
                      icon: Icons.share_rounded,
                      label: translations.translate('share'),
                      color: accentColor,
                      onPressed: () => _shareLocation(
                          cardBgColor, textColor, translations),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBottomButton(
                      icon: Icons.download_rounded,
                      label: translations.translate('download'),
                      color: _getCategoryColor(
                          widget.location.category ?? 'Other', iconThemeMode),
                      onPressed: () => _downloadLocation(
                          cardBgColor, textColor, translations),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 4,
        shadowColor: color.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherBadge(
      String iconThemeMode, bool isDay, Color accentColor) {
    final translations =
        Provider.of<TranslationService>(context, listen: false);
    final current = _weatherData!['current'];
    final temp = (current['temperature_2m'] as num).round();
    final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.2),
            accentColor.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDay
              ? accentColor.withOpacity(0.3)
              : accentColor.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: iconThemeMode != 'default' && !isDay
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDay ? 0.08 : 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _weatherService.getWeatherEmoji(weatherCode),
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 10),
          Text(
            '$temp${translations.translate('celsius')}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: accentColor,
              letterSpacing: 0.3,
              shadows: iconThemeMode != 'default' && !isDay
                  ? [
                      Shadow(
                        color: accentColor.withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(
    String iconThemeMode,
    bool isDay,
    Color cardBgColor,
    Color textColor,
    Color secondaryTextColor,
    Color accentColor,
    TranslationService translations,
  ) {
    final current = _weatherData!['current'];
    final temp = (current['temperature_2m'] as num).round();
    final humidity = (current['relative_humidity_2m'] as num?)?.round() ?? 0;
    final windSpeed = (current['wind_speed_10m'] as num?)?.round() ?? 0;
    final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDay
              ? accentColor.withOpacity(0.2)
              : accentColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: iconThemeMode != 'default' && !isDay
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDay ? 0.08 : 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.cloud_rounded, color: accentColor, size: 26),
              ),
              const SizedBox(width: 12),
              Text(
                translations.translate('weather_at_location'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherStat(
                _weatherService.getWeatherEmoji(weatherCode),
                '$temp${translations.translate('celsius')}',
                translations.translate('temperature'),
                textColor,
                secondaryTextColor,
              ),
              Container(
                width: 2,
                height: 50,
                color: accentColor.withOpacity(0.2),
              ),
              _buildWeatherStat(
                '💧',
                '$humidity%',
                translations.translate('humidity'),
                textColor,
                secondaryTextColor,
              ),
              Container(
                width: 2,
                height: 50,
                color: accentColor.withOpacity(0.2),
              ),
              _buildWeatherStat(
                '💨',
                '$windSpeed ${translations.translate('km_h')}',
                translations.translate('wind'),
                textColor,
                secondaryTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(String emoji, String value, String label,
      Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: secondaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: textColor,
      ),
    );
  }

  Widget _buildInfoCard(
    String iconThemeMode,
    bool isDay,
    Color cardBgColor,
    Color textColor,
    Color secondaryTextColor,
    Color accentColor,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDay
              ? accentColor.withOpacity(0.15)
              : accentColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDay ? 0.05 : 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color accentColor,
    Color textColor,
    Color secondaryTextColor, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withOpacity(0.2),
                    accentColor.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(Icons.copy_rounded, size: 18, color: accentColor),
              ),
          ],
        ),
      ),
    );
  }

  void _copyAddress(Color bgColor, Color textColor,
      TranslationService translations) {
    if (widget.location.address != null) {
      Clipboard.setData(ClipboardData(text: widget.location.address!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: textColor),
              const SizedBox(width: 12),
              Text(
                translations.translate('copied_to_clipboard'),
                style: TextStyle(color: textColor),
              ),
            ],
          ),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _copyCoordinates(Color bgColor, Color textColor,
      [String format = 'decimal', TranslationService? translations]) {
    final trans = translations ??
        Provider.of<TranslationService>(context, listen: false);
    String text;
    switch (format) {
      case 'dms':
        text = _toDMS(widget.location.latitude, widget.location.longitude);
        break;
      case 'link':
        text =
            'https://maps.google.com/?q=${widget.location.latitude},${widget.location.longitude}';
        break;
      default:
        text =
            '${widget.location.latitude.toStringAsFixed(6)}, ${widget.location.longitude.toStringAsFixed(6)}';
    }

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: textColor),
            const SizedBox(width: 12),
            Text(
              trans.translate('copied_to_clipboard'),
              style: TextStyle(color: textColor),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Captures the full scrollable content by temporarily expanding it.
  Future<Uint8List?> _captureFullScreenshot() async {
    try {
      // Scroll to top first so the boundary starts rendering from the top
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      await Future.delayed(const Duration(milliseconds: 400));

      RenderRepaintBoundary boundary = _screenshotKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing screenshot: $e');
      return null;
    }
  }

  /// Share — uses share sheet so the user can send it anywhere.
  Future<void> _shareLocation(Color bgColor, Color textColor,
      TranslationService translations) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                translations.translate('preparing_to_share'),
                style: TextStyle(color: textColor),
              ),
            ],
          ),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );

      final imageBytes = await _captureFullScreenshot();

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final timestamp =
            DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final imagePath =
            '${directory.path}/${_locationName.replaceAll(' ', '_')}_${timestamp}_location.png';

        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);

        if (await imageFile.exists()) {
          await Share.shareXFiles(
            [XFile(imagePath)],
            text:
                '$_locationName\n${translations.translate('location_share_coordinates')} ${widget.location.latitude.toStringAsFixed(6)}, ${widget.location.longitude.toStringAsFixed(6)}\n${translations.translate('location_share_google_maps')} https://maps.google.com/?q=${widget.location.latitude},${widget.location.longitude}',
            subject:
                '${translations.translate('location_prefix')} $_locationName',
          );

          Future.delayed(const Duration(seconds: 5), () {
            try {
              if (imageFile.existsSync()) imageFile.deleteSync();
            } catch (_) {}
          });
        } else {
          throw Exception('Failed to create screenshot file');
        }
      } else {
        await Share.share(
          '$_locationName\n${translations.translate('location_share_coordinates')} ${widget.location.latitude.toStringAsFixed(6)}, ${widget.location.longitude.toStringAsFixed(6)}\n${translations.translate('location_share_google_maps')} https://maps.google.com/?q=${widget.location.latitude},${widget.location.longitude}',
          subject:
              '${translations.translate('location_prefix')} $_locationName',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                        '${translations.translate('error_sharing')} ${e.toString()}')),
              ],
            ),
            backgroundColor: const Color(0xFFB71C1C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  /// Download — saves the PNG directly to the device's Downloads folder.
  Future<void> _downloadLocation(Color bgColor, Color textColor,
      TranslationService translations) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                translations.translate('preparing_download'),
                style: TextStyle(color: textColor),
              ),
            ],
          ),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );

      final imageBytes = await _captureFullScreenshot();

      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(translations.translate('failed_to_capture_screenshot')),
                ],
              ),
              backgroundColor: const Color(0xFFB71C1C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName =
          '${_locationName.replaceAll(' ', '_')}_$timestamp.png';

      // Save directly to the Downloads folder on Android;
      // fall back to app documents directory on iOS.
      Directory? saveDir;
      if (Platform.isAndroid) {
        saveDir = Directory('/storage/emulated/0/Download');
        if (!await saveDir.exists()) {
          saveDir = await getExternalStorageDirectory();
        }
      } else {
        saveDir = await getApplicationDocumentsDirectory();
      }

      if (saveDir == null) {
        throw Exception('Could not access storage directory');
      }

      final filePath = '${saveDir.path}/$fileName';
      final imageFile = File(filePath);
      await imageFile.writeAsBytes(imageBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.download_done_rounded, color: textColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${translations.translate('saved_to')} $fileName',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
              ],
            ),
            backgroundColor: bgColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                        '${translations.translate('error_downloading')} ${e.toString()}')),
              ],
            ),
            backgroundColor: const Color(0xFFB71C1C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _calculateBearing(
      double lat1, double lon1, double lat2, double lon2) {
    final dLon = _toRadians(lon2 - lon1);
    final y = math.sin(dLon) * math.cos(_toRadians(lat2));
    final x = math.cos(_toRadians(lat1)) * math.sin(_toRadians(lat2)) -
        math.sin(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.cos(dLon);
    final bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);

  String _toDMS(double lat, double lon) {
    final latDMS = _convertToDMS(lat, true);
    final lonDMS = _convertToDMS(lon, false);
    return '$latDMS, $lonDMS';
  }

  String _convertToDMS(double decimal, bool isLatitude) {
    final direction =
        isLatitude ? (decimal >= 0 ? 'N' : 'S') : (decimal >= 0 ? 'E' : 'W');
    final absolute = decimal.abs();
    final degrees = absolute.floor();
    final minutesDecimal = (absolute - degrees) * 60;
    final minutes = minutesDecimal.floor();
    final seconds = (minutesDecimal - minutes) * 60;
    return '$degrees°$minutes\'${seconds.toStringAsFixed(2)}"$direction';
  }

  Color _getCategoryColor(String category, String iconThemeMode) {
    if (iconThemeMode == 'glow') {
      switch (category) {
        case 'Home': return const Color(0xFF00FFAA);
        case 'Work': return const Color(0xFF00FF88);
        case 'Favorite': return const Color(0xFF00DD88);
        case 'Restaurant': return const Color(0xFF00BBAA);
        case 'Shopping': return const Color(0xFF00AACC);
        case 'Gas Station': return const Color(0xFF00CCAA);
        case 'Parking': return const Color(0xFF00DDBB);
        case 'Hotel': return const Color(0xFF00EEBB);
        case 'Hospital': return const Color(0xFF00FFBB);
        case 'School': return const Color(0xFF00EEAA);
        default: return const Color(0xFF00DDAA);
      }
    } else if (iconThemeMode == 'night') {
      switch (category) {
        case 'Home': return const Color(0xFFC62828);
        case 'Work': return const Color(0xFFD32F2F);
        case 'Favorite': return const Color(0xFFD32F2F);
        case 'Restaurant': return const Color(0xFFE53935);
        case 'Shopping': return const Color(0xFFF44336);
        case 'Gas Station': return const Color(0xFFF44336);
        case 'Parking': return const Color(0xFFEF5350);
        case 'Hotel': return const Color(0xFFEF5350);
        case 'Hospital': return const Color(0xFFD32F2F);
        case 'School': return const Color(0xFFFF7043);
        default: return const Color(0xFFE53935);
      }
    } else {
      switch (category) {
        case 'Home': return const Color(0xFF5C6BC0);
        case 'Work': return const Color(0xFFFF9800);
        case 'Favorite': return const Color(0xFFE91E63);
        case 'Restaurant': return const Color(0xFFFF5722);
        case 'Shopping': return const Color(0xFF9C27B0);
        case 'Gas Station': return const Color(0xFF4CAF50);
        case 'Parking': return const Color(0xFF3F51B5);
        case 'Hotel': return const Color(0xFF00BCD4);
        case 'Hospital': return const Color(0xFFD81B60);
        case 'School': return const Color(0xFFFFC107);
        default: return const Color(0xFF009688);
      }
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Home': return Icons.home;
      case 'Work': return Icons.work;
      case 'Favorite': return Icons.favorite;
      case 'Restaurant': return Icons.restaurant;
      case 'Shopping': return Icons.shopping_bag;
      case 'Gas Station': return Icons.local_gas_station;
      case 'Parking': return Icons.local_parking;
      case 'Hotel': return Icons.hotel;
      case 'Hospital': return Icons.local_hospital;
      case 'School': return Icons.school;
      default: return Icons.place;
    }
  }
}