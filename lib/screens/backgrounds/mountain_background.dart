import 'package:flutter/material.dart';

class MountainBackground extends StatelessWidget {
  final Widget child;

  const MountainBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB),
            Color(0xFFB0D4E3),
            Color(0xFFD4E7F5),
          ],
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _MountainsPainter(),
          ),
          child,
        ],
      ),
    );
  }
}

class _MountainsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Back mountain layer
    final backMountain = Path();
    backMountain.moveTo(0, size.height);
    backMountain.lineTo(0, size.height * 0.6);
    backMountain.lineTo(size.width * 0.3, size.height * 0.4);
    backMountain.lineTo(size.width * 0.6, size.height * 0.5);
    backMountain.lineTo(size.width, size.height * 0.55);
    backMountain.lineTo(size.width, size.height);
    backMountain.close();

    canvas.drawPath(
      backMountain,
      Paint()..color = Color(0xFF6B8E9F).withOpacity(0.6),
    );

    // Middle mountain layer
    final middleMountain = Path();
    middleMountain.moveTo(0, size.height);
    middleMountain.lineTo(0, size.height * 0.7);
    middleMountain.lineTo(size.width * 0.4, size.height * 0.5);
    middleMountain.lineTo(size.width * 0.7, size.height * 0.6);
    middleMountain.lineTo(size.width, size.height * 0.65);
    middleMountain.lineTo(size.width, size.height);
    middleMountain.close();

    canvas.drawPath(
      middleMountain,
      Paint()..color = Color(0xFF4A7C8E).withOpacity(0.7),
    );

    // Front mountain layer
    final frontMountain = Path();
    frontMountain.moveTo(0, size.height);
    frontMountain.lineTo(0, size.height * 0.8);
    frontMountain.lineTo(size.width * 0.5, size.height * 0.6);
    frontMountain.lineTo(size.width * 0.8, size.height * 0.7);
    frontMountain.lineTo(size.width, size.height * 0.75);
    frontMountain.lineTo(size.width, size.height);
    frontMountain.close();

    canvas.drawPath(
      frontMountain,
      Paint()..color = Color(0xFF2E5266),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}