import 'package:flutter/material.dart';
import 'dart:math' as math;

class AuroraBackground extends StatefulWidget {
  final Widget child;

  const AuroraBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
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
            Color(0xFF001a33),
            Color(0xFF003d5c),
            Color(0xFF004d73),
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
                painter: _AuroraPainter(_controller.value),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double animation;

  _AuroraPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw multiple aurora layers
    _drawAuroraWave(
      canvas,
      size,
      [Color(0xFF00ff87).withOpacity(0.3), Color(0xFF60efff).withOpacity(0.2)],
      0.3,
      30,
      0,
    );
    _drawAuroraWave(
      canvas,
      size,
      [Color(0xFFb24592).withOpacity(0.25), Color(0xFFf15f79).withOpacity(0.15)],
      0.4,
      25,
      math.pi / 3,
    );
    _drawAuroraWave(
      canvas,
      size,
      [Color(0xFF4facfe).withOpacity(0.2), Color(0xFF00f2fe).withOpacity(0.1)],
      0.5,
      35,
      math.pi / 2,
    );
  }

  void _drawAuroraWave(
    Canvas canvas,
    Size size,
    List<Color> colors,
    double heightFactor,
    double amplitude,
    double phaseShift,
  ) {
    final path = Path();
    final waveHeight = size.height * heightFactor;

    path.moveTo(0, size.height);
    path.lineTo(0, waveHeight);

    for (double x = 0; x <= size.width; x += 5) {
      final y = waveHeight +
          math.sin((x / size.width * 3 * math.pi) +
                  (animation * 2 * math.pi) +
                  phaseShift) *
              amplitude +
          math.sin((x / size.width * 5 * math.pi) +
                  (animation * math.pi) +
                  phaseShift * 2) *
              (amplitude * 0.5);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) => true;
}