import 'package:flutter/material.dart';
import 'dart:math' as math;

class GalaxyBackground extends StatefulWidget {
  final Widget child;

  const GalaxyBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<GalaxyBackground> createState() => _GalaxyBackgroundState();
}

class _GalaxyBackgroundState extends State<GalaxyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFF1A0033), // Deep purple center
            Color(0xFF0D001A), // Darker purple
            Color(0xFF000000), // Black edges
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated spiral galaxy arms
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: GalaxyPainter(
                  rotation: _controller.value * 2 * math.pi,
                ),
              );
            },
          ),
          // Static stars layer
          CustomPaint(
            size: Size.infinite,
            painter: StarFieldPainter(seed: 12345),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class GalaxyPainter extends CustomPainter {
  final double rotation;

  GalaxyPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.8;

    // Draw multiple spiral arms
    for (int arm = 0; arm < 4; arm++) {
      final armAngle = (arm * math.pi / 2) + rotation;
      
      for (int i = 0; i < 100; i++) {
        final t = i / 100.0;
        final radius = t * maxRadius;
        final angle = armAngle + t * 4 * math.pi;
        
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        final opacity = (1 - t) * 0.6;
        final size = (1 - t) * 3 + 1;
        
        final paint = Paint()
          ..color = Color.lerp(
            const Color(0xFF9D4EDD), // Purple
            const Color(0xFF3C096C), // Deep purple
            t,
          )!.withOpacity(opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        
        canvas.drawCircle(Offset(x, y), size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(GalaxyPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}

class StarFieldPainter extends CustomPainter {
  final int seed;

  StarFieldPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint()..color = Colors.white;

    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 2 + 0.5;
      final opacity = random.nextDouble() * 0.8 + 0.2;

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) => false;
}