import 'package:flutter/foundation.dart';

class CompassService extends ChangeNotifier {
  bool _isCalibrated = false;
  double _currentHeading = 0.0;
  
  // Calibration offsets (hard iron correction)
  double _xOffset = 0.0;
  double _yOffset = 0.0;
  double _zOffset = 0.0;
  
  bool get isCalibrated => _isCalibrated;
  double get currentHeading => _currentHeading;
  
  double get xOffset => _xOffset;
  double get yOffset => _yOffset;
  double get zOffset => _zOffset;
  
  void setCalibrated(bool value) {
    _isCalibrated = value;
    notifyListeners();
  }
  
  void updateHeading(double heading) {
    _currentHeading = heading;
    notifyListeners();
  }
  
  void setCalibrationOffsets(double x, double y, double z) {
    _xOffset = x;
    _yOffset = y;
    _zOffset = z;
    notifyListeners();
  }
  
  /// Apply calibration to raw magnetometer values
  Map<String, double> applyCalibratedValues(double x, double y, double z) {
    if (!_isCalibrated) {
      return {'x': x, 'y': y, 'z': z};
    }
    
    return {
      'x': x - _xOffset,
      'y': y - _yOffset,
      'z': z - _zOffset,
    };
  }
  
  void resetCalibration() {
    _isCalibrated = false;
    _xOffset = 0.0;
    _yOffset = 0.0;
    _zOffset = 0.0;
    notifyListeners();
  }
}