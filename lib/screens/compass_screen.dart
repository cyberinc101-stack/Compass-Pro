import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/compass_service.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../services/weather_service.dart';
import '../services/localization_service.dart';
import '../widgets/heading_card.dart';
import '../widgets/swipeable_info_cards.dart';
import '../widgets/level_bubble.dart';
import '../widgets/weather_info_widget.dart';
import 'compass_styles/classic_compass.dart';
import 'compass_styles/digital_compass.dart';
import 'compass_styles/gradient_compass.dart';
import 'compass_styles/high_tech.dart';
import 'compass_styles/minimal_compass.dart';
import 'compass_styles/modern_compass.dart';
import 'compass_styles/nautical_compass.dart';
import 'compass_styles/neon_compass.dart';
import 'compass_styles/vintage_compass.dart';
import 'compass_styles/3d_compass.dart';
import 'compass_styles/tech_compass.dart';
import 'compass_styles/nav_compass.dart';
import 'compass_styles/tele_compass.dart';
import 'compass_styles/digi_compass.dart';
// UPDATED: All background imports including new ones
import 'backgrounds/classic_gradient_bg.dart';
import 'backgrounds/map_background.dart';
import 'backgrounds/transparent_background.dart';
import 'backgrounds/weather_background.dart';
import 'backgrounds/dark_mode_background.dart';
import 'backgrounds/sunset_background.dart';
import 'backgrounds/ocean_background.dart';
import 'backgrounds/mountain_background.dart';
import 'backgrounds/night_sky_background.dart';
import 'backgrounds/aurora_background.dart';
import 'backgrounds/black_background.dart';
import 'backgrounds/galaxy_background.dart';
import 'backgrounds/cosmic_background.dart';
import 'backgrounds/nebula_background.dart';

class CompassScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const CompassScreen({Key? key, this.onBackPressed}) : super(key: key);

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> with WidgetsBindingObserver {
  double _heading = 0;
  double _smoothHeading = 0;
  String _compassStyle = 'classic';
  String _backgroundStyle = 'classic';
  StreamSubscription<CompassEvent>? _compassSubscription;
  bool _isInitialized = false;
  bool _stylesLoaded = false;

  // Weather data
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;
  Timer? _weatherRefreshTimer;

  String translate(String key) {
    return LocalizationService.translate(key);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStylesSync();
    _initializeServices();
    _initCompass();
    _loadWeather();
    _startWeatherRefreshTimer();
  }

  Future<void> _loadStylesSync() async {
    final prefs = await SharedPreferences.getInstance();
    final compass = prefs.getString('compass_style') ?? 'classic';
    final background = prefs.getString('background_style') ?? 'classic';
    
    if (mounted) {
      setState(() {
        _compassStyle = compass;
        _backgroundStyle = background;
        _stylesLoaded = true;
      });
    }
  }

  Future<void> _initializeServices() async {
    if (!_isInitialized) {
      final locationService = Provider.of<LocationService>(context, listen: false);
      await locationService.getCurrentLocation();
      _isInitialized = true;
    }
  }

  Future<void> _loadWeather() async {
    print('🌤️ COMPASS: _loadWeather() called');
    
    try {
      final locationService = Provider.of<LocationService>(context, listen: false);
      
      if (locationService.currentPosition != null) {
        print('✅ COMPASS: Using cached location from LocationService');
        final data = await _weatherService.getWeather(
          locationService.currentPosition!.latitude,
          locationService.currentPosition!.longitude,
        );
        
        if (mounted) {
          setState(() {
            _weatherData = data;
            _isLoadingWeather = false;
          });
          print('✅ COMPASS: Weather loaded instantly from cached position');
        }
      } else {
        print('⚠️ COMPASS: No cached position, fetching fresh');
        final data = await _weatherService.getCurrentWeather();
        
        if (mounted) {
          setState(() {
            _weatherData = data;
            _isLoadingWeather = false;
          });
          print('✅ COMPASS: Weather loaded from fresh GPS');
        }
      }
    } catch (e) {
      print('❌ COMPASS: Error loading weather: $e');
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
  }

  void _startWeatherRefreshTimer() {
    _weatherRefreshTimer = Timer.periodic(
      const Duration(minutes: 10),
      (timer) {
        _loadWeather();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCompassStyle();
      _loadBackgroundStyle();
      _initCompass();
      _loadWeather();
      final locationService = Provider.of<LocationService>(context, listen: false);
      locationService.refreshLocation();
    } else if (state == AppLifecycleState.paused) {
      _compassSubscription?.cancel();
    }
  }

  Future<void> _loadCompassStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final newStyle = prefs.getString('compass_style') ?? 'classic';
    if (mounted && newStyle != _compassStyle) {
      setState(() {
        _compassStyle = newStyle;
      });
    }
  }

  Future<void> _loadBackgroundStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final newBackground = prefs.getString('background_style') ?? 'classic';
    if (mounted && newBackground != _backgroundStyle) {
      setState(() {
        _backgroundStyle = newBackground;
      });
    }
  }

  void _initCompass() {
    _compassSubscription?.cancel();
    
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (!mounted) return;
      
      if (event.heading != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _heading = event.heading!;
              _smoothHeading = _lerp(_smoothHeading, _heading, 0.1);
            });
            
            Provider.of<CompassService>(context, listen: false)
                .updateHeading(_smoothHeading);
          }
        });
      }
    });
  }

  double _lerp(double a, double b, double t) {
    double diff = b - a;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return (a + diff * t) % 360;
  }

  Widget _getCompassWidget(double heading, double size) {
    switch (_compassStyle) {
      case 'tech':
        return TechCompass(heading: heading);
      case 'nav':
        return NavCompass(heading: heading);
      case 'tele':
        return TeleCompass(heading: heading);
      case 'digi':
        return DigiCompass(heading: heading);
      case 'classic':
        return ClassicCompass(heading: heading);
      case 'digital':
        return DigitalCompass(heading: heading);
      case 'modern':
        return ModernCompass(heading: heading);
      case 'minimal':
        return MinimalCompass(heading: heading);
      case 'gradient':
        return GradientCompass(heading: heading);
      case 'military':
        return HighTechCompass(heading: heading);
      case 'nautical':
        return NauticalCompass(heading: heading);
      case 'neon':
        return NeonCompass(heading: heading);
      case 'vintage':
        return VintageCompass(heading: heading);
      case '3d':
        return ThreeDCompass(heading: heading);
      default:
        return ClassicCompass(heading: heading);
    }
  }

  // UPDATED: Added all new background cases
  Widget _getBackgroundWidget(Widget child) {
    switch (_backgroundStyle) {
      case 'classic':
        return ClassicGradientBackground(child: child);
      case 'map':
        return MapBackground(child: child);
      case 'transparent':
        return TransparentBackground(child: child);
      case 'weather':
        return WeatherBackground(child: child);
      case 'dark':
        return DarkModeBackground(child: child);
      case 'sunset':
        return SunsetBackground(child: child);
      case 'ocean':
        return OceanBackground(child: child);
      case 'mountain':
        return MountainBackground(child: child);
      case 'night':
        return NightSkyBackground(child: child);
      case 'aurora':
        return AuroraBackground(child: child);
      case 'black':
        return BlackBackground(child: child);
      case 'galaxy':
        return GalaxyBackground(child: child);
      case 'cosmic':
        return CosmicBackground(child: child);
      case 'nebula':
        return NebulaBackground(child: child);
      default:
        return ClassicGradientBackground(child: child);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _compassSubscription?.cancel();
    _weatherRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_stylesLoaded) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    final locationService = Provider.of<LocationService>(context);
    final settings = Provider.of<SettingsService>(context);
    
    final textColor = settings.getTextColor(opacity: 1.0);
    final iconColor = settings.getIconColor(opacity: 1.0);
    final textColorLight = settings.getTextColor(opacity: 0.7);
    final textColorMedium = settings.getTextColor(opacity: 0.85);
    final iconColorLight = settings.getIconColor(opacity: 0.3);
    
    return _getBackgroundWidget(
      SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 55,
              ),
              child: Column(
                children: [
                  if (settings.showWeatherInfo)
                    _isLoadingWeather
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      textColorLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  translate('loading_weather'),
                                  style: TextStyle(
                                    color: textColorLight,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : WeatherInfoWidget(weatherData: _weatherData),
                  
                  if (settings.showWeatherInfo)
                    const SizedBox(height: 8),
                  
                  if (settings.showCoordinates)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: locationService.currentPosition != null
                          ? _buildTranslatableCoordinateDisplay(locationService, settings)
                          : _buildNoLocationCard(locationService, settings),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            height: MediaQuery.of(context).size.width * 0.75,
                            child: _getCompassWidget(
                              _smoothHeading,
                              MediaQuery.of(context).size.width * 0.75,
                            ),
                          ),
                          
                          if (settings.showLevelBubble)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: LevelBubble(
                                size: MediaQuery.of(context).size.width * 0.22,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (settings.showHeadingCard)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: HeadingCard(heading: _smoothHeading),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  if (settings.showLocationText)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      child: _buildScrollableLocationText(locationService, settings),
                    ),
                  
                  // FIX: Removed redundant outer SizedBox(height: 100) — SwipeableInfoCards
                  // already declares its own SizedBox(height: 120) internally. The conflicting
                  // heights were causing layout thrashing and contributing to the ParentDataWidget error.
                  if (settings.showInfoCards)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SwipeableInfoCards(
                        locationService: locationService,
                        heading: _smoothHeading,
                      ),
                    ),
                ],
              ),
            ),
            
            if (widget.onBackPressed != null)
              Positioned(
                top: 8,
                left: 8,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onBackPressed,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: iconColorLight,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: iconColor,
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

  Widget _buildTranslatableCoordinateDisplay(LocationService locationService, SettingsService settings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildCoordinateItem(
          translate('lat'),
          locationService.currentPosition!.latitude.toStringAsFixed(6),
          settings,
        ),
        Container(
          width: 1,
          height: 30,
          color: settings.getTextColor(opacity: 0.3),
        ),
        _buildCoordinateItem(
          translate('lon'),
          locationService.currentPosition!.longitude.toStringAsFixed(6),
          settings,
        ),
      ],
    );
  }

  Widget _buildScrollableLocationText(LocationService locationService, SettingsService settings) {
    if (locationService.isLoading) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  settings.getTextColor(opacity: 0.7),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              translate('loading_location'),
              style: TextStyle(
                color: settings.getTextColor(opacity: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (locationService.errorMessage != null) {
      return Center(
        child: GestureDetector(
          onTap: () => locationService.refreshLocation(),
          child: Text(
            locationService.errorMessage!,
            style: TextStyle(
              color: Colors.red.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    if (locationService.currentAddress == null) {
      return Center(
        child: Text(
          translate('searching_location'),
          style: TextStyle(
            color: settings.getTextColor(opacity: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return _AutoScrollingText(
      text: locationService.currentAddress!,
      style: TextStyle(
        color: settings.getTextColor(opacity: 0.85),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildNoLocationCard(LocationService locationService, SettingsService settings) {
    if (locationService.isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                settings.getTextColor(opacity: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            translate('acquiring_gps'),
            style: TextStyle(
              color: settings.getTextColor(opacity: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    if (locationService.errorMessage != null) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                color: Colors.red.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              // FIX: Changed Expanded to Flexible here. Expanded requires a fully
              // bounded parent, but this Row sits inside a Column inside a Padding
              // inside a Stack — the Stack doesn't constrain width the same way a
              // Row/Column flex layout does, causing the ParentDataWidget error.
              // Flexible works correctly in this context.
              Flexible(
                child: Text(
                  locationService.errorMessage!,
                  style: TextStyle(
                    color: Colors.red.withOpacity(0.9),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => locationService.refreshLocation(),
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(translate('retry')),
            style: ElevatedButton.styleFrom(
              backgroundColor: settings.getIconColor(opacity: 0.2),
              foregroundColor: settings.getIconColor(opacity: 1.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.location_searching,
          color: settings.getIconColor(opacity: 0.6),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          translate('searching_gps'),
          style: TextStyle(
            color: settings.getTextColor(opacity: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCoordinateItem(String label, String value, SettingsService settings) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: settings.getTextColor(opacity: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: settings.getTextColor(opacity: 1.0),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _AutoScrollingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration pauseDuration;
  final Duration scrollDuration;

  const _AutoScrollingText({
    Key? key,
    required this.text,
    this.style,
    this.pauseDuration = const Duration(seconds: 2),
    this.scrollDuration = const Duration(seconds: 6),
  }) : super(key: key);

  @override
  State<_AutoScrollingText> createState() => _AutoScrollingTextState();
}

class _AutoScrollingTextState extends State<_AutoScrollingText> {
  late ScrollController _scrollController;
  bool _isScrolling = false;
  bool _shouldScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollNeeded();
    });
  }

  @override
  void didUpdateWidget(_AutoScrollingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _isScrolling = false;
      _scrollController.jumpTo(0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfScrollNeeded();
      });
    }
  }

  void _checkIfScrollNeeded() {
    if (!mounted) return;

    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final containerWidth = context.size?.width ?? 0;
    final textWidth = textPainter.width;

    setState(() {
      _shouldScroll = textWidth > containerWidth;
    });

    if (_shouldScroll && !_isScrolling) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() async {
    if (!mounted || !_shouldScroll) return;
    _isScrolling = true;

    await Future.delayed(widget.pauseDuration);

    while (mounted && _isScrolling && _shouldScroll) {
      try {
        if (_scrollController.hasClients) {
          await _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: widget.scrollDuration,
            curve: Curves.linear,
          );
        }
        if (!mounted) break;

        await Future.delayed(widget.pauseDuration);
        if (!mounted) break;

        if (_scrollController.hasClients) {
          await _scrollController.animateTo(
            0,
            duration: widget.scrollDuration,
            curve: Curves.linear,
          );
        }
        if (!mounted) break;

        await Future.delayed(widget.pauseDuration);
      } catch (e) {
        break;
      }
    }
  }

  @override
  void dispose() {
    _isScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldScroll) {
      return Center(
        child: Text(
          widget.text,
          style: widget.style,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(
          widget.text,
          style: widget.style,
          maxLines: 1,
        ),
      ),
    );
  }
}