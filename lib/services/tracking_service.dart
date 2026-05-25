import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class TrackingService extends ChangeNotifier {
  bool _isTracking = false;
  bool _isPaused = false;
  double _totalDistance = 0.0;
  int _elapsedSeconds = 0;
  double _maxSpeed = 0.0;
  double _avgSpeed = 0.0;
  double _currentSpeed = 0.0;
  double _elevation = 0.0;

  double? _startLatitude;
  double? _startLongitude;
  double? _lastLatitude;
  double? _lastLongitude;
  double? _anchorLatitude;
  double? _anchorLongitude;

  String? _startAddress;
  Timer? _timer;

  DateTime? _lastPositionTime;
  int _consecutiveStationaryReadings = 0;
  int _consecutiveMovingReadings = 0;

  final List<double> _speedWindow = [];
  static const int _kSpeedWindowSize = 5;

  // ── Thresholds ─────────────────────────────────────────────────────────────

  // Accuracy gate: reject fixes worse than this.
  static const double _kAccuracyGate = 25.0; // metres

  // Doppler stationary threshold.
  // Raised to 0.8 m/s — Doppler noise can reach 0.7 m/s on budget devices.
  // Normal walking is 1.2+ m/s so this threshold still catches real movement.
  static const double _kStationaryMs = 0.8; // m/s

  // Hard speed cap.
  static const double _kMaxPlausibleMs = 55.0; // m/s (~200 km/h)

  // Minimum COORDINATE displacement from anchor to count as real movement.
  // RAISED from 2.0m → 5.0m to account for GPS random walk drift.
  // GPS coordinates wander 2–4m over time even when completely stationary.
  // Requiring 5m of displacement means you need to actually walk ~5 steps.
  static const double _kMinDisplacementM = 5.0; // metres

  // Minimum segment to add to total distance.
  static const double _kMinSegmentM = 5.0; // metres

  // Maximum single-step jump before treating as GPS teleport.
  static const double _kMaxJumpM = 150.0; // metres

  // Consecutive valid readings required before recording speed/distance.
  static const int _kConsecutiveReq = 2;

  // Getters
  bool get isTracking => _isTracking;
  bool get isPaused => _isPaused;
  double get totalDistance => _totalDistance;
  int get elapsedSeconds => _elapsedSeconds;
  double get maxSpeed => _maxSpeed;
  double get avgSpeed => _avgSpeed;
  double get currentSpeed => _currentSpeed;
  double get elevation => _elevation;

  double? get startLatitude => _startLatitude;
  double? get startLongitude => _startLongitude;
  double? get lastLatitude => _lastLatitude;
  double? get lastLongitude => _lastLongitude;
  String? get startAddress => _startAddress;

  void startTracking(Position? currentPosition, String? address) {
    _isTracking = true;
    _isPaused = false;
    _totalDistance = 0.0;
    _elapsedSeconds = 0;
    _maxSpeed = 0.0;
    _avgSpeed = 0.0;
    _currentSpeed = 0.0;
    _elevation = currentPosition?.altitude ?? 0.0;

    _startLatitude  = currentPosition?.latitude;
    _startLongitude = currentPosition?.longitude;
    _lastLatitude   = currentPosition?.latitude;
    _lastLongitude  = currentPosition?.longitude;
    _anchorLatitude  = currentPosition?.latitude;
    _anchorLongitude = currentPosition?.longitude;

    _startAddress = address;
    _lastPositionTime = DateTime.now();
    _consecutiveStationaryReadings = 0;
    _consecutiveMovingReadings = 0;
    _speedWindow.clear();

    notifyListeners();
    debugPrint('🚀 TrackingService: Started tracking at '
        '${_startLatitude?.toStringAsFixed(6)}, ${_startLongitude?.toStringAsFixed(6)}');
  }

  void updatePosition(Position? currentPosition, {bool shouldAddDistance = true}) {
    if (!_isTracking || _isPaused || currentPosition == null) return;

    final now = currentPosition.timestamp ?? DateTime.now();

    _lastLatitude  = currentPosition.latitude;
    _lastLongitude = currentPosition.longitude;
    _elevation     = currentPosition.altitude;

    final double rawSpeedMps = currentPosition.speed >= 0 ? currentPosition.speed : 0.0;

    // ── Filter 1: Accuracy gate ────────────────────────────────────────────
    if (currentPosition.accuracy > _kAccuracyGate) {
      debugPrint('❌ REJECTED: Poor accuracy ${currentPosition.accuracy.toStringAsFixed(1)}m');
      _resetMovementState();
      _lastPositionTime = now;
      notifyListeners();
      return;
    }

    // ── Filter 2: Hard speed cap ───────────────────────────────────────────
    if (rawSpeedMps > _kMaxPlausibleMs) {
      debugPrint('❌ REJECTED: Implausible speed ${(rawSpeedMps * 3.6).toStringAsFixed(1)} km/h');
      _resetMovementState();
      _lastPositionTime = now;
      notifyListeners();
      return;
    }

    // ── Compute displacement from anchor ──────────────────────────────────
    final double displacement = (_anchorLatitude != null && _anchorLongitude != null)
        ? _calculateDistance(
            _anchorLatitude!, _anchorLongitude!,
            currentPosition.latitude, currentPosition.longitude,
          )
        : 0.0;

    final bool dopplerMoving     = rawSpeedMps >= _kStationaryMs;
    final bool coordinatesMoving = displacement >= _kMinDisplacementM;

    // ── Filter 3: Stationary detection ────────────────────────────────────
    // Treat as stationary if EITHER:
    //   (a) Doppler speed is below threshold (genuine standstill), OR
    //   (b) Doppler claims movement but coordinates haven't moved enough
    //       (Doppler noise — the ghost speed case)
    //
    // KEY FIX for phantom distance: the anchor now updates on EVERY
    // stationary reading, not just after 2+ consecutive ones.
    // Previously the anchor could sit at a position from several seconds ago.
    // GPS random walk drifts 2–4m over time, so the displacement from a
    // stale anchor would grow large enough to look like real movement and
    // slip through. By keeping the anchor continuously updated to the latest
    // GPS position when stationary, drift from anchor never accumulates.
    if (!dopplerMoving || (dopplerMoving && !coordinatesMoving)) {
      _consecutiveMovingReadings = 0;
      _consecutiveStationaryReadings++;
      _speedWindow.clear();
      _currentSpeed = 0.0;

      // Always slide anchor to current position when stationary.
      // This is what prevents drift accumulation.
      _anchorLatitude  = currentPosition.latitude;
      _anchorLongitude = currentPosition.longitude;

      _lastPositionTime = now;

      if (!dopplerMoving) {
        debugPrint('📍 STATIONARY: Doppler ${rawSpeedMps.toStringAsFixed(2)} m/s '
            '< ${_kStationaryMs} threshold, streak: $_consecutiveStationaryReadings');
      } else {
        debugPrint('👻 GHOST SPEED: Doppler=${rawSpeedMps.toStringAsFixed(2)} m/s '
            'but only ${displacement.toStringAsFixed(1)}m displacement (< ${_kMinDisplacementM}m)');
      }

      notifyListeners();
      return;
    }

    // ── Both Doppler AND coordinates confirm movement ──────────────────────

    // GPS teleport check
    if (displacement > _kMaxJumpM) {
      debugPrint('❌ REJECTED: GPS jump ${displacement.toStringAsFixed(1)}m from anchor');
      _resetMovementState();
      _anchorLatitude  = currentPosition.latitude;
      _anchorLongitude = currentPosition.longitude;
      _lastPositionTime = now;
      notifyListeners();
      return;
    }

    // Speed/displacement mismatch check
    if (_lastPositionTime != null) {
      final double dtSeconds =
          now.difference(_lastPositionTime!).inMilliseconds / 1000.0;
      if (dtSeconds > 0.5 && displacement > 0) {
        final double impliedSpeedMps = displacement / dtSeconds;
        if (impliedSpeedMps < 0.15 && rawSpeedMps > 2.0) {
          debugPrint('❌ REJECTED: Speed/distance mismatch — '
              'Doppler: ${rawSpeedMps.toStringAsFixed(2)} m/s, '
              'implied: ${impliedSpeedMps.toStringAsFixed(2)} m/s');
          _resetMovementState();
          _lastPositionTime = now;
          notifyListeners();
          return;
        }
      }
    }

    // ── Filter 4: Require N consecutive confirmed-movement readings ────────
    _consecutiveMovingReadings++;
    _consecutiveStationaryReadings = 0;

    if (_consecutiveMovingReadings < _kConsecutiveReq) {
      _currentSpeed = 0.0;
      _lastPositionTime = now;
      debugPrint('⏳ VALIDATING: $_consecutiveMovingReadings/$_kConsecutiveReq');
      notifyListeners();
      return;
    }

    // ── ALL FILTERS PASSED — confirmed real movement ───────────────────────
    debugPrint('✅ VALID: ${rawSpeedMps.toStringAsFixed(2)} m/s '
        '(${(rawSpeedMps * 3.6).toStringAsFixed(1)} km/h), '
        'displacement ${displacement.toStringAsFixed(1)}m, '
        'accuracy ${currentPosition.accuracy.toStringAsFixed(1)}m');

    // Speed smoothing
    final double rawSpeedKmh = rawSpeedMps * 3.6;
    _speedWindow.add(rawSpeedKmh);
    if (_speedWindow.length > _kSpeedWindowSize) _speedWindow.removeAt(0);
    final double smoothedKmh =
        _speedWindow.reduce((a, b) => a + b) / _speedWindow.length;
    _currentSpeed = smoothedKmh;

    if (smoothedKmh > _maxSpeed) {
      _maxSpeed = smoothedKmh;
      debugPrint('🏎️ New max: ${_maxSpeed.toStringAsFixed(1)} km/h');
    }

    // Distance accumulation
    if (shouldAddDistance && _anchorLatitude != null && _anchorLongitude != null) {
      final double segment = _calculateDistance(
        _anchorLatitude!, _anchorLongitude!,
        currentPosition.latitude, currentPosition.longitude,
      );

      if (segment >= _kMinSegmentM && segment < _kMaxJumpM) {
        _totalDistance += segment;
        debugPrint('➕ +${segment.toStringAsFixed(1)}m → Total: ${_totalDistance.toStringAsFixed(1)}m');
        _anchorLatitude  = currentPosition.latitude;
        _anchorLongitude = currentPosition.longitude;
      } else if (segment < _kMinSegmentM) {
        debugPrint('⏭️ Segment too short: ${segment.toStringAsFixed(1)}m');
      }
    }

    _lastPositionTime = now;

    if (_elapsedSeconds > 0 && _totalDistance > 0) {
      _avgSpeed = (_totalDistance / _elapsedSeconds) * 3.6;
    }

    notifyListeners();
  }

  void _resetMovementState() {
    _consecutiveMovingReadings = 0;
    _speedWindow.clear();
    _currentSpeed = 0.0;
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _isTracking) {
        _elapsedSeconds++;
        if (_totalDistance > 0 && _elapsedSeconds > 0) {
          _avgSpeed = (_totalDistance / _elapsedSeconds) * 3.6;
        }
        notifyListeners();
      }
    });
  }

  void togglePause() {
    _isPaused = !_isPaused;
    if (_isPaused) {
      _resetMovementState();
      _consecutiveStationaryReadings = 0;
    }
    notifyListeners();
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    _isPaused = false;
    notifyListeners();
    debugPrint('⏹️ Stopped. Total: ${_totalDistance.toStringAsFixed(1)}m');
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  // Legacy setters
  void setTracking(bool value) { _isTracking = value; notifyListeners(); }
  void setPaused(bool value) { _isPaused = value; notifyListeners(); }
  void updateDistance(double distance) { _totalDistance = distance; notifyListeners(); }
  void updateElapsedTime(int seconds) { _elapsedSeconds = seconds; notifyListeners(); }
  void updateMaxSpeed(double speed) { _maxSpeed = speed; notifyListeners(); }
  void updateAvgSpeed(double speed) { _avgSpeed = speed; notifyListeners(); }
  void updateCurrentSpeed(double speed) { _currentSpeed = speed; notifyListeners(); }

  void reset() {
    _totalDistance = 0.0;
    _elapsedSeconds = 0;
    _maxSpeed = 0.0;
    _avgSpeed = 0.0;
    _currentSpeed = 0.0;
    _elevation = 0.0;
    _startLatitude    = null;
    _startLongitude   = null;
    _lastLatitude     = null;
    _lastLongitude    = null;
    _anchorLatitude   = null;
    _anchorLongitude  = null;
    _startAddress     = null;
    _lastPositionTime = null;
    _consecutiveStationaryReadings = 0;
    _consecutiveMovingReadings = 0;
    _speedWindow.clear();
    notifyListeners();
  }

  String get formattedTime {
    final int hours   = _elapsedSeconds ~/ 3600;
    final int minutes = (_elapsedSeconds % 3600) ~/ 60;
    final int secs    = _elapsedSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${secs.toString().padLeft(2, '0')}';
  }

  String get formattedDistance {
    if (_totalDistance < 1000) {
      return '${_totalDistance.toStringAsFixed(0)} m';
    } else {
      return '${(_totalDistance / 1000).toStringAsFixed(2)} km';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}