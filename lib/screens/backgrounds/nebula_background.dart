import 'package:flutter/material.dart';
import 'dart:math' as math;

class NebulaBackground extends StatefulWidget {
  final Widget child;

  const NebulaBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NebulaBackground> createState() => _NebulaBackgroundState();
}

class _NebulaBackgroundState extends State<NebulaBackground>
    with TickerProviderStateMixin {
  // Very slow cloud drift — 3 minutes per cycle
  late AnimationController _cloudController;
  // Ultra-slow star twinkle — 20 seconds per cycle
  late AnimationController _twinkleController;
  // Gentle sway — 25 seconds per cycle
  late AnimationController _swayController;
  // Slow background hue pulse — 40 seconds per cycle
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _cloudController = AnimationController(
      duration: const Duration(seconds: 180),
      vsync: this,
    )..repeat();

    _twinkleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _swayController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 40),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _twinkleController.dispose();
    _swayController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Slowly breathing background gradient
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final pulse = (math.sin(_pulseController.value * 2 * math.pi) + 1) / 2;
            // Gently shifts between deep purple and near-black
            final centerColor = Color.lerp(
              const Color(0xFF1A0F2E),
              const Color(0xFF110820),
              pulse * 0.4,
            )!;
            final midColor = Color.lerp(
              const Color(0xFF0F0320),
              const Color(0xFF080115),
              pulse * 0.3,
            )!;

            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(
                    0.3 + math.sin(_pulseController.value * 2 * math.pi) * 0.08,
                    -0.2 + math.cos(_pulseController.value * 2 * math.pi) * 0.06,
                  ),
                  radius: 1.5,
                  colors: [
                    centerColor,
                    midColor,
                    const Color(0xFF000000),
                  ],
                ),
              ),
            );
          },
        ),

        // Animated nebula clouds
        AnimatedBuilder(
          animation: Listenable.merge([_cloudController, _swayController]),
          builder: (context, _) {
            return RepaintBoundary(
              child: CustomPaint(
                painter: NebulaPainter(
                  progress: _cloudController.value,
                  swayProgress: _swayController.value,
                ),
                isComplex: true,
                willChange: true,
              ),
            );
          },
        ),

        // Twinkling stars
        AnimatedBuilder(
          animation: _twinkleController,
          builder: (context, _) {
            return RepaintBoundary(
              child: CustomPaint(
                painter: TwinklingStarsPainter(
                  time: _twinkleController.value,
                ),
                isComplex: true,
                willChange: true,
              ),
            );
          },
        ),

        widget.child,
      ],
    );
  }
}

class NebulaPainter extends CustomPainter {
  final double progress;
  final double swayProgress;

  NebulaPainter({
    required this.progress,
    required this.swayProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || !size.height.isFinite ||
        size.width <= 0 || size.height <= 0) return;

    // Three layers: far (slow, large, faint), mid, near (faster, smaller, slightly brighter)
    // All kept very soft and transparent — nothing harsh
    final layers = [
      {'speed': 0.15, 'opacity': 0.09, 'count': 5, 'baseSize': 220.0, 'blur': 55.0},
      {'speed': 0.25, 'opacity': 0.07, 'count': 6, 'baseSize': 160.0, 'blur': 45.0},
      {'speed': 0.40, 'opacity': 0.06, 'count': 7, 'baseSize': 120.0, 'blur': 38.0},
    ];

    // Very muted nebula palette — low saturation so colours blend gently
    const colors = [
      Color(0xFFB03060), // Muted rose
      Color(0xFF7B52AB), // Soft purple
      Color(0xFF3A6EA8), // Muted blue
      Color(0xFFAA3E7A), // Dusty pink
      Color(0xFF5A4E9F), // Slate indigo
      Color(0xFF8A4FAF), // Lavender
    ];

    for (var layerIndex = 0; layerIndex < layers.length; layerIndex++) {
      final layer = layers[layerIndex];
      final layerSpeed = layer['speed'] as double;
      final maxOpacity = layer['opacity'] as double;
      final cloudCount = layer['count'] as int;
      final baseCloudSize = layer['baseSize'] as double;
      final blurSigma = layer['blur'] as double;

      final layerProgress = (progress * layerSpeed) % 1.0;
      // Very gentle sway — reduced amplitude
      final swayOffset = math.sin(swayProgress * 2 * math.pi) * 18;

      for (int i = 0; i < cloudCount; i++) {
        final seedOffset = i * 100 + layerIndex * 1000;
        final rng = math.Random(555 + seedOffset);

        final baseX = rng.nextDouble() * size.width * 1.4 - size.width * 0.2;
        final baseY = rng.nextDouble() * size.height * 1.4 - size.height * 0.2;

        final driftAmount = layerProgress * size.width * 0.35;
        final x = (baseX + driftAmount) % (size.width * 1.4) - size.width * 0.2;

        final swayVariation = math.sin((i / cloudCount.toDouble()) * 2 * math.pi);
        final y = baseY + swayOffset * swayVariation * (layerIndex + 1) * 0.2;

        final sizeVariation = rng.nextDouble() * 0.5 + 0.75;
        final cloudSize = baseCloudSize * sizeVariation;

        // Opacity variation kept narrow so nothing jumps out
        final opacityVariation = rng.nextDouble() * 0.3 + 0.7;
        final opacity = maxOpacity * opacityVariation;

        final color = colors[rng.nextInt(colors.length)];

        if (!x.isFinite || !y.isFinite || !cloudSize.isFinite) continue;

        final paint = Paint()
          ..shader = RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(opacity * 0.4),
              color.withOpacity(0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(
            center: Offset(x, y),
            radius: cloudSize,
          ))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

        canvas.drawCircle(Offset(x, y), cloudSize, paint);

        // Occasional soft sub-cloud — very infrequent
        if (rng.nextDouble() > 0.80) {
          final detailSize = cloudSize * 0.30;
          final detailX = x + (rng.nextDouble() - 0.5) * cloudSize * 0.5;
          final detailY = y + (rng.nextDouble() - 0.5) * cloudSize * 0.5;

          if (!detailX.isFinite || !detailY.isFinite || !detailSize.isFinite) continue;

          final detailPaint = Paint()
            ..shader = RadialGradient(
              colors: [
                color.withOpacity(opacity * 0.5),
                color.withOpacity(0),
              ],
            ).createShader(Rect.fromCircle(
              center: Offset(detailX, detailY),
              radius: detailSize,
            ))
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma * 0.5);

          canvas.drawCircle(Offset(detailX, detailY), detailSize, detailPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(NebulaPainter oldDelegate) {
    return (oldDelegate.progress - progress).abs() > 0.0005 ||
        (oldDelegate.swayProgress - swayProgress).abs() > 0.0005;
  }
}

class TwinklingStarsPainter extends CustomPainter {
  final double time;

  TwinklingStarsPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || !size.height.isFinite ||
        size.width <= 0 || size.height <= 0) return;

    final random = math.Random(999);

    for (int i = 0; i < 90; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      if (!x.isFinite || !y.isFinite) continue;

      final starPhase = (i % 30) / 30.0;
      // Very slow individual twinkle rates
      final twinkleSpeed = 0.25 + (i % 7) * 0.05;
      final twinkleValue = (time * twinkleSpeed + starPhase) % 1.0;
      // Smooth sine wave — no harsh flicker
      final brightness = (math.sin(twinkleValue * 2 * math.pi) + 1) / 2;

      final baseSizeRand = random.nextDouble();
      final baseSize = baseSizeRand < 0.75
          ? random.nextDouble() * 1.2 + 0.3  // Tiny stars
          : random.nextDouble() * 1.8 + 1.2; // Occasional slightly larger star

      // Very subtle size breathing — barely perceptible
      final starSize = baseSize * (0.85 + brightness * 0.15);
      // Opacity stays relatively high so stars don't disappear fully
      final opacity = 0.45 + brightness * 0.45;

      if (!starSize.isFinite || !opacity.isFinite) continue;

      // Subtle colour tinting on a minority of stars
      Color starColor = Colors.white;
      if (baseSizeRand > 0.88) {
        final tints = [
          const Color(0xFFFFFAF0), // Warm white
          const Color(0xFFEEF4FF), // Cool white
          const Color(0xFFFFF0F5), // Rose white
        ];
        starColor = tints[i % tints.length];
      }

      final paint = Paint()..color = starColor.withOpacity(opacity);

      // Very soft glow only on brightest moments
      if (brightness > 0.80) {
        final glowPaint = Paint()
          ..color = starColor.withOpacity(opacity * 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), starSize * 2.2, glowPaint);
      }

      canvas.drawCircle(Offset(x, y), starSize, paint);

      // Subtle cross flare only on the very largest, brightest stars
      if (brightness > 0.92 && baseSize > 2.2) {
        final flarePaint = Paint()
          ..color = starColor.withOpacity(opacity * 0.35)
          ..strokeWidth = 0.35
          ..style = PaintingStyle.stroke;

        final flareLength = starSize * 2.2;
        if (flareLength.isFinite) {
          canvas.drawLine(Offset(x - flareLength, y), Offset(x + flareLength, y), flarePaint);
          canvas.drawLine(Offset(x, y - flareLength), Offset(x, y + flareLength), flarePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(TwinklingStarsPainter oldDelegate) {
    return (oldDelegate.time - time).abs() > 0.005;
  }
}