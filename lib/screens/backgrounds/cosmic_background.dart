import 'package:flutter/material.dart';
import 'dart:math' as math;

class CosmicBackground extends StatefulWidget {
  final Widget child;

  const CosmicBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with TickerProviderStateMixin {
  late AnimationController _driftController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _driftController = AnimationController(
      duration: const Duration(seconds: 40),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _driftController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0E27), // Deep blue
            Color(0xFF1A1147), // Purple-blue
            Color(0xFF0D0221), // Deep purple
          ],
        ),
      ),
      child: Stack(
        children: [
          // Drifting cosmic particles
          AnimatedBuilder(
            animation: _driftController,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: CosmicParticlesPainter(
                  progress: _driftController.value,
                ),
              );
            },
          ),
          // Pulsing stars
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: PulsingStarsPainter(
                  pulse: _pulseController.value,
                ),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class CosmicParticlesPainter extends CustomPainter {
  final double progress;

  CosmicParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    
    for (int i = 0; i < 80; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = random.nextDouble() * 0.5 + 0.3;
      
      // Drift particles diagonally
      final offsetX = (progress * speed * size.width) % size.width;
      final offsetY = (progress * speed * size.height * 0.5) % size.height;
      
      final x = (baseX + offsetX) % size.width;
      final y = (baseY + offsetY) % size.height;
      
      final particleSize = random.nextDouble() * 3 + 1;
      final opacity = random.nextDouble() * 0.4 + 0.2;
      
      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFF4A90E2), // Blue
          const Color(0xFFB19CD9), // Light purple
          random.nextDouble(),
        )!.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(CosmicParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class PulsingStarsPainter extends CustomPainter {
  final double pulse;

  PulsingStarsPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(789);
    
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      
      // Each star pulses at a slightly different phase
      final phase = (i % 10) / 10.0;
      final pulseValue = ((pulse + phase) % 1.0);
      final intensity = (math.sin(pulseValue * 2 * math.pi) + 1) / 2;
      
      final baseSize = random.nextDouble() * 1.5 + 0.5;
      final starSize = baseSize * (0.7 + intensity * 0.6);
      final opacity = 0.3 + intensity * 0.5;
      
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(PulsingStarsPainter oldDelegate) {
    return oldDelegate.pulse != pulse;
  }
}