import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/saved_locations_service.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';
import '../models/saved_location.dart';
import '../utils/unit_converter_helper.dart';
import 'saved_location_detail_screen.dart';
import 'dart:math' as math;

class SavedLocationsScreen extends StatefulWidget {
  final VoidCallback? onBackToCompass;
  
  const SavedLocationsScreen({Key? key, this.onBackToCompass}) : super(key: key);

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  String _selectedCategory = 'All';
  
  List<Map<String, dynamic>> _getCategories() {
    return [
      {'name': LocalizationService.translate('all'), 'key': 'All', 'icon': Icons.grid_view},
      // 'Tracking' removed — tracking locations are hidden from this screen
      {'name': LocalizationService.translate('home'), 'key': 'Home', 'icon': Icons.home},
      {'name': LocalizationService.translate('work'), 'key': 'Work', 'icon': Icons.work},
      {'name': LocalizationService.translate('favorite'), 'key': 'Favorite', 'icon': Icons.favorite},
      {'name': LocalizationService.translate('restaurant'), 'key': 'Restaurant', 'icon': Icons.restaurant},
      {'name': LocalizationService.translate('shopping'), 'key': 'Shopping', 'icon': Icons.shopping_bag},
      {'name': LocalizationService.translate('gas_station'), 'key': 'Gas Station', 'icon': Icons.local_gas_station},
      {'name': LocalizationService.translate('parking'), 'key': 'Parking', 'icon': Icons.local_parking},
      {'name': LocalizationService.translate('hotel'), 'key': 'Hotel', 'icon': Icons.hotel},
      {'name': LocalizationService.translate('hospital'), 'key': 'Hospital', 'icon': Icons.local_hospital},
      {'name': LocalizationService.translate('school'), 'key': 'School', 'icon': Icons.school},
      {'name': LocalizationService.translate('other'), 'key': 'Other', 'icon': Icons.place},
    ];
  }

  @override
  void initState() {
    super.initState();
    // Set initial selected category to 'All' (English key)
    _selectedCategory = 'All';
  }

  bool _isDay() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 20;
  }

  List<Color> _getGradientColors(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? [
                const Color(0xFFE8F5F1),
                const Color(0xFFF0F9F6),
                const Color(0xFFF5FCFA),
              ]
            : [
                const Color(0xFF000a08),
                const Color(0xFF001510),
                const Color(0xFF002018),
              ];
      case 'night':
        return isDay
            ? [
                const Color(0xFFFFF5F5),
                const Color(0xFFFFEBEE),
                const Color(0xFFFCE4EC),
              ]
            : [
                const Color(0xFF0a0000),
                const Color(0xFF150000),
                const Color(0xFF200000),
              ];
      default:
        return isDay
            ? [
                const Color(0xFFE3F2FD),
                const Color(0xFFEEF5FC),
                const Color(0xFFF5F9FD),
              ]
            : [
                const Color(0xFF1a2a3a),
                const Color(0xFF2a3a4a),
                const Color(0xFF3a4a5a),
              ];
    }
  }

  Color _getTextColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF004D3D)
            : const Color(0xFF00FFAA);
      case 'night':
        return isDay
            ? const Color(0xFF8B1A1A)
            : const Color(0xFFE57373);
      default:
        return isDay
            ? const Color(0xFF1A237E)
            : Colors.white;
    }
  }

  Color _getSecondaryTextColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00695C)
            : const Color(0xFF00FF88).withOpacity(0.8);
      case 'night':
        return isDay
            ? const Color(0xFFC62828)
            : const Color(0xFFF44336).withOpacity(0.8);
      default:
        return isDay
            ? const Color(0xFF424242)
            : Colors.white.withOpacity(0.8);
    }
  }

  Color _getCardBackgroundColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? Colors.white
            : const Color(0xFF001510).withOpacity(0.6);
      case 'night':
        return isDay
            ? Colors.white
            : const Color(0xFF150000).withOpacity(0.6);
      default:
        return isDay
            ? Colors.white
            : const Color(0xFF2a3a4a).withOpacity(0.6);
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
            : Colors.white.withOpacity(0.15);
    }
  }

  String _getDistanceUnitAbbreviation(String unit) {
    if (unit == LocalizationService.translate('meters')) {
      return LocalizationService.translate('m');
    } else if (unit == LocalizationService.translate('feet')) {
      return LocalizationService.translate('ft');
    } else if (unit == LocalizationService.translate('kilometers')) {
      return LocalizationService.translate('km');
    } else if (unit == LocalizationService.translate('miles')) {
      return LocalizationService.translate('mi');
    } else {
      return LocalizationService.translate('km');
    }
  }

  // Get the translated display name for a category key
  String _getTranslatedCategoryName(String categoryKey) {
    final keyToTranslationMap = {
      'All': 'all',
      'Home': 'home',
      'Work': 'work',
      'Favorite': 'favorite',
      'Restaurant': 'restaurant',
      'Shopping': 'shopping',
      'Gas Station': 'gas_station',
      'Parking': 'parking',
      'Hotel': 'hotel',
      'Hospital': 'hospital',
      'School': 'school',
      'Other': 'other',
    };
    final translationKey = keyToTranslationMap[categoryKey] ?? 'other';
    return LocalizationService.translate(translationKey);
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    final savedLocationsService = Provider.of<SavedLocationsService>(context);
    final settings = Provider.of<SettingsService>(context);
    final iconThemeMode = settings.iconThemeMode ?? 'default';
    final isDay = _isDay();
    final categories = _getCategories();
    
    // Get locations filtered by category key (not translated name)
    // Always exclude 'Tracking' locations — they are managed on the tracking screen
    var locations = _selectedCategory == 'All'
        ? savedLocationsService.locations.where((l) => l.category != 'Tracking').toList()
        : savedLocationsService.getLocationsByCategory(_selectedCategory);
    
    // SORTING: Show latest saved locations first (most recent at top)
    locations = List<SavedLocation>.from(locations)
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    
    // LIMIT: Maximum 30 locations displayed to maintain performance
    if (locations.length > 30) {
      locations = locations.sublist(0, 30);
    }

    final gradientColors = _getGradientColors(iconThemeMode, isDay);
    final textColor = _getTextColor(iconThemeMode, isDay);
    final secondaryTextColor = _getSecondaryTextColor(iconThemeMode, isDay);
    final overlayColor = _getOverlayColor(iconThemeMode, isDay);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Professional Header
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        overlayColor.withOpacity(0.3),
                        overlayColor.withOpacity(0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDay 
                            ? Colors.black.withOpacity(0.08)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top Bar with Title and Actions
                      Padding(
                        padding: const EdgeInsets.fromLTRB(60, 20, 60, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LocalizationService.translate('saved_locations'),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: textColor,
                                      letterSpacing: -1.2,
                                      height: 1.1,
                                      shadows: iconThemeMode != 'default' && !isDay ? [
                                        Shadow(
                                          color: textColor.withOpacity(0.5),
                                          blurRadius: 8,
                                        ),
                                      ] : null,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: overlayColor.withOpacity(isDay ? 0.5 : 0.3),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDay 
                                            ? textColor.withOpacity(0.2)
                                            : textColor.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.bookmark_rounded,
                                          size: 16,
                                          color: secondaryTextColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${locations.length} ${locations.length == 1 ? LocalizationService.translate('location_singular') : LocalizationService.translate('locations_plural')}',
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: overlayColor.withOpacity(isDay ? 0.5 : 0.3),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDay 
                                      ? textColor.withOpacity(0.2)
                                      : textColor.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: iconThemeMode != 'default' && !isDay ? [
                                  BoxShadow(
                                    color: textColor.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDay ? 0.08 : 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.info_outline, color: textColor, size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              LocalizationService.translate('use_location_screen_to_save'),
                                              style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: gradientColors[0],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.add_location_alt_rounded,
                                  color: textColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Category Filter Section
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 0, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12, left: 4),
                              child: Text(
                                LocalizationService.translate('filter_by_category'),
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 52,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(right: 16),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  final categoryKey = category['key'] as String;
                                  final categoryName = category['name'] as String;
                                  final isSelected = categoryKey == _selectedCategory;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedCategory = categoryKey;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          curve: Curves.easeOutCubic,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            gradient: isSelected
                                                ? LinearGradient(
                                                    colors: [
                                                      _getCategoryColor(categoryKey, iconThemeMode),
                                                      _getCategoryColor(categoryKey, iconThemeMode).withOpacity(0.8),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : null,
                                            color: isSelected 
                                                ? null 
                                                : (isDay 
                                                    ? Colors.white.withOpacity(0.9)
                                                    : overlayColor.withOpacity(0.2)),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isSelected 
                                                  ? _getCategoryColor(categoryKey, iconThemeMode).withOpacity(0.5)
                                                  : (isDay 
                                                      ? textColor.withOpacity(0.15)
                                                      : textColor.withOpacity(0.2)),
                                              width: isSelected ? 2 : 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isSelected
                                                    ? _getCategoryColor(categoryKey, iconThemeMode).withOpacity(0.4)
                                                    : Colors.black.withOpacity(isDay ? 0.05 : 0.2),
                                                blurRadius: isSelected ? 12 : 6,
                                                offset: Offset(0, isSelected ? 4 : 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: isSelected 
                                                      ? Colors.white.withOpacity(0.25)
                                                      : _getCategoryColor(categoryKey, iconThemeMode).withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  category['icon'] as IconData,
                                                  size: 18,
                                                  color: isSelected 
                                                      ? Colors.white
                                                      : _getCategoryColor(categoryKey, iconThemeMode),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                categoryName,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                                  letterSpacing: 0.2,
                                                  color: isSelected 
                                                      ? Colors.white 
                                                      : textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Locations List
                Expanded(
                  child: locations.isEmpty
                      ? _buildEmptyState(iconThemeMode, isDay, textColor, secondaryTextColor, overlayColor, gradientColors)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const BouncingScrollPhysics(),
                          itemCount: locations.length,
                          itemBuilder: (context, index) {
                            return _buildLocationCard(
                              locations[index],
                              locationService,
                              savedLocationsService,
                              settings,
                              index,
                              iconThemeMode,
                              isDay,
                            );
                          },
                        ),
                ),
              ],
            ),
            
            // Back button
            if (widget.onBackToCompass != null)
              Positioned(
                top: 10,
                left: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onBackToCompass,
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
                              ? textColor.withOpacity(0.15)
                              : textColor.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDay ? 0.08 : 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: textColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String iconThemeMode, bool isDay, Color textColor, Color secondaryTextColor, Color overlayColor, List<Color> gradientColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDay 
                  ? Colors.white
                  : overlayColor.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDay 
                    ? textColor.withOpacity(0.15)
                    : textColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: iconThemeMode != 'default' && !isDay ? [
                BoxShadow(
                  color: textColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ] : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDay ? 0.08 : 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              _selectedCategory == 'All' 
                  ? Icons.location_off
                  : _getCategoryIcon(_selectedCategory),
              size: 80,
              color: textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedCategory == 'All' 
                ? LocalizationService.translate('no_saved_locations')
                : '${LocalizationService.translate('no')} ${_getTranslatedCategoryName(_selectedCategory)} ${LocalizationService.translate('locations_plural')}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: -0.5,
              shadows: iconThemeMode != 'default' && !isDay ? [
                Shadow(
                  color: textColor.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ] : null,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _selectedCategory == 'All'
                  ? LocalizationService.translate('save_favorite_places_hint')
                  : LocalizationService.translate('no_locations_in_category'),
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    LocalizationService.translate('use_location_screen_to_save'),
                    style: TextStyle(color: textColor),
                  ),
                  backgroundColor: gradientColors[0],
                ),
              );
            },
            icon: Icon(Icons.add_location_alt, color: gradientColors[1]),
            label: Text(
              LocalizationService.translate('add_location'),
              style: TextStyle(color: gradientColors[1]),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDay 
                  ? Colors.white
                  : overlayColor.withOpacity(0.3),
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 8,
              shadowColor: iconThemeMode != 'default' && !isDay
                  ? textColor.withOpacity(0.3)
                  : Colors.black.withOpacity(isDay ? 0.08 : 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDay 
                      ? textColor.withOpacity(0.15)
                      : textColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(
    SavedLocation location,
    LocationService locationService,
    SavedLocationsService savedLocationsService,
    SettingsService settings,
    int index,
    String iconThemeMode,
    bool isDay,
  ) {
    final textColor = _getTextColor(iconThemeMode, isDay);
    final cardBgColor = _getCardBackgroundColor(iconThemeMode, isDay);
    
    // Calculate distance
    final distanceKm = locationService.currentPosition != null
        ? _calculateDistance(
            locationService.currentPosition!.latitude,
            locationService.currentPosition!.longitude,
            location.latitude,
            location.longitude,
          )
        : null;

    final distanceMeters = distanceKm != null ? distanceKm * 1000 : null;
    final distanceConverted = distanceMeters != null 
        ? UnitConverter.convertDistance(distanceMeters, settings.distanceUnit)
        : null;
    final distanceUnit = _getDistanceUnitAbbreviation(settings.distanceUnit);

    final bearing = locationService.currentPosition != null
        ? _calculateBearing(
            locationService.currentPosition!.latitude,
            locationService.currentPosition!.longitude,
            location.latitude,
            location.longitude,
          )
        : null;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key(location.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFC62828),
                Color(0xFFD32F2F),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                LocalizationService.translate('delete'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: cardBgColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete, color: Color(0xFFB71C1C)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    LocalizationService.translate('delete_location'),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              content: Text(
                '${LocalizationService.translate('delete_location_confirm_prefix')} "${location.name}"? ${LocalizationService.translate('delete_location_confirm_suffix')}',
                style: TextStyle(height: 1.4, color: textColor.withOpacity(0.8)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(LocalizationService.translate('cancel'), style: TextStyle(color: textColor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(LocalizationService.translate('delete')),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) async {
          await savedLocationsService.deleteLocation(location.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('${location.name} ${LocalizationService.translate('deleted')}'),
                  ],
                ),
                backgroundColor: const Color(0xFFD32F2F),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: isDay ? 2 : 8,
          color: cardBgColor,
          shadowColor: isDay 
              ? Colors.black.withOpacity(0.08)
              : _getCategoryColor(location.category ?? 'Other', iconThemeMode).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDay 
                  ? _getCategoryColor(location.category ?? 'Other', iconThemeMode).withOpacity(0.15)
                  : _getCategoryColor(location.category ?? 'Other', iconThemeMode).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedLocationDetailScreen(
                    location: location,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: isDay 
                    ? null
                    : LinearGradient(
                        colors: [
                          _getCategoryColor(location.category ?? 'Other', iconThemeMode).withOpacity(0.15),
                          cardBgColor,
                          cardBgColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.3, 1.0],
                      ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Category Icon
                  Hero(
                    tag: 'location_icon_${location.id}',
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getCategoryColor(location.category ?? 'Other', iconThemeMode),
                            _getCategoryColor(location.category ?? 'Other', iconThemeMode).withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _getCategoryColor(location.category ?? 'Other', iconThemeMode).withOpacity(isDay ? 0.25 : 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getCategoryIcon(location.category),
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Location Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (location.address != null)
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: textColor.withOpacity(0.6)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location.address!,
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.6),
                                    fontSize: 13,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              color: textColor.withOpacity(0.6),
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        if (distanceConverted != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getCategoryColor(location.category ?? 'Other', iconThemeMode).withOpacity(0.2),
                                  _getCategoryColor(location.category ?? 'Other', iconThemeMode).withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getCategoryColor(location.category ?? 'Other', iconThemeMode).withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.navigation,
                                  size: 14,
                                  color: _getCategoryColor(location.category ?? 'Other', iconThemeMode),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${distanceConverted.toStringAsFixed(2)} $distanceUnit',
                                  style: TextStyle(
                                    color: _getCategoryColor(location.category ?? 'Other', iconThemeMode),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (bearing != null) ...[
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.explore,
                                    size: 14,
                                    color: _getCategoryColor(location.category ?? 'Other', iconThemeMode),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getBearingDirection(bearing),
                                    style: TextStyle(
                                      color: _getCategoryColor(location.category ?? 'Other', iconThemeMode),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Arrow indicator
                  Icon(
                    Icons.chevron_right,
                    color: textColor.withOpacity(0.4),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
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

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = _toRadians(lon2 - lon1);
    final y = math.sin(dLon) * math.cos(_toRadians(lat2));
    final x = math.cos(_toRadians(lat1)) * math.sin(_toRadians(lat2)) -
        math.sin(_toRadians(lat1)) * math.cos(_toRadians(lat2)) * math.cos(dLon);
    final bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  String _getBearingDirection(double bearing) {
    final directions = [
      LocalizationService.translate('n'),
      LocalizationService.translate('ne'),
      LocalizationService.translate('e'),
      LocalizationService.translate('se'),
      LocalizationService.translate('s'),
      LocalizationService.translate('sw'),
      LocalizationService.translate('w'),
      LocalizationService.translate('nw')
    ];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  Color _getCategoryColor(String categoryKey, String iconThemeMode) {
    if (iconThemeMode == 'glow') {
      if (categoryKey == 'Home') return const Color(0xFF00FFAA);
      if (categoryKey == 'Work') return const Color(0xFF00FF88);
      if (categoryKey == 'Favorite') return const Color(0xFF00DD88);
      if (categoryKey == 'Restaurant') return const Color(0xFF00BBAA);
      if (categoryKey == 'Shopping') return const Color(0xFF00AACC);
      if (categoryKey == 'Gas Station') return const Color(0xFF00CCAA);
      if (categoryKey == 'Parking') return const Color(0xFF00DDBB);
      if (categoryKey == 'Hotel') return const Color(0xFF00EEBB);
      if (categoryKey == 'Hospital') return const Color(0xFF00FFBB);
      if (categoryKey == 'School') return const Color(0xFF00EEAA);
      return const Color(0xFF00DDAA);
    } else if (iconThemeMode == 'night') {
      if (categoryKey == 'Home') return const Color(0xFFC62828);
      if (categoryKey == 'Work') return const Color(0xFFD32F2F);
      if (categoryKey == 'Favorite') return const Color(0xFFD32F2F);
      if (categoryKey == 'Restaurant') return const Color(0xFFE53935);
      if (categoryKey == 'Shopping') return const Color(0xFFF44336);
      if (categoryKey == 'Gas Station') return const Color(0xFFF44336);
      if (categoryKey == 'Parking') return const Color(0xFFEF5350);
      if (categoryKey == 'Hotel') return const Color(0xFFEF5350);
      if (categoryKey == 'Hospital') return const Color(0xFFD32F2F);
      if (categoryKey == 'School') return const Color(0xFFFF7043);
      return const Color(0xFFE53935);
    } else {
      if (categoryKey == 'Home') return const Color(0xFF5C6BC0);
      if (categoryKey == 'Work') return const Color(0xFFFF9800);
      if (categoryKey == 'Favorite') return const Color(0xFFE91E63);
      if (categoryKey == 'Restaurant') return const Color(0xFFFF5722);
      if (categoryKey == 'Shopping') return const Color(0xFF9C27B0);
      if (categoryKey == 'Gas Station') return const Color(0xFF4CAF50);
      if (categoryKey == 'Parking') return const Color(0xFF3F51B5);
      if (categoryKey == 'Hotel') return const Color(0xFF00BCD4);
      if (categoryKey == 'Hospital') return const Color(0xFFD81B60);
      if (categoryKey == 'School') return const Color(0xFFFFC107);
      return const Color(0xFF009688);
    }
  }

  IconData _getCategoryIcon(String? categoryKey) {
    if (categoryKey == 'Home') return Icons.home;
    if (categoryKey == 'Work') return Icons.work;
    if (categoryKey == 'Favorite') return Icons.favorite;
    if (categoryKey == 'Restaurant') return Icons.restaurant;
    if (categoryKey == 'Shopping') return Icons.shopping_bag;
    if (categoryKey == 'Gas Station') return Icons.local_gas_station;
    if (categoryKey == 'Parking') return Icons.local_parking;
    if (categoryKey == 'Hotel') return Icons.hotel;
    if (categoryKey == 'Hospital') return Icons.local_hospital;
    if (categoryKey == 'School') return Icons.school;
    return Icons.place;
  }
}