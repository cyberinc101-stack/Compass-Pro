import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

/// Shared colours for splash, language selector and the home init screen.
class BrandPalette {
  final Color top;
  final Color bottom;
  final Color accent;
  final Color text;
  final bool light;

  const BrandPalette(this.top, this.bottom, this.accent, this.text, this.light);

  static BrandPalette forMode(String? mode) {
    switch (mode) {
      case 'glow':
        return const BrandPalette(Color(0xFF001A15), Color(0xFF004438),
            Color(0xFF00FFCC), Color(0xFFD5FFF5), false);
      case 'night':
        return const BrandPalette(Color(0xFF0A0000), Color(0xFF3A0A0A),
            Color(0xFFFF8888), Color(0xFFFFE0E0), false);
      default:
        return const BrandPalette(Color(0xFF2F6FD0), Color(0xFF63B3ED),
            Colors.white, Colors.white, true);
    }
  }
}

/// Branded full-screen loader. Used by the splash and by Home while it
/// initialises, so the two look like one continuous screen.
class BrandLoader extends StatefulWidget {
  final String? status;
  final bool animateIn;

  const BrandLoader({Key? key, this.status, this.animateIn = true})
      : super(key: key);

  @override
  State<BrandLoader> createState() => _BrandLoaderState();
}

class _BrandLoaderState extends State<BrandLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<SettingsService>().iconThemeMode;
    final p = BrandPalette.forMode(mode);

    return Scaffold(
      backgroundColor: p.top,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.top, p.bottom],
          ),
        ),
        child: SafeArea(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: widget.animateIn ? 0.0 : 1.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
            ),
            child: Column(
              children: [
                const Spacer(flex: 3),
                SizedBox(
                  width: 230,
                  height: 230,
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (context, _) {
                      final breathe =
                          1 + 0.025 * math.sin(_c.value * 2 * math.pi);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: _c.value * 2 * math.pi,
                            child: CustomPaint(
                              size: const Size(230, 230),
                              painter: _RingPainter(p.accent),
                            ),
                          ),
                          Transform.scale(
                            scale: breathe,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: p.accent
                                        .withOpacity(p.light ? 0.25 : 0.35),
                                    blurRadius: 40,
                                    spreadRadius: 4,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/compass-icon-professional.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'Compass Safe Pro',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: p.text,
                    letterSpacing: 1.2,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                SizedBox(
                  height: 20,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      widget.status ?? '',
                      key: ValueKey(widget.status),
                      style: TextStyle(
                        color: p.text.withOpacity(0.75),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 160,
                    height: 3,
                    child: LinearProgressIndicator(
                      backgroundColor: p.accent.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(p.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  _RingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;

    for (int i = 0; i < 60; i++) {
      final a = i * 6 * math.pi / 180;
      final long = i % 5 == 0;
      final inner = r - (long ? 12 : 7);
      canvas.drawLine(
        Offset(c.dx + inner * math.sin(a), c.dy - inner * math.cos(a)),
        Offset(c.dx + r * math.sin(a), c.dy - r * math.cos(a)),
        Paint()
          ..color = color.withOpacity(long ? 0.7 : 0.3)
          ..strokeWidth = long ? 2.5 : 1.5
          ..strokeCap = StrokeCap.round,
      );
    }

    final rect = Rect.fromCircle(center: c, radius: r - 18);
    canvas.drawArc(
      rect,
      0,
      math.pi * 1.2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0.0,
          endAngle: math.pi * 1.2,
          colors: [color.withOpacity(0.0), color],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.color != color;
}