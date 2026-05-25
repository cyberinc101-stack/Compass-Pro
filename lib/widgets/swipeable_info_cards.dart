import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../services/tracking_service.dart';
import '../services/localization_service.dart';
import '../utils/unit_converter_helper.dart';

class SwipeableInfoCards extends StatefulWidget {
  final LocationService locationService;
  final double heading;

  const SwipeableInfoCards({
    Key? key,
    required this.locationService,
    required this.heading,
  }) : super(key: key);

  @override
  State<SwipeableInfoCards> createState() => _SwipeableInfoCardsState();
}

class _SwipeableInfoCardsState extends State<SwipeableInfoCards> {
  late ScrollController _scrollController;
  double _itemWidth = 0;
  bool _isSnapping = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _snapToNearestItem() {
    if (_itemWidth == 0 || _isSnapping) return;

    final currentScroll = _scrollController.offset;
    final targetIndex = (currentScroll / _itemWidth).round();
    final targetScroll = targetIndex * _itemWidth;

    if ((currentScroll - targetScroll).abs() < 0.5) return;

    _isSnapping = true;

    _scrollController
        .animateTo(
          targetScroll,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        )
        .then((_) => _isSnapping = false)
        .catchError((_) => _isSnapping = false);
  }

  String _getDistanceUnitAbbreviation(String unit, LocalizationService loc) {
    switch (unit) {
      case 'Meters':     return loc.translate('m');
      case 'Feet':       return loc.translate('ft');
      case 'Kilometers': return loc.translate('km');
      case 'Miles':      return loc.translate('mi');
      default:           return loc.translate('m');
    }
  }

  List<Widget> _buildAllItems(
    TrackingService ts,
    SettingsService settings,
    LocalizationService loc,
  ) {
    final accuracy  = widget.locationService.currentPosition?.accuracy  ?? 0.0;
    final altitude  = widget.locationService.currentPosition?.altitude  ?? 0.0;
    final latitude  = widget.locationService.currentPosition?.latitude  ?? 0.0;
    final longitude = widget.locationService.currentPosition?.longitude ?? 0.0;

    final List<Widget> items = [];

    // ── TRACKING CARDS ───────────────────────────────────────────────────────
    // TrackingService stores currentSpeed / avgSpeed / maxSpeed in km/h.
    // UnitConverter.convertSpeed expects m/s, so divide by 3.6 ONCE here.
    // Do NOT divide again anywhere else.

    if (settings.showSpeed && ts.isTracking) {
      // FIX: was dividing by 3.6 in swipeable_info_cards AND the service
      // already stored km/h — causing double-conversion (showed ~10× too low).
      // Now: km/h → m/s → convertSpeed → display unit. Single conversion.
      final converted = UnitConverter.convertSpeed(
        ts.currentSpeed / 3.6,
        settings.speedUnit,
      );
      items.add(_buildInfoItem(
        settings: settings,
        loc: loc,
        icon: Icons.speed_rounded,
        label: loc.translate('speed'),
        value: converted.toStringAsFixed(1),
        unit: settings.speedUnit,
      ));
    }

    if (settings.showDistance && ts.isTracking) {
      // totalDistance is metres — convertDistance expects metres. No division needed.
      final converted = UnitConverter.convertDistance(
        ts.totalDistance,
        settings.distanceUnit,
      );
      items.add(_buildInfoItem(
        settings: settings,
        loc: loc,
        icon: Icons.straighten_rounded,
        label: loc.translate('distance'),
        value: converted.toStringAsFixed(2),
        unit: _getDistanceUnitAbbreviation(settings.distanceUnit, loc),
      ));
    }

    if (settings.showMaxSpeed && ts.isTracking) {
      // FIX: same double-conversion bug as currentSpeed above.
      final converted = UnitConverter.convertSpeed(
        ts.maxSpeed / 3.6,
        settings.speedUnit,
      );
      items.add(_buildInfoItem(
        settings: settings,
        loc: loc,
        icon: Icons.flash_on,
        label: loc.translate('max_speed'),
        value: converted.toStringAsFixed(1),
        unit: settings.speedUnit,
      ));
    }

    if (settings.showMovingTime && ts.isTracking) {
      items.add(_buildInfoItem(
        settings: settings,
        loc: loc,
        icon: Icons.timer_rounded,
        label: loc.translate('moving'),
        value: ts.formattedTime,
        unit: '',
      ));
    }

    if (settings.showAvgSpeed && ts.isTracking) {
      // FIX: same double-conversion bug as currentSpeed above.
      final converted = UnitConverter.convertSpeed(
        ts.avgSpeed / 3.6,
        settings.speedUnit,
      );
      items.add(_buildInfoItem(
        settings: settings,
        loc: loc,
        icon: Icons.analytics_rounded,
        label: loc.translate('avg_speed'),
        value: converted.toStringAsFixed(1),
        unit: settings.speedUnit,
      ));
    }

    // ── NON-TRACKING CARDS ───────────────────────────────────────────────────

    if (settings.showAccuracy) {
      final converted = UnitConverter.convertDistance(accuracy, settings.distanceUnit);
      items.add(_buildInfoItem(
        settings: settings,
        loc: loc,
        icon: Icons.my_location_rounded,
        label: loc.translate('accuracy'),
        value: '±${converted.toStringAsFixed(0)}',
        unit: _getDistanceUnitAbbreviation(settings.distanceUnit, loc),
      ));
    }

    if (settings.showAltitude) {
      final converted = UnitConverter.convertDistance(altitude, settings.distanceUnit);
      items.add(_buildInfoItem(
        settings: settings,
        loc: loc,
        icon: Icons.terrain_rounded,
        label: loc.translate('altitude'),
        value: converted.toStringAsFixed(0),
        unit: _getDistanceUnitAbbreviation(settings.distanceUnit, loc),
      ));
    }

    if (settings.showBearing) {
      items.add(_buildInfoItem(
        settings: settings,
        loc: loc,
        icon: Icons.navigation_rounded,
        label: loc.translate('bearing'),
        value: '${widget.heading.toInt()}',
        unit: '°',
      ));
    }

    if (settings.showLocation) {
      items.add(_buildInfoItem(
        settings: settings,
        loc: loc,
        icon: Icons.location_on_rounded,
        label: loc.translate('location'),
        value: latitude.toStringAsFixed(4),
        unit: '',
        subtitle: longitude.toStringAsFixed(4),
      ));
    }

    if (settings.showElevation) {
      final converted = UnitConverter.convertDistance(altitude, settings.distanceUnit);
      items.add(_buildInfoItem(
        settings: settings,
        loc: loc,
        icon: Icons.trending_up_rounded,
        label: loc.translate('elevation'),
        value: converted.toStringAsFixed(0),
        unit: _getDistanceUnitAbbreviation(settings.distanceUnit, loc),
      ));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<TrackingService, SettingsService, LocalizationService>(
      builder: (context, trackingService, settings, localization, child) {
        final allItems = _buildAllItems(trackingService, settings, localization);

        if (allItems.isEmpty) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            _itemWidth = constraints.maxWidth / 3;

            return SizedBox(
              height: 120,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification &&
                      notification.depth == 0 &&
                      !_isSnapping) {
                    _snapToNearestItem();
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: allItems.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: _itemWidth,
                      child: allItems[index],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoItem({
    required SettingsService settings,
    required LocalizationService loc,
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    String? subtitle,
  }) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: settings.getIconColor(opacity: 0.95),
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: settings.getTextColor(opacity: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          if (subtitle == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: settings.getTextColor(opacity: 0.95),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Text(
                    unit,
                    style: TextStyle(
                      color: settings.getTextColor(opacity: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            )
          else
            Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: settings.getTextColor(opacity: 0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: settings.getTextColor(opacity: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}