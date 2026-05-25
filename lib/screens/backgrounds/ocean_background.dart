import 'package:flutter/material.dart';
import 'dart:math' as math;

class OceanBackground extends StatefulWidget {
  final Widget child;

  const OceanBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<OceanBackground> createState() => _OceanBackgroundState();
}

class _OceanBackgroundState extends State<OceanBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF006994),
            Color(0xFF0082C8),
            Color(0xFF4FB3D9),
            Color(0xFF7FCDEE),
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
                painter: _WavesPainter(_controller.value),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _WavesPainter extends CustomPainter {
  final double animation;

  _WavesPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw multiple wave layers
    _drawWave(canvas, size, 0.7, Colors.white.withOpacity(0.1), 40, 0);
    _drawWave(canvas, size, 0.75, Colors.white.withOpacity(0.08), 35, 30);
    _drawWave(canvas, size, 0.8, Colors.white.withOpacity(0.06), 30, 60);
  }

  void _drawWave(Canvas canvas, Size size, double heightFactor, Color color, double amplitude, double offset) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * heightFactor;
    
    path.moveTo(0, size.height);
    path.lineTo(0, waveHeight);

    for (double x = 0; x <= size.width; x += 5) {
      final y = waveHeight + 
                 math.sin((x / size.width * 4 * math.pi) + (animation * 2 * math.pi) + offset) * amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavesPainter oldDelegate) => true;
}