import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/compass_service.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart'; // ADDED IMPORT
import 'dart:math' as math;
import 'dart:async';

class CalibrationScreen extends StatefulWidget {
  final VoidCallback? onBackToCompass;
  
  const CalibrationScreen({Key? key, this.onBackToCompass}) : super(key: key);

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen>
    with SingleTickerProviderStateMixin {
  bool _isCalibrating = false;
  double _calibrationProgress = 0.0;
  int _calibrationStep = 0;
  late AnimationController _rotationController;
  StreamSubscription? _magnetometerSubscription;
  
  // Min/Max values for each axis
  double _xMin = double.infinity;
  double _xMax = double.negativeInfinity;
  double _yMin = double.infinity;
  double _yMax = double.negativeInfinity;
  double _zMin = double.infinity;
  double _zMax = double.negativeInfinity;
  
  // Coverage percentages
  double _xCoverage = 0.0;
  double _yCoverage = 0.0;
  double _zCoverage = 0.0;
  
  // Expected range for magnetometer (typical Earth's magnetic field)
  static const double expectedRange = 100.0; // microteslas

  // Get translation helper - REPLACED TODO
  String _translate(String key) {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    return localization.translate(key);
  }

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  void _startListeningToMagnetometer() {
    _magnetometerSubscription = magnetometerEventStream().listen((event) {
      if (_isCalibrating) {
        setState(() {
          // Update min/max values
          _xMin = math.min(_xMin, event.x);
          _xMax = math.max(_xMax, event.x);
          _yMin = math.min(_yMin, event.y);
          _yMax = math.max(_yMax, event.y);
          _zMin = math.min(_zMin, event.z);
          _zMax = math.max(_zMax, event.z);
          
          // Calculate coverage based on range
          _xCoverage = math.min((_xMax - _xMin) / expectedRange, 1.0);
          _yCoverage = math.min((_yMax - _yMin) / expectedRange, 1.0);
          _zCoverage = math.min((_zMax - _zMin) / expectedRange, 1.0);
          
          _updateCalibrationProgress();
        });
      }
    });
  }

  void _updateCalibrationProgress() {
    // Progress is the average coverage of all three axes
    final totalCoverage = (_xCoverage + _yCoverage + _zCoverage) / 3;
    _calibrationProgress = math.min(totalCoverage, 1.0);
    
    // Update step based on progress
    if (_calibrationProgress < 0.25) {
      _calibrationStep = 1;
    } else if (_calibrationProgress < 0.50) {
      _calibrationStep = 2;
    } else if (_calibrationProgress < 0.75) {
      _calibrationStep = 3;
    } else {
      _calibrationStep = 4;
    }
    
    // Complete when all axes have good coverage
    if (_xCoverage >= 0.8 && _yCoverage >= 0.8 && _zCoverage >= 0.8) {
      _completeCalibration();
    }
  }

  void _startCalibration() {
    setState(() {
      _isCalibrating = true;
      _calibrationStep = 1;
      _calibrationProgress = 0.0;
      
      // Reset min/max values
      _xMin = double.infinity;
      _xMax = double.negativeInfinity;
      _yMin = double.infinity;
      _yMax = double.negativeInfinity;
      _zMin = double.infinity;
      _zMax = double.negativeInfinity;
      
      // Reset coverage
      _xCoverage = 0.0;
      _yCoverage = 0.0;
      _zCoverage = 0.0;
    });
    
    _startListeningToMagnetometer();
  }

  void _cancelCalibration() {
    setState(() {
      _isCalibrating = false;
      _calibrationStep = 0;
      _calibrationProgress = 0.0;
      
      // Reset min/max values
      _xMin = double.infinity;
      _xMax = double.negativeInfinity;
      _yMin = double.infinity;
      _yMax = double.negativeInfinity;
      _zMin = double.infinity;
      _zMax = double.negativeInfinity;
      
      // Reset coverage
      _xCoverage = 0.0;
      _yCoverage = 0.0;
      _zCoverage = 0.0;
    });
    
    // Cancel magnetometer subscription
    _magnetometerSubscription?.cancel();
  }

  void _completeCalibration() {
    if (!_isCalibrating) return;
    
    setState(() {
      _isCalibrating = false;
      _calibrationStep = 0;
      _calibrationProgress = 1.0;
    });
    
    // Cancel magnetometer subscription
    _magnetometerSubscription?.cancel();
    
    // Calculate calibration offsets (hard iron correction)
    final xOffset = (_xMax + _xMin) / 2;
    final yOffset = (_yMax + _yMin) / 2;
    final zOffset = (_zMax + _zMin) / 2;
    
    // Save calibration to CompassService
    final compassService = Provider.of<CompassService>(context, listen: false);
    compassService.setCalibrated(true);
    compassService.setCalibrationOffsets(xOffset, yOffset, zOffset);
    
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final settings = Provider.of<SettingsService>(context, listen: false);
    final themeMode = settings.iconThemeMode;
    final dialogBackgroundColor = themeMode == 'night' 
        ? const Color(0xFF21262D)
        : themeMode == 'glow'
            ? const Color(0xFF2D2D2D)
            : Colors.white;
    final textColor = themeMode == 'day' 
        ? Colors.black87
        : settings.getTextColor(opacity: 1.0);
    final iconColor = themeMode == 'day'
        ? Colors.blue.shade700
        : settings.getIconColor(opacity: 1.0);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBackgroundColor,
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _translate('calibration_complete'),
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        content: Text(
          _translate('calibration_success_message'),
          style: TextStyle(color: textColor.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              _translate('ok'),
              style: TextStyle(color: iconColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onBackToCompass != null) {
                widget.onBackToCompass!();
              } else {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
            ),
            child: Text(
              _translate('back_to_compass'),
              style: TextStyle(
                color: themeMode == 'night' ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetCalibration() {
    final settings = Provider.of<SettingsService>(context, listen: false);
    final themeMode = settings.iconThemeMode;
    final dialogBackgroundColor = themeMode == 'night' 
        ? const Color(0xFF21262D)
        : themeMode == 'glow'
            ? const Color(0xFF2D2D2D)
            : Colors.white;
    final textColor = themeMode == 'day' 
        ? Colors.black87
        : settings.getTextColor(opacity: 1.0);
    final iconColor = themeMode == 'day'
        ? Colors.blue.shade700
        : settings.getIconColor(opacity: 1.0);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBackgroundColor,
        title: Text(
          _translate('reset_calibration'),
          style: TextStyle(color: textColor),
        ),
        content: Text(
          _translate('reset_calibration_confirmation'),
          style: TextStyle(color: textColor.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _translate('cancel'),
              style: TextStyle(color: iconColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _calibrationProgress = 0.0;
                _xMin = double.infinity;
                _xMax = double.negativeInfinity;
                _yMin = double.infinity;
                _yMax = double.negativeInfinity;
                _zMin = double.infinity;
                _zMax = double.negativeInfinity;
                _xCoverage = 0.0;
                _yCoverage = 0.0;
                _zCoverage = 0.0;
              });
              
              final compassService = Provider.of<CompassService>(context, listen: false);
              compassService.setCalibrated(false);
              compassService.setCalibrationOffsets(0, 0, 0);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_translate('calibration_data_cleared')),
                  backgroundColor: themeMode == 'night'
                      ? const Color(0xFF30363D)
                      : null,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
            ),
            child: Text(
              _translate('reset'),
              style: TextStyle(
                color: themeMode == 'night' ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _magnetometerSubscription?.cancel();
    super.dispose();
  }

  // Get background colors based on theme mode
  Color _getBackgroundStartColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return const Color(0xFF4A90E2);
      case 'glow':
        return const Color(0xFF003355);
      case 'night':
        return const Color(0xFF0D1117);
      default:
        return const Color(0xFF4A90E2);
    }
  }

  Color _getBackgroundEndColor(String themeMode) {
    switch (themeMode) {
      case 'day':
        return const Color(0xFF63B3ED);
      case 'glow':
        return const Color(0xFF004466);
      case 'night':
        return const Color(0xFF1C1F26);
      default:
        return const Color(0xFF63B3ED);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final themeMode = settings.iconThemeMode;
    
    // Get theme-aware colors that work with the background
    final textColor = themeMode == 'day' 
        ? Colors.black87
        : settings.getTextColor(opacity: 1.0);
    final textColorLight = themeMode == 'day'
        ? Colors.black54
        : settings.getTextColor(opacity: 0.6);
    final iconColor = themeMode == 'day'
        ? Colors.blue.shade700
        : settings.getIconColor(opacity: 1.0);
    final cardBackgroundColor = themeMode == 'night' 
        ? const Color(0xFF21262D)
        : themeMode == 'glow'
            ? const Color(0xFF2D2D2D)
            : Colors.white;
    final progressBackgroundColor = themeMode == 'night'
        ? const Color(0xFF30363D)
        : themeMode == 'glow'
            ? const Color(0xFF3D3D3D)
            : Colors.grey[300];
    
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
                padding: const EdgeInsets.fromLTRB(24, 70, 24, 16),
                children: [
                  const SizedBox(height: 20),
                  Text(
                    _translate('compass_calibration'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _translate('calibrate_description'),
                    style: TextStyle(
                      fontSize: 16,
                      color: textColorLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  // Calibration animation
                  _buildCalibrationVisual(settings, themeMode, iconColor),
                  
                  const SizedBox(height: 40),
                  
                  // Progress indicator
                  if (_isCalibrating) _buildProgressSection(settings, progressBackgroundColor, textColor),
                  
                  const SizedBox(height: 30),
                  
                  // Instructions
                  _buildInstructions(settings, cardBackgroundColor, textColor, textColorLight, iconColor),
                  
                  const SizedBox(height: 30),
                  
                  // Calibration buttons
                  if (_isCalibrating)
                    _buildCancelButton(settings, themeMode, iconColor)
                  else
                    _buildCalibrationButton(settings, themeMode, iconColor),
                  
                  const SizedBox(height: 30),
                  
                  // Advanced settings (hide during calibration)
                  if (!_isCalibrating)
                    _buildAdvancedSettings(settings, cardBackgroundColor, textColor, textColorLight, iconColor),
                ],
              ),
              
              // Back button - positioned at top left matching tracking screen
              Positioned(
                top: 10,
                left: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (_isCalibrating) {
                        _cancelCalibration();
                      } else {
                        if (widget.onBackToCompass != null) {
                          widget.onBackToCompass!();
                        } else {
                          Navigator.pop(context);
                        }
                      }
                    },
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

  Widget _buildCalibrationVisual(SettingsService settings, String themeMode, Color iconColor) {
    final iconColorLight = themeMode == 'day'
        ? Colors.blue.shade200
        : settings.getIconColor(opacity: 0.2);
    final iconColorVeryLight = themeMode == 'day'
        ? Colors.blue.shade50
        : settings.getIconColor(opacity: 0.05);
    
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              iconColorLight,
              iconColorVeryLight,
            ],
          ),
        ),
        child: Center(
          child: _isCalibrating
              ? AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.phone_iphone,
                    size: 100,
                    color: iconColor,
                  ),
                )
              : Icon(
                  Icons.explore,
                  size: 100,
                  color: iconColor,
                ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(SettingsService settings, Color? progressBackgroundColor, Color textColor) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _calibrationProgress,
          minHeight: 8,
          backgroundColor: progressBackgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(
            _calibrationProgress < 0.5
                ? Colors.red
                : _calibrationProgress < 0.8
                    ? Colors.orange
                    : Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${(_calibrationProgress * 100).toInt()}${_translate('percent_complete')}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAxisCoverage(_translate('axis_x'), _xCoverage, Colors.red, progressBackgroundColor, textColor),
            _buildAxisCoverage(_translate('axis_y'), _yCoverage, Colors.green, progressBackgroundColor, textColor),
            _buildAxisCoverage(_translate('axis_z'), _zCoverage, Colors.blue, progressBackgroundColor, textColor),
          ],
        ),
      ],
    );
  }

  Widget _buildAxisCoverage(String axis, double coverage, Color color, Color? backgroundColor, Color textColor) {
    return Column(
      children: [
        Text(
          axis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: coverage,
            strokeWidth: 6,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(coverage * 100).toInt()}%',
          style: TextStyle(
            fontSize: 12,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(SettingsService settings, Color cardBackgroundColor, Color textColor, Color textColorLight, Color iconColor) {
    return Card(
      elevation: 4,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  _translate('calibration_steps'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(
              1,
              _translate('step_1_title'),
              _translate('step_1_description'),
              settings,
              textColor,
              textColorLight,
              iconColor,
            ),
            _buildInstructionStep(
              2,
              _translate('step_2_title'),
              _translate('step_2_description'),
              settings,
              textColor,
              textColorLight,
              iconColor,
            ),
            _buildInstructionStep(
              3,
              _translate('step_3_title'),
              _translate('step_3_description'),
              settings,
              textColor,
              textColorLight,
              iconColor,
            ),
            _buildInstructionStep(
              4,
              _translate('step_4_title'),
              _translate('step_4_description'),
              settings,
              textColor,
              textColorLight,
              iconColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
    int number,
    String title,
    String description,
    SettingsService settings,
    Color textColor,
    Color textColorLight,
    Color iconColor,
  ) {
    final isActive = _calibrationStep == number;
    final themeMode = settings.iconThemeMode;
    final inactiveBackgroundColor = themeMode == 'night'
        ? const Color(0xFF30363D)
        : themeMode == 'glow'
            ? const Color(0xFF3D3D3D)
            : Colors.grey[300];
    final inactiveTextColor = themeMode == 'night'
        ? Colors.grey[500]
        : themeMode == 'glow'
            ? Colors.grey[400]
            : Colors.grey[700];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? iconColor : inactiveBackgroundColor,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: isActive 
                      ? (themeMode == 'night' ? Colors.black : Colors.white)
                      : inactiveTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? iconColor : textColor,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColorLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationButton(SettingsService settings, String themeMode, Color iconColor) {
    return ElevatedButton(
      onPressed: _startCalibration,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: iconColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        _translate('start_calibration'),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: themeMode == 'night' ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  Widget _buildCancelButton(SettingsService settings, String themeMode, Color iconColor) {
    return ElevatedButton(
      onPressed: _cancelCalibration,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        _translate('cancel_calibration'),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAdvancedSettings(SettingsService settings, Color cardBackgroundColor, Color textColor, Color textColorLight, Color iconColor) {
    final compassService = Provider.of<CompassService>(context);
    
    return Card(
      elevation: 2,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: Icon(Icons.settings, color: iconColor),
        title: Text(
          _translate('advanced_settings'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        iconColor: iconColor,
        collapsedIconColor: iconColor,
        children: [
          ListTile(
            leading: Icon(
              compassService.isCalibrated ? Icons.check_circle : Icons.warning,
              color: compassService.isCalibrated ? Colors.green : Colors.orange,
            ),
            title: Text(
              _translate('calibration_status'),
              style: TextStyle(color: textColor),
            ),
            subtitle: Text(
              compassService.isCalibrated 
                  ? _translate('calibrated')
                  : _translate('not_calibrated'),
              style: TextStyle(color: textColorLight),
            ),
          ),
          ListTile(
            leading: Icon(Icons.refresh, color: iconColor),
            title: Text(
              _translate('reset_calibration'),
              style: TextStyle(color: textColor),
            ),
            subtitle: Text(
              _translate('clear_all_calibration_data'),
              style: TextStyle(color: textColorLight),
            ),
            onTap: _resetCalibration,
          ),
        ],
      ),
    );
  }
}