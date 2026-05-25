import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

class CompassDial extends StatelessWidget {
  final double heading;
  final double size;

  const CompassDial({
    Key? key,
    required this.heading,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<LocalizationService>(context, listen: false);
    
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CompassDialPainter(
          heading: heading,
          cardinalDirections: [
            t.translate('n'),
            t.translate('e'),
            t.translate('s'),
            t.translate('w'),
          ],
        ),
      ),
    );
  }
}

class CompassDialPainter extends CustomPainter {
  final double heading;
  final List<String> cardinalDirections;

  CompassDialPainter({
    required this.heading,
    required this.cardinalDirections,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer circle
    final outerPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 10, outerPaint);

    // Draw compass rose
    for (int i = 0; i < 360; i += 30) {
      final angle = (i - heading) * math.pi / 180;
      final x1 = center.dx + (radius - 30) * math.cos(angle);
      final y1 = center.dy + (radius - 30) * math.sin(angle);
      final x2 = center.dx + (radius - 15) * math.cos(angle);
      final y2 = center.dy + (radius - 15) * math.sin(angle);

      final paint = Paint()
        ..color = Colors.white
        ..strokeWidth = i % 90 == 0 ? 3 : 2;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw cardinal directions
    _drawCardinalDirections(canvas, center, radius);

    // Draw north pointer
    _drawNorthPointer(canvas, center, radius);
  }

  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    final colors = [Colors.red, Colors.white, Colors.white, Colors.white];

    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - heading) * math.pi / 180;
      final x = center.dx + (radius - 50) * math.cos(angle);
      final y = center.dy + (radius - 50) * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: cardinalDirections[i],
          style: TextStyle(
            color: colors[i],
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawNorthPointer(Canvas canvas, Offset center, double radius) {
    final path = Path();
    path.moveTo(center.dx, center.dy - radius + 40);
    path.lineTo(center.dx - 15, center.dy + 20);
    path.lineTo(center.dx, center.dy);
    path.lineTo(center.dx + 15, center.dy + 20);
    path.close();

    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(CompassDialPainter oldDelegate) =>
      heading != oldDelegate.heading ||
      cardinalDirections != oldDelegate.cardinalDirections;
}