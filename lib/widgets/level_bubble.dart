import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import '../services/settings_service.dart';
import '../services/localization_service.dart';

class LevelBubble extends StatefulWidget {
  final double size;
  
  const LevelBubble({
    Key? key,
    this.size = 120,
  }) : super(key: key);

  @override
  State<LevelBubble> createState() => _LevelBubbleState();
}

class _LevelBubbleState extends State<LevelBubble> {
  double _xTilt = 0;
  double _yTilt = 0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _initAccelerometer();
  }

  void _initAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (!mounted) return;
      
      setState(() {
        // Normalize the tilt values (-1 to 1 range)
        // Clamp to prevent bubble from going outside container
        _xTilt = (event.x / 10).clamp(-1.0, 1.0);
        _yTilt = (event.y / 10).clamp(-1.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  bool get _isLevel {
    return _xTilt.abs() < 0.05 && _yTilt.abs() < 0.05;
  }

  // Determine if it's day or night based on current time
  bool _isDay() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 20;
  }

  // Get background color based on icon theme mode
  Color _getBackgroundColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay 
            ? Colors.black.withOpacity(0.3)
            : const Color(0xFF001100).withOpacity(0.5);
      case 'night':
        return isDay
            ? const Color(0xFF330000).withOpacity(0.3)
            : const Color(0xFF220000).withOpacity(0.5);
      default:
        return Colors.black.withOpacity(0.3);
    }
  }

  // Get border color based on icon theme mode
  Color _getBorderColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00FFAA).withOpacity(0.5)
            : const Color(0xFF00FF88).withOpacity(0.5);
      case 'night':
        return isDay
            ? const Color(0xFFFF8888).withOpacity(0.5)
            : const Color(0xFFFF6666).withOpacity(0.5);
      default:
        return Colors.white.withOpacity(0.5);
    }
  }

  // Get crosshair color based on icon theme mode
  Color _getCrosshairColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00FFCC).withOpacity(0.3)
            : const Color(0xFF00FFAA).withOpacity(0.3);
      case 'night':
        return isDay
            ? const Color(0xFFFFAAAA).withOpacity(0.3)
            : const Color(0xFFFF8888).withOpacity(0.3);
      default:
        return Colors.white.withOpacity(0.3);
    }
  }

  // Get target circle color based on icon theme mode and level state
  Color _getTargetColor(String iconThemeMode, bool isDay, bool isLevel) {
    if (isLevel) {
      switch (iconThemeMode) {
        case 'glow':
          return isDay
              ? const Color(0xFF00FFCC).withOpacity(0.6)
              : const Color(0xFF00FFAA).withOpacity(0.6);
        case 'night':
          return isDay
              ? const Color(0xFFFF88FF).withOpacity(0.6)
              : const Color(0xFFFF66FF).withOpacity(0.6);
        default:
          return Colors.green.withOpacity(0.6);
      }
    } else {
      switch (iconThemeMode) {
        case 'glow':
          return isDay
              ? const Color(0xFF00FFAA).withOpacity(0.3)
              : const Color(0xFF00FF88).withOpacity(0.3);
        case 'night':
          return isDay
              ? const Color(0xFFFF8888).withOpacity(0.3)
              : const Color(0xFFFF6666).withOpacity(0.3);
        default:
          return Colors.white.withOpacity(0.3);
      }
    }
  }

  // Get bubble gradient colors based on icon theme mode and level state
  List<Color> _getBubbleColors(String iconThemeMode, bool isDay, bool isLevel) {
    if (isLevel) {
      switch (iconThemeMode) {
        case 'glow':
          return isDay
              ? [
                  const Color(0xFF00FFCC).withOpacity(0.8),
                  const Color(0xFF00FFAA).withOpacity(0.4),
                ]
              : [
                  const Color(0xFF00FFAA).withOpacity(0.8),
                  const Color(0xFF00FF88).withOpacity(0.4),
                ];
        case 'night':
          return isDay
              ? [
                  const Color(0xFFFF88FF).withOpacity(0.8),
                  const Color(0xFFFF66FF).withOpacity(0.4),
                ]
              : [
                  const Color(0xFFFF66FF).withOpacity(0.8),
                  const Color(0xFFFF44FF).withOpacity(0.4),
                ];
        default:
          return [
            Colors.green.withOpacity(0.8),
            Colors.green.withOpacity(0.4),
          ];
      }
    } else {
      switch (iconThemeMode) {
        case 'glow':
          return isDay
              ? [
                  const Color(0xFFFFFF00).withOpacity(0.8),
                  const Color(0xFFFFFF00).withOpacity(0.4),
                ]
              : [
                  const Color(0xFF00FFFF).withOpacity(0.8),
                  const Color(0xFF00FFFF).withOpacity(0.4),
                ];
        case 'night':
          return isDay
              ? [
                  const Color(0xFFFFAA00).withOpacity(0.8),
                  const Color(0xFFFFAA00).withOpacity(0.4),
                ]
              : [
                  const Color(0xFFFFCC66).withOpacity(0.8),
                  const Color(0xFFFFCC66).withOpacity(0.4),
                ];
        default:
          return [
            Colors.yellow.withOpacity(0.8),
            Colors.yellow.withOpacity(0.4),
          ];
      }
    }
  }

  // Get level text color based on icon theme mode
  Color _getLevelTextColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00FFCC)
            : const Color(0xFF00FFAA);
      case 'night':
        return isDay
            ? const Color(0xFFFF88FF)
            : const Color(0xFFFF66FF);
      default:
        return Colors.green[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final localization = Provider.of<LocalizationService>(context);
    final iconThemeMode = settings.iconThemeMode ?? 'default';
    final isDay = _isDay();
    
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getBackgroundColor(iconThemeMode, isDay),
        border: Border.all(
          color: _getBorderColor(iconThemeMode, isDay),
          width: 2,
        ),
        boxShadow: iconThemeMode == 'glow' || iconThemeMode == 'night'
            ? [
                BoxShadow(
                  color: _getBorderColor(iconThemeMode, isDay).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Crosshair lines
          Center(
            child: Container(
              width: widget.size,
              height: 1,
              color: _getCrosshairColor(iconThemeMode, isDay),
            ),
          ),
          Center(
            child: Container(
              width: 1,
              height: widget.size,
              color: _getCrosshairColor(iconThemeMode, isDay),
            ),
          ),
          
          // Center circle (target)
          Center(
            child: Container(
              width: widget.size * 0.2,
              height: widget.size * 0.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getTargetColor(iconThemeMode, isDay, _isLevel),
                  width: 2,
                ),
                boxShadow: _isLevel && (iconThemeMode == 'glow' || iconThemeMode == 'night')
                    ? [
                        BoxShadow(
                          color: _getTargetColor(iconThemeMode, isDay, _isLevel),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          
          // Bubble
          AnimatedPositioned(
            duration: const Duration(milliseconds: 50),
            left: (widget.size / 2) + (_xTilt * widget.size * 0.35) - (widget.size * 0.15),
            top: (widget.size / 2) - (_yTilt * widget.size * 0.35) - (widget.size * 0.15),
            child: Container(
              width: widget.size * 0.3,
              height: widget.size * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: _getBubbleColors(iconThemeMode, isDay, _isLevel),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                  if (iconThemeMode == 'glow' || iconThemeMode == 'night')
                    BoxShadow(
                      color: _getBubbleColors(iconThemeMode, isDay, _isLevel)[0],
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                ],
              ),
            ),
          ),
          
          // Level indicator text
          if (_isLevel)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTargetColor(iconThemeMode, isDay, _isLevel).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: iconThemeMode != 'default'
                      ? Border.all(
                          color: _getLevelTextColor(iconThemeMode, isDay).withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Text(
                  localization.translate('level'),
                  style: TextStyle(
                    color: _getLevelTextColor(iconThemeMode, isDay),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    shadows: iconThemeMode == 'glow' || iconThemeMode == 'night'
                        ? [
                            Shadow(
                              color: _getLevelTextColor(iconThemeMode, isDay).withOpacity(0.6),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}