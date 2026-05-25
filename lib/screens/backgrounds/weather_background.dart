import 'package:flutter/material.dart';
import 'dart:math' as math;

class WeatherBackground extends StatefulWidget {
  final Widget child;

  const WeatherBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB),
            Color(0xFF4A90E2),
            Color(0xFF2E5266),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated clouds
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _CloudsPainter(_controller.value),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _CloudsPainter extends CustomPainter {
  final double animation;

  _CloudsPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Draw multiple clouds
    _drawCloud(canvas, size, Offset(size.width * 0.2 + animation * 100, size.height * 0.15), 80, paint);
    _drawCloud(canvas, size, Offset(size.width * 0.6 + animation * 80, size.height * 0.25), 100, paint);
    _drawCloud(canvas, size, Offset(size.width * 0.4 + animation * 120, size.height * 0.35), 70, paint);
  }

  void _drawCloud(Canvas canvas, Size size, Offset center, double radius, Paint paint) {
    // Wrap around screen
    final x = center.dx % (size.width + radius * 2) - radius;
    
    canvas.drawCircle(Offset(x, center.dy), radius, paint);
    canvas.drawCircle(Offset(x + radius * 0.7, center.dy - radius * 0.3), radius * 0.8, paint);
    canvas.drawCircle(Offset(x - radius * 0.7, center.dy - radius * 0.2), radius * 0.7, paint);
  }

  @override
  bool shouldRepaint(_CloudsPainter oldDelegate) => true;
}