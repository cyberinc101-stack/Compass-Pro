import 'package:flutter/material.dart';
import 'dart:math' as math;

class NightSkyBackground extends StatefulWidget {
  final Widget child;

  const NightSkyBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NightSkyBackground> createState() => _NightSkyBackgroundState();
}

class _NightSkyBackgroundState extends State<NightSkyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Generate random stars
    final random = math.Random(42);
    stars = List.generate(100, (index) {
      return Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 1,
        opacity: random.nextDouble() * 0.5 + 0.5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF000428),
            Color(0xFF004e92),
          ],
        ),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _StarsPainter(stars, _controller.value),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double opacity;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
  });
}

class _StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double animation;

  _StarsPainter(this.stars, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = (math.sin(animation * 2 * math.pi + star.x * 10) + 1) / 2;
      final paint = Paint()
        ..color = Colors.white.withOpacity(star.opacity * twinkle)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter oldDelegate) => true;
}