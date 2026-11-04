import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/brand_loader.dart';
import 'home_screen.dart';
import 'language_selector_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minDuration = Duration(milliseconds: 2200);
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
      const AssetImage('assets/images/compass-icon-professional.png'),
      context,
    );
  }

  Future<void> _start() async {
    final started = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final seenLanguage = prefs.getBool('has_seen_language_selector') ?? false;
    final language = prefs.getString('language') ?? 'en';

    final remaining = _minDuration - DateTime.now().difference(started);
    if (remaining > Duration.zero) await Future.delayed(remaining);

    if (!mounted || _navigated) return;
    _navigated = true;

    final Widget next = seenLanguage
        ? const HomeScreen()
        : LanguageSelectorScreen(currentLanguage: language, isFirstLaunch: true);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const BrandLoader();
  }
}