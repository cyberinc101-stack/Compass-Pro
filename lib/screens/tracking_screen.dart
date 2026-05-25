import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/saved_locations_service.dart';
import '../services/tracking_service.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';
import '../utils/unit_converter_helper.dart';
import '../models/saved_location.dart';

class TrackingScreen extends StatefulWidget {
  final VoidCallback? onBackToCompass;
  
  const TrackingScreen({Key? key, this.onBackToCompass}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<Position>? _positionSubscription;
  
  @override
  void dispose() {
    _scrollController.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  String _formatCoordinate(double? value, LocalizationService localization, {bool isLatitude = true}) {
    if (value == null) {
      return localization.translate('na');
    }
    final direction = isLatitude 
        ? (value >= 0 ? localization.translate('n') : localization.translate('s'))
        : (value >= 0 ? localization.translate('e') : localization.translate('w'));
    return '${value.abs().toStringAsFixed(6)}° $direction';
  }

  void _startTracking() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    final trackingService = Provider.of<TrackingService>(context, listen: false);
    
    if (trackingService.isTracking) return;
    
    final currentPos = locationService.currentPosition;
    final address = locationService.currentAddress;
    
    trackingService.startTracking(currentPos, address);
    trackingService.startTimer();
    
    await _positionSubscription?.cancel();
    
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        // FIX: distanceFilter set to 0 (was 8).
        // With distanceFilter:8, the stream suppressed frequent 0.0 m/s
        // stationary readings, so ghost Doppler speed had fewer votes
        // against it and persisted in the display. With 0, every GPS
        // pulse comes through — stationary readings vote speed back to
        // zero immediately, and TrackingService's displacement cross-check
        // (Filter 3) handles noise suppression instead.
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      trackingService.updatePosition(position, shouldAddDistance: true);
    });
    
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _pauseTracking() {
    final trackingService = Provider.of<TrackingService>(context, listen: false);
    trackingService.togglePause();
  }

  Future<void> _stopTracking() async {
    final trackingService = Provider.of<TrackingService>(context, listen: false);
    
    await _saveTrackingSession();
    
    await _positionSubscription?.cancel();
    trackingService.stopTracking();
    trackingService.reset();
  }

  Future<void> _saveTrackingSession() async {
    final trackingService = Provider.of<TrackingService>(context, listen: false);
    final settings = Provider.of<SettingsService>(context, listen: false);
    final localization = Provider.of<LocalizationService>(context, listen: false);
    
    if (trackingService.startLatitude == null || trackingService.startLongitude == null) {
      return;
    }
    
    final savedLocationsService = Provider.of<SavedLocationsService>(context, listen: false);
    
    // avgSpeed / maxSpeed in TrackingService are km/h.
    // UnitConverter.formatSpeed / convertSpeed expect m/s, so divide by 3.6.
    final distanceFormatted = UnitConverter.formatDistance(trackingService.totalDistance, settings.distanceUnit);
    final avgSpeedFormatted = UnitConverter.formatSpeed(trackingService.avgSpeed / 3.6, settings.speedUnit);
    final maxSpeedFormatted = UnitConverter.formatSpeed(trackingService.maxSpeed / 3.6, settings.speedUnit);
    final elevationFormatted = UnitConverter.formatDistance(trackingService.elevation, settings.distanceUnit);
    
    String paceText;
    if (trackingService.elapsedSeconds > 0 && trackingService.totalDistance > 0) {
      final distanceInUnit = UnitConverter.convertDistance(trackingService.totalDistance, settings.distanceUnit);
      final paceMinutes = trackingService.elapsedSeconds / 60 / distanceInUnit;
      final distanceUnitName = settings.distanceUnit == 'Kilometers' ? localization.translate('km') : 
                               settings.distanceUnit == 'Miles' ? localization.translate('mi') : 
                               settings.distanceUnit == 'Meters' ? localization.translate('m') : localization.translate('ft');
      paceText = '${paceMinutes.toStringAsFixed(0)} ${localization.translate('min')}/$distanceUnitName';
    } else {
      paceText = '0 ${localization.translate('min')}';
    }
    
    final separator = '━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    final notes = '''${localization.translate('route_tracking_session')}
$separator
${localization.translate('distance')}: $distanceFormatted
${localization.translate('duration')}: ${trackingService.formattedTime}
${localization.translate('avg_speed')}: $avgSpeedFormatted
${localization.translate('max_speed')}: $maxSpeedFormatted
${localization.translate('elevation')}: $elevationFormatted
${localization.translate('pace')}: $paceText

${localization.translate('start')}: ${_formatCoordinate(trackingService.startLatitude, localization, isLatitude: true)}, ${_formatCoordinate(trackingService.startLongitude, localization, isLatitude: false)}
${localization.translate('end')}: ${_formatCoordinate(trackingService.lastLatitude, localization, isLatitude: true)}, ${_formatCoordinate(trackingService.lastLongitude, localization, isLatitude: false)}''';
    
    final timestamp = DateTime.now();
    final name = '${localization.translate('route')} $distanceFormatted - ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    
    final newLocation = SavedLocation(
      id: timestamp.millisecondsSinceEpoch.toString(),
      name: name,
      latitude: trackingService.startLatitude!,
      longitude: trackingService.startLongitude!,
      timestamp: timestamp,
      category: 'Tracking',
      notes: notes,
      address: trackingService.startAddress,
      altitude: trackingService.elevation,
      accuracy: 0.0,
    );

    await savedLocationsService.addLocation(newLocation);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${localization.translate('tracking_session_saved')}: $distanceFormatted'),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  List<Color> _getGradientColors(SettingsService settings) {
    switch (settings.iconThemeMode) {
      case 'glow':
        return [const Color(0xFF003355), const Color(0xFF004466)];
      case 'night':
        return [const Color(0xFF330022), const Color(0xFF440033)];
      default:
        return [const Color(0xFF4A90E2), const Color(0xFF63B3ED)];
    }
  }

  Color _getStatColor(SettingsService settings, int index) {
    final baseColors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    
    switch (settings.iconThemeMode) {
      case 'glow':
        return [
          const Color(0xFF00DDFF),
          const Color(0xFF00FF88),
          const Color(0xFFFFCC00),
          const Color(0xFFDD00FF),
          const Color(0xFFFF3388),
        ][index];
      case 'night':
        return [
          const Color(0xFFFF4488),
          const Color(0xFFFF6666),
          const Color(0xFFFFAA44),
          const Color(0xFFFF88DD),
          const Color(0xFFFF3333),
        ][index];
      default:
        return baseColors[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    final trackingService = Provider.of<TrackingService>(context);
    final settings = Provider.of<SettingsService>(context);
    final localization = Provider.of<LocalizationService>(context);
    
    // currentSpeed in TrackingService is km/h → convert to m/s for UnitConverter
    final currentSpeed = trackingService.currentSpeed / 3.6;

    final distanceFormatted = UnitConverter.formatDistance(trackingService.totalDistance, settings.distanceUnit);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getGradientColors(settings),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 60, bottom: 20, left: 12, right: 12),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: settings.getIconColor(opacity: 0.2),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              Icons.route,
                              size: 36,
                              color: settings.getIconColor(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              localization.translate('route_tracking'),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: settings.getTextColor(),
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateTime.now().toString().split('.')[0],
                            style: TextStyle(
                              fontSize: 12,
                              color: settings.getTextColor(opacity: 0.7),
                              fontFamily: 'monospace',
                            ),
                          ),
                          
                          const SizedBox(height: 28),
                          
                          // Main Stats
                          Row(
                            children: [
                              Expanded(
                                child: _buildPrimaryStatCard(
                                  label: localization.translate('distance'),
                                  value: distanceFormatted,
                                  icon: Icons.straighten,
                                  color: _getStatColor(settings, 0),
                                  settings: settings,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildPrimaryStatCard(
                                  label: localization.translate('time'),
                                  value: trackingService.formattedTime,
                                  icon: Icons.timer,
                                  color: _getStatColor(settings, 1),
                                  settings: settings,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Coordinates
                          if (trackingService.startLatitude != null || trackingService.lastLatitude != null) ...[
                            _buildSectionTitle(localization.translate('location_section'), Icons.location_on, settings),
                            const SizedBox(height: 10),
                            _buildLocationCard(trackingService, settings, localization),
                            const SizedBox(height: 20),
                          ],
                          
                          // Speed Section
                          _buildSectionTitle(localization.translate('speed_metrics'), Icons.speed, settings),
                          const SizedBox(height: 10),
                          _buildSpeedSection(trackingService, currentSpeed, settings, localization),
                          
                          const SizedBox(height: 20),
                          
                          // Activity Stats
                          _buildSectionTitle(localization.translate('activity_stats'), Icons.directions_run, settings),
                          const SizedBox(height: 10),
                          _buildActivityStats(trackingService, settings, localization),
                          
                          const SizedBox(height: 20),
                          
                          // Session Details
                          _buildSectionTitle(localization.translate('session_details'), Icons.info_outline, settings),
                          const SizedBox(height: 10),
                          _buildSessionDetails(trackingService, settings, localization),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Control buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: !trackingService.isTracking
                          ? _buildStartButton(settings, localization)
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _pauseTracking,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _getStatColor(settings, 2),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      elevation: 8,
                                    ),
                                    // FIX: Removed mainAxisSize: MainAxisSize.min from this Row.
                                    // This button is inside an Expanded widget. Setting mainAxisSize.min
                                    // on the inner Row caused Flutter to apply competing Flexible
                                    // constraints — the Expanded above and the min-size Row below
                                    // both try to control the Text widget's layout, triggering the
                                    // "Incorrect use of ParentDataWidget" / competing Flexible crash.
                                    // With mainAxisSize removed, the Row fills its Expanded parent
                                    // correctly and mainAxisAlignment: center handles the centering.
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(trackingService.isPaused ? Icons.play_arrow : Icons.pause, size: 22),
                                        const SizedBox(width: 6),
                                        Text(
                                          trackingService.isPaused ? localization.translate('resume') : localization.translate('pause'),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _stopTracking,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _getStatColor(settings, 4),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      elevation: 8,
                                    ),
                                    // FIX: Same as pause button — removed mainAxisSize: MainAxisSize.min.
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.stop, size: 22),
                                        const SizedBox(width: 6),
                                        Text(
                                          localization.translate('stop'),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                      
                    const SizedBox(height: 20),
                  ],
                ),
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
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: settings.getIconColor(opacity: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: settings.getIconColor(),
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

  Widget _buildLocationCard(TrackingService trackingService, SettingsService settings, LocalizationService localization) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            settings.getIconColor(opacity: 0.12),
            settings.getIconColor(opacity: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: settings.getIconColor(opacity: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag,
                      color: _getStatColor(settings, 1),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        localization.translate('start_position'),
                        style: TextStyle(
                          color: settings.getTextColor(opacity: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCoordinate(trackingService.startLatitude, localization, isLatitude: true),
                          style: TextStyle(
                            color: settings.getTextColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCoordinate(trackingService.startLongitude, localization, isLatitude: false),
                          style: TextStyle(
                            color: settings.getTextColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildDivider(settings),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.my_location,
                      color: _getStatColor(settings, 4),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        localization.translate('current_position'),
                        style: TextStyle(
                          color: settings.getTextColor(opacity: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCoordinate(trackingService.lastLatitude, localization, isLatitude: true),
                          style: TextStyle(
                            color: settings.getTextColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCoordinate(trackingService.lastLongitude, localization, isLatitude: false),
                          style: TextStyle(
                            color: settings.getTextColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedSection(TrackingService trackingService, double currentSpeed, SettingsService settings, LocalizationService localization) {
    final currentSpeedConverted = UnitConverter.convertSpeed(currentSpeed, settings.speedUnit);
    // avgSpeed / maxSpeed stored as km/h → convert to m/s for UnitConverter
    final avgSpeedConverted = UnitConverter.convertSpeed(trackingService.avgSpeed / 3.6, settings.speedUnit);
    final maxSpeedConverted = UnitConverter.convertSpeed(trackingService.maxSpeed / 3.6, settings.speedUnit);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            settings.getIconColor(opacity: 0.15),
            settings.getIconColor(opacity: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: settings.getIconColor(opacity: 0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: localization.translate('current'),
                  value: currentSpeedConverted.toStringAsFixed(1),
                  unit: settings.speedUnit,
                  icon: Icons.speed,
                  color: _getStatColor(settings, 2),
                  settings: settings,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  label: localization.translate('average'),
                  value: avgSpeedConverted.toStringAsFixed(1),
                  unit: settings.speedUnit,
                  icon: Icons.analytics,
                  color: _getStatColor(settings, 3),
                  settings: settings,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildStatCard(
            label: localization.translate('max_speed'),
            value: maxSpeedConverted.toStringAsFixed(1),
            unit: settings.speedUnit,
            icon: Icons.flash_on,
            color: _getStatColor(settings, 4),
            settings: settings,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStats(TrackingService trackingService, SettingsService settings, LocalizationService localization) {
    final elevationConverted = UnitConverter.convertDistance(trackingService.elevation, settings.distanceUnit);
    final distanceUnitAbbr = settings.distanceUnit == 'Kilometers' ? localization.translate('km') : 
                             settings.distanceUnit == 'Miles' ? localization.translate('mi') : 
                             settings.distanceUnit == 'Meters' ? localization.translate('m') : localization.translate('ft');
    
    String paceText;
    if (trackingService.elapsedSeconds > 0 && trackingService.totalDistance > 0) {
      final distanceInUnit = UnitConverter.convertDistance(trackingService.totalDistance, settings.distanceUnit);
      final paceMinutes = trackingService.elapsedSeconds / 60 / distanceInUnit;
      paceText = '${paceMinutes.toStringAsFixed(0)} ${localization.translate('min')}/$distanceUnitAbbr';
    } else {
      paceText = '0 ${localization.translate('min')}/$distanceUnitAbbr';
    }
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            settings.getIconColor(opacity: 0.12),
            settings.getIconColor(opacity: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: settings.getIconColor(opacity: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            localization.translate('elevation'),
            '${elevationConverted.toStringAsFixed(0)} $distanceUnitAbbr',
            Icons.terrain,
            settings,
          ),
          _buildDivider(settings),
          _buildInfoRow(
            localization.translate('pace'),
            paceText,
            Icons.timeline,
            settings,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetails(TrackingService trackingService, SettingsService settings, LocalizationService localization) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            settings.getIconColor(opacity: 0.12),
            settings.getIconColor(opacity: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: settings.getIconColor(opacity: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            localization.translate('status'),
            trackingService.isTracking
                ? (trackingService.isPaused ? localization.translate('paused') : localization.translate('active'))
                : localization.translate('stopped'),
            trackingService.isTracking
                ? (trackingService.isPaused ? Icons.pause_circle : Icons.play_circle)
                : Icons.stop_circle,
            settings,
          ),
          _buildDivider(settings),
          _buildInfoRow(
            localization.translate('moving_time'),
            trackingService.formattedTime,
            Icons.access_time,
            settings,
          ),
          _buildDivider(settings),
          _buildInfoRow(
            localization.translate('distance_unit'),
            settings.distanceUnit,
            Icons.straighten,
            settings,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, SettingsService settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: settings.getIconColor(opacity: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: settings.getIconColor(), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: settings.getTextColor(),
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required SettingsService settings,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            settings.getIconColor(opacity: 0.2),
            settings.getIconColor(opacity: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: settings.getTextColor(opacity: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: settings.getTextColor(),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required SettingsService settings,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: settings.getIconColor(opacity: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: settings.getTextColor(opacity: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: settings.getTextColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: TextStyle(
                    color: settings.getTextColor(opacity: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, SettingsService settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: settings.getIconColor(opacity: 0.8),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: settings.getTextColor(opacity: 0.85),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  color: settings.getTextColor(),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(SettingsService settings) {
    return Divider(
      height: 1,
      thickness: 1,
      color: settings.getIconColor(opacity: 0.1),
    );
  }

  Widget _buildStartButton(SettingsService settings, LocalizationService localization) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startTracking,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getStatColor(settings, 1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, size: 26),
            const SizedBox(width: 8),
            Text(
              localization.translate('start_tracking'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}