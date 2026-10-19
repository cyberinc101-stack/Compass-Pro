import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/location_service.dart';
import '../../services/weather_service.dart';
import '../../services/settings_service.dart';
import '../../services/localization_service.dart';
import '../../services/premium_service.dart';
import '../../utils/unit_converter_helper.dart';
import 'widgets/weather_header.dart';
import 'widgets/animated_weather_display.dart';
import 'utils/weather_gradients.dart';

class WeatherScreen extends StatefulWidget {
  final VoidCallback? onBackToCompass;

  const WeatherScreen({Key? key, this.onBackToCompass}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _weatherData;
  final WeatherService _weatherService = WeatherService();

  String? _selectedLocationName;
  double? _selectedLatitude;
  double? _selectedLongitude;

  late AnimationController _floatController;
  late AnimationController _pulseController;

  String translate(String key) => LocalizationService.translate(key);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _selectedLocationName = translate('loading');
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWeatherData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localization = Provider.of<LocalizationService>(context, listen: false);
    final locationService = Provider.of<LocationService>(context, listen: false);
    if (locationService.currentLanguage != localization.currentLanguage) {
      locationService.setLanguage(localization.currentLanguage);
    }
  }

  void _setupAnimations() {
    _floatController = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    setState(() => _isLoading = true);
    try {
      final locationService =
          Provider.of<LocationService>(context, listen: false);
      double? latitude;
      double? longitude;

      if (_selectedLatitude != null && _selectedLongitude != null) {
        latitude = _selectedLatitude;
        longitude = _selectedLongitude;
      } else if (locationService.currentPosition != null) {
        latitude = locationService.currentPosition!.latitude;
        longitude = locationService.currentPosition!.longitude;
      } else {
        await locationService.getCurrentLocation();
        if (locationService.currentPosition != null) {
          latitude = locationService.currentPosition!.latitude;
          longitude = locationService.currentPosition!.longitude;
        } else if (locationService.errorMessage != null) {
          setState(() {
            _isLoading = false;
            _selectedLocationName = translate('location_unavailable');
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(locationService.errorMessage!),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                  label: translate('settings'),
                  textColor: Colors.white,
                  onPressed: () => locationService.openAppSettings()),
            ));
          }
          return;
        }
      }

      if (latitude != null && longitude != null) {
        final data = await _weatherService.getWeather(latitude, longitude);
        setState(() {
          _weatherData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _selectedLocationName = translate('location_unavailable');
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _selectedLocationName = translate('error_loading_weather');
      });
    }
  }

  Future<void> _showLocationSearchDialog() async {
    final settings = Provider.of<SettingsService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => LocationSearchDialog(
        onLocationSelected: (name, lat, lng) {
          setState(() {
            _selectedLocationName = name;
            _selectedLatitude = lat;
            _selectedLongitude = lng;
          });
          _loadWeatherData();
        },
        weatherService: _weatherService,
        settings: settings,
      ),
    );
  }

  void _useCurrentLocation() {
    setState(() {
      _selectedLocationName = null;
      _selectedLatitude = null;
      _selectedLongitude = null;
    });
    _loadWeatherData();
  }

  bool _isDay() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 20;
  }

  void _showUpgradeSheet(BuildContext context, SettingsService settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeatherUpgradeSheet(settings: settings),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    final settings = Provider.of<SettingsService>(context);
    final premium = Provider.of<PremiumService>(context);

    final weatherCode =
        (_weatherData?['current']?['weather_code'] as num?)?.toInt();
    final isDay = _isDay();

    final displayLocationName =
        (_selectedLatitude == null && _selectedLongitude == null)
            ? (locationService.currentAddress ?? translate('current_location'))
            : (_selectedLocationName ?? translate('loading'));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: WeatherGradients.getWeatherGradient(
                weatherCode, isDay, settings.iconThemeMode),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: settings.getIconColor(opacity: 1.0)))
                  : _weatherData == null
                      ? _buildNoDataState(settings)
                      : RefreshIndicator(
                          onRefresh: _loadWeatherData,
                          color: settings.getIconColor(opacity: 1.0),
                          backgroundColor:
                              settings.iconThemeMode == 'night'
                                  ? const Color(0xFF21262D)
                                  : Colors.black45,
                          child: ListView(
                            padding:
                                const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            physics: const BouncingScrollPhysics(),
                            children: [
                              const SizedBox(height: 10),
                              WeatherHeader(
                                locationName: displayLocationName,
                                hasWeatherData: _weatherData != null,
                                isCurrentLocation: _selectedLatitude == null &&
                                    _selectedLongitude == null,
                                onUseCurrentLocation: _useCurrentLocation,
                                onSearchLocation: _showLocationSearchDialog,
                              ),
                              const SizedBox(height: 30),
                              AnimatedWeatherDisplay(
                                weatherData: _weatherData!,
                                weatherCode: weatherCode,
                                isDay: isDay,
                                weatherService: _weatherService,
                                floatController: _floatController,
                                pulseController: _pulseController,
                                temperatureUnit: settings.temperatureUnit,
                              ),
                              const SizedBox(height: 30),

                              // ── FREE: humidity + precip ──────────────────
                              _buildTemperatureCard(settings),
                              const SizedBox(height: 20),

                              // ── FREE: wind speed + direction ─────────────
                              _buildWindCard(settings),
                              const SizedBox(height: 20),

                              // ── FREE: sunrise + sunset ───────────────────
                              _buildSunMoonCard(settings),
                              const SizedBox(height: 20),

                              // ── LOCKED: pressure + cloud cover ───────────
                              _buildLockedOrVisible(
                                context: context,
                                settings: settings,
                                premium: premium,
                                child: _buildPressureCloudCard(settings),
                              ),
                              const SizedBox(height: 20),

                              // ── LOCKED: hourly forecast ──────────────────
                              _buildLockedOrVisible(
                                context: context,
                                settings: settings,
                                premium: premium,
                                child: _buildHourlyForecast(settings),
                                lockLabel: translate('hourly_forecast'),
                              ),
                              const SizedBox(height: 20),

                              // ── LOCKED: 7-day forecast ───────────────────
                              _buildLockedOrVisible(
                                context: context,
                                settings: settings,
                                premium: premium,
                                child: _build7DayForecast(settings),
                                lockLabel: translate('seven_day_forecast'),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),

              // Back button
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
                            width: 1),
                      ),
                      child: Icon(Icons.arrow_back,
                          color: settings.getIconColor(), size: 24),
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

  /// Wraps [child] in a blur+lock overlay when user is not premium.
  Widget _buildLockedOrVisible({
    required BuildContext context,
    required SettingsService settings,
    required PremiumService premium,
    required Widget child,
    String? lockLabel,
  }) {
    if (premium.isPremium) return child;

    return GestureDetector(
      onTap: () => _showUpgradeSheet(context, settings),
      child: Stack(
        children: [
          // Blurred content — user can see shape but not data
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Opacity(opacity: 0.4, child: child),
          ),
          // Lock card overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                    color: settings.getIconColor(opacity: 0.3), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_rounded,
                      color: settings.getIconColor(opacity: 0.9), size: 28),
                  const SizedBox(height: 8),
                  if (lockLabel != null)
                    Text(lockLabel,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Pro only — tap to upgrade',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FREE cards ─────────────────────────────────────────────────────────────

  Widget _buildTemperatureCard(SettingsService settings) {
    if (_weatherData == null) return const SizedBox();
    final humidity =
        (_weatherData!['current']['relative_humidity_2m'] as num?)?.round() ??
            0;
    final precipitation =
        (_weatherData!['current']['precipitation'] as num?)?.toDouble() ?? 0.0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            settings.getIconColor(opacity: 0.25),
            settings.getIconColor(opacity: 0.15)
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: settings.getIconColor(opacity: 0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickStat(Icons.water_drop_outlined, '$humidity%',
              translate('humidity'), settings),
          Container(
              width: 1, height: 40, color: settings.getIconColor(opacity: 0.3)),
          _buildQuickStat(
              Icons.umbrella_outlined,
              '$precipitation ${translate('mm')}',
              translate('precip'),
              settings),
        ],
      ),
    );
  }

  Widget _buildWindCard(SettingsService settings) {
    if (_weatherData == null) return const SizedBox();
    final windSpeedMS =
        (_weatherData!['current']['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
    final windDir =
        (_weatherData!['current']['wind_direction_10m'] as num?)?.toDouble() ??
            0.0;
    final convertedWindSpeed =
        UnitConverter.convertSpeed(windSpeedMS, settings.speedUnit);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          settings.getIconColor(opacity: 0.2),
          settings.getIconColor(opacity: 0.1),
        ]),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: settings.getIconColor(opacity: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
              child: _buildDetailItem(Icons.air, translate('wind_speed'),
                  '${convertedWindSpeed.toStringAsFixed(1)} ${settings.speedUnit}',
                  settings)),
          Expanded(
              child: _buildDetailItem(
                  Icons.navigation,
                  translate('wind_direction'),
                  _weatherService.getWindDirection(windDir),
                  settings)),
        ],
      ),
    );
  }

  // ── LOCKED cards ───────────────────────────────────────────────────────────

  Widget _buildPressureCloudCard(SettingsService settings) {
    if (_weatherData == null) return const SizedBox();
    final pressure =
        (_weatherData!['current']['pressure_msl'] as num?)?.toDouble() ?? 0.0;
    final cloudCover =
        (_weatherData!['current']['cloud_cover'] as num?)?.round() ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          settings.getIconColor(opacity: 0.2),
          settings.getIconColor(opacity: 0.1),
        ]),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: settings.getIconColor(opacity: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
              child: _buildDetailItem(
                  Icons.compress,
                  translate('pressure'),
                  '${pressure.round()} ${translate('hpa')}',
                  settings)),
          Expanded(
              child: _buildDetailItem(Icons.cloud_outlined,
                  translate('cloud_cover'), '$cloudCover%', settings)),
        ],
      ),
    );
  }

  Widget _buildSunMoonCard(SettingsService settings) {
    if (_weatherData == null) return const SizedBox();
    final daily = _weatherData!['daily'];
    final sunrise = daily['sunrise'][0].split('T')[1].substring(0, 5);
    final sunset = daily['sunset'][0].split('T')[1].substring(0, 5);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF9A56),
            Color(0xFFFF6B95),
            Color(0xFFB06AB3),
            Color(0xFF4568DC),
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        border:
            Border.all(color: settings.getIconColor(opacity: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFFF9A56).withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSunMoonItem(Icons.wb_twilight, translate('sunrise'), sunrise,
              const Color(0xFFFFB347), settings),
          Container(
            width: 2,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  settings.getIconColor(opacity: 0.6),
                  settings.getIconColor(opacity: 0.3),
                  settings.getIconColor(opacity: 0.6),
                ],
              ),
            ),
          ),
          _buildSunMoonItem(Icons.nightlight_round, translate('sunset'), sunset,
              const Color(0xFFFF6B9D), settings),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(SettingsService settings) {
    if (_weatherData == null) return const SizedBox();
    final hourly = _weatherData!['hourly'];
    final textColorLight = settings.getTextColor(opacity: 0.9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(translate('hourly_forecast'),
              style: TextStyle(
                  color: textColorLight,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 24,
            itemBuilder: (context, index) {
              final time = DateTime.parse(hourly['time'][index]);
              final tempCelsius =
                  (hourly['temperature_2m'][index] as num?)?.toDouble() ?? 0.0;
              final weatherCode =
                  (hourly['weather_code'][index] as num?)?.toInt() ?? 0;
              final precipitation =
                  (hourly['precipitation_probability'][index] as num?)
                          ?.toInt() ??
                      0;
              final convertedTemp = UnitConverter.convertTemperature(
                  tempCelsius, settings.temperatureUnit);
              return _buildHourlyCard(
                time.hour == 0
                    ? '12 ${translate('am')}'
                    : time.hour < 12
                        ? '${time.hour} ${translate('am')}'
                        : time.hour == 12
                            ? '12 ${translate('pm')}'
                            : '${time.hour - 12} ${translate('pm')}',
                convertedTemp,
                weatherCode,
                precipitation,
                settings.temperatureUnit,
                settings,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _build7DayForecast(SettingsService settings) {
    if (_weatherData == null) return const SizedBox();
    final daily = _weatherData!['daily'];
    final textColor = settings.getTextColor(opacity: 1.0);
    final textColorLight = settings.getTextColor(opacity: 0.9);
    final textColorMedium = settings.getTextColor(opacity: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(translate('seven_day_forecast'),
              style: TextStyle(
                  color: textColorLight,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              settings.getIconColor(opacity: 0.2),
              settings.getIconColor(opacity: 0.1),
            ]),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: settings.getIconColor(opacity: 0.3)),
          ),
          child: Column(
            children: List.generate(7, (index) {
              final date = DateTime.parse(daily['time'][index]);
              final weatherCode =
                  (daily['weather_code'][index] as num?)?.toInt() ?? 0;
              final maxTempC =
                  (daily['temperature_2m_max'][index] as num?)?.toDouble() ??
                      0.0;
              final minTempC =
                  (daily['temperature_2m_min'][index] as num?)?.toDouble() ??
                      0.0;
              final precipProb =
                  (daily['precipitation_probability_max'][index] as num?)
                          ?.toInt() ??
                      0;
              final maxTemp = UnitConverter.convertTemperature(
                  maxTempC, settings.temperatureUnit);
              final minTemp = UnitConverter.convertTemperature(
                  minTempC, settings.temperatureUnit);
              final tempSymbol =
                  settings.temperatureUnit == 'Kelvin' ? ' K' : '°';

              String dayName;
              if (index == 0) {
                dayName = translate('today');
              } else if (index == 1) {
                dayName = translate('tomorrow');
              } else {
                const map = {
                  DateTime.monday: 'mon',
                  DateTime.tuesday: 'tue',
                  DateTime.wednesday: 'wed',
                  DateTime.thursday: 'thu',
                  DateTime.friday: 'fri',
                  DateTime.saturday: 'sat',
                  DateTime.sunday: 'sun',
                };
                dayName = translate(map[date.weekday] ?? 'sun');
              }

              return Column(
                children: [
                  if (index > 0)
                    Divider(
                        color: settings.getIconColor(opacity: 0.24),
                        height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 80,
                            child: Text(dayName,
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500))),
                        const Spacer(),
                        if (precipProb > 0) ...[
                          Icon(Icons.water_drop,
                              size: 16, color: Colors.lightBlue[200]),
                          const SizedBox(width: 4),
                          SizedBox(
                              width: 35,
                              child: Text('$precipProb%',
                                  style: TextStyle(
                                      color: Colors.lightBlue[200],
                                      fontSize: 13))),
                        ] else
                          const SizedBox(width: 55),
                        const SizedBox(width: 12),
                        Text(_weatherService.getWeatherEmoji(weatherCode),
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('${maxTemp.round()}$tempSymbol',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text('${minTemp.round()}$tempSymbol',
                                  style: TextStyle(
                                      color: textColorMedium, fontSize: 18)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  Widget _buildNoDataState(SettingsService settings) {
    final textColor = settings.getTextColor(opacity: 1.0);
    final textColorLight = settings.getTextColor(opacity: 0.7);
    final iconColor = settings.getIconColor(opacity: 1.0);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 100, color: iconColor.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(translate('no_weather_data'),
                style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(translate('enable_location_or_search'),
                style: TextStyle(color: textColorLight, fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showLocationSearchDialog,
              icon: const Icon(Icons.search),
              label: Text(translate('search_location')),
              style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor.withOpacity(0.2),
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadWeatherData,
              icon: const Icon(Icons.refresh),
              label: Text(translate('try_again')),
              style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor.withOpacity(0.2),
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(
      IconData icon, String value, String label, SettingsService settings) {
    final textColor = settings.getTextColor(opacity: 1.0);
    final textColorLight = settings.getTextColor(opacity: 0.8);
    return Column(
      children: [
        Icon(icon, color: textColor, size: 32),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: textColorLight, fontSize: 14)),
      ],
    );
  }

  Widget _buildDetailItem(
      IconData icon, String label, String value, SettingsService settings) {
    final textColor = settings.getTextColor(opacity: 1.0);
    final textColorLight = settings.getTextColor(opacity: 0.7);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Icon(icon, color: textColor.withOpacity(0.9), size: 28),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(color: textColorLight, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSunMoonItem(IconData icon, String label, String time,
      Color color, SettingsService settings) {
    final textColor = settings.getTextColor(opacity: 1.0);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              color.withOpacity(0.4),
              color.withOpacity(0.2),
              Colors.transparent,
            ]),
          ),
          child: Icon(icon, color: textColor, size: 42, shadows: [
            Shadow(color: color.withOpacity(0.6), blurRadius: 12),
            const Shadow(
                color: Colors.black26,
                offset: Offset(2, 2),
                blurRadius: 4),
          ]),
        ),
        const SizedBox(height: 12),
        Text(label,
            style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                shadows: const [
                  Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 3)
                ])),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: settings.getIconColor(opacity: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: settings.getIconColor(opacity: 0.3)),
          ),
          child: Text(time,
              style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  shadows: const [
                    Shadow(
                        color: Colors.black38,
                        offset: Offset(1, 1),
                        blurRadius: 3)
                  ])),
        ),
      ],
    );
  }

  Widget _buildHourlyCard(String time, num temp, int weatherCode,
      int precipitation, String tempUnit, SettingsService settings) {
    final tempSymbol = tempUnit == 'Kelvin' ? ' K' : '°';
    final textColor = settings.getTextColor(opacity: 1.0);
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            settings.getIconColor(opacity: 0.25),
            settings.getIconColor(opacity: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: settings.getIconColor(opacity: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(time,
              style: TextStyle(
                  color: textColor, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(_weatherService.getWeatherEmoji(weatherCode),
              style: const TextStyle(fontSize: 28)),
          Text('${temp.round()}$tempSymbol',
              style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          if (precipitation > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.water_drop, size: 12, color: Colors.lightBlue[200]),
                const SizedBox(width: 2),
                Text('$precipitation%',
                    style: TextStyle(
                        color: Colors.lightBlue[200], fontSize: 11)),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Weather-specific upgrade sheet ──────────────────────────────────────────
class _WeatherUpgradeSheet extends StatefulWidget {
  final SettingsService settings;
  const _WeatherUpgradeSheet({required this.settings});

  @override
  State<_WeatherUpgradeSheet> createState() => _WeatherUpgradeSheetState();
}

class _WeatherUpgradeSheetState extends State<_WeatherUpgradeSheet> {
  bool _isLoading = false;
  String _selected = 'yearly';

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumService>();
    final iconColor = widget.settings.getIconColor(opacity: 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Icon(Icons.bar_chart_rounded, color: iconColor, size: 40),
          const SizedBox(height: 12),
          const Text('Unlock Full Weather',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Hourly forecast  •  7-day forecast\nPressure  •  Cloud cover  •  No ads',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.65), fontSize: 13),
          ),
          const SizedBox(height: 24),
          _buildPlanRow('\$2.99/mo', 'monthly', iconColor),
          const SizedBox(height: 10),
          _buildPlanRow('\$28.99/yr  •  Save 19%', 'yearly', iconColor,
              badge: 'BEST VALUE'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      final ok = _selected == 'monthly'
                          ? await premium.purchaseMonthly()
                          : await premium.purchaseYearly();
                      if (mounted) {
                        setState(() => _isLoading = false);
                        if (ok) Navigator.pop(context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : Text(
                      'Subscribe — ${_selected == 'monthly' ? '\$2.99/mo' : '\$28.99/yr'}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              await premium.restorePurchases();
              if (mounted) Navigator.pop(context);
            },
            child: Text('Restore Purchase',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanRow(String label, String plan, Color iconColor,
      {String? badge}) {
    final isSelected = _selected == plan;
    return GestureDetector(
      onTap: () => setState(() => _selected = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? iconColor.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? iconColor : Colors.white24,
              width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? iconColor : Colors.white38,
                size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(badge,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Location Search Dialog (unchanged) ──────────────────────────────────────
class LocationSearchDialog extends StatefulWidget {
  final Function(String name, double latitude, double longitude)
      onLocationSelected;
  final WeatherService weatherService;
  final SettingsService settings;

  const LocationSearchDialog({
    Key? key,
    required this.onLocationSelected,
    required this.weatherService,
    required this.settings,
  }) : super(key: key);

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  String translate(String key) => LocalizationService.translate(key);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await widget.weatherService.searchLocation(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  List<Color> _getDialogGradient(String themeMode) {
    switch (themeMode) {
      case 'glow':
        return [
          const Color(0xFF003355).withOpacity(0.95),
          const Color(0xFF004466).withOpacity(0.95),
        ];
      case 'night':
        return [
          const Color(0xFF21262D).withOpacity(0.95),
          const Color(0xFF1C1F26).withOpacity(0.95),
        ];
      default:
        return [
          const Color(0xFF4A90E2).withOpacity(0.95),
          const Color(0xFF357ABD).withOpacity(0.95),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = widget.settings.iconThemeMode;
    final textColor = widget.settings.getTextColor(opacity: 1.0);
    final textColorLight = widget.settings.getTextColor(opacity: 0.7);
    final iconColor = widget.settings.getIconColor(opacity: 1.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getDialogGradient(themeMode),
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: iconColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.search, color: iconColor, size: 28),
                  const SizedBox(width: 12),
                  Text(translate('search_location'),
                      style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: iconColor)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: iconColor.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: textColor, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: translate('enter_city_name'),
                    hintStyle: TextStyle(color: textColorLight),
                    prefixIcon: Icon(Icons.location_city,
                        color: iconColor.withOpacity(0.7)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (value) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_searchController.text == value) {
                        _performSearch(value);
                      }
                    });
                  },
                  onSubmitted: _performSearch,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: _isSearching
                  ? Center(
                      child: CircularProgressIndicator(color: iconColor))
                  : _searchResults.isEmpty
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.public,
                                  size: 64,
                                  color: iconColor.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                  _searchController.text.isEmpty
                                      ? translate('search_any_city')
                                      : translate('no_locations_found'),
                                  style: TextStyle(
                                      color: textColorLight, fontSize: 16),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          itemBuilder: (context, index) {
                            final location = _searchResults[index];
                            final name = location['name'] ?? '';
                            final country = location['country'] ?? '';
                            final admin1 = location['admin1'] ?? '';
                            String displayName = name;
                            if (admin1.isNotEmpty) displayName += ', $admin1';
                            if (country.isNotEmpty)
                              displayName += ', $country';
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: InkWell(
                                onTap: () {
                                  widget.onLocationSelected(displayName,
                                      location['latitude'],
                                      location['longitude']);
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: iconColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: iconColor.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: iconColor.withOpacity(0.9),
                                          size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(name,
                                                style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            if (admin1.isNotEmpty ||
                                                country.isNotEmpty)
                                              Text(
                                                  [admin1, country]
                                                      .where((s) =>
                                                          s.isNotEmpty)
                                                      .join(', '),
                                                  style: TextStyle(
                                                      color: textColorLight,
                                                      fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios,
                                          color: iconColor.withOpacity(0.5),
                                          size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
