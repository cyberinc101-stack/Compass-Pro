import 'package:flutter/material.dart';
import 'dart:math' as math;

class MapBackground extends StatelessWidget {
  final Widget child;

  const MapBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50), // Dark blue-grey
            Color(0xFF34495E), // Slightly lighter blue-grey
            Color(0xFF2C3E50), // Back to dark
          ],
        ),
      ),
      child: Stack(
        children: [
          // Base terrain texture
          CustomPaint(
            size: Size.infinite,
            painter: _TerrainTexturePainter(),
          ),
          // Elevation contour lines
          CustomPaint(
            size: Size.infinite,
            painter: _TopographicPainter(),
          ),
          // Coordinate grid
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(),
          ),
          // Subtle compass markers
          CustomPaint(
            size: Size.infinite,
            painter: _CompassMarkersPainter(),
          ),
          child,
        ],
      ),
    );
  }
}

class _TerrainTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(123);
    final paint = Paint()..style = PaintingStyle.fill;

    // Add subtle terrain variation spots
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 60 + 40;
      
      paint.shader = RadialGradient(
        colors: [
          Color(0xFF3E5568).withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopographicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    
    // Draw multiple layers of contour lines with varying thickness
    for (int layer = 0; layer < 3; layer++) {
      final paint = Paint()
        ..color = Color(0xFF5DADE2).withOpacity(0.15 + layer * 0.05)
        ..strokeWidth = 1.0 + layer * 0.5
        ..style = PaintingStyle.stroke;

      // Create organic contour lines
      for (int i = 0; i < 12; i++) {
        final path = Path();
        final baseY = size.height * (i + layer * 0.3) / 12;
        final amplitude = 40 + layer * 10;
        final frequency = 0.015 + random.nextDouble() * 0.01;
        
        path.moveTo(0, baseY);
        
        for (double x = 0; x <= size.width; x += 5) {
          final noise1 = math.sin(x * frequency + random.nextDouble() * 2);
          final noise2 = math.cos(x * frequency * 1.5 + i);
          final y = baseY + (noise1 * amplitude) + (noise2 * amplitude * 0.5);
          path.lineTo(x, y);
        }
        
        canvas.drawPath(path, paint);
        
        // Add occasional elevation markers
        if (i % 3 == 0 && layer == 0) {
          final markerPaint = Paint()
            ..color = Color(0xFF85C1E9).withOpacity(0.4)
            ..strokeWidth = 2;
          
          for (double x = 50; x < size.width; x += 150) {
            final markerY = baseY + math.sin(x * frequency) * amplitude;
            canvas.drawLine(
              Offset(x, markerY - 5),
              Offset(x, markerY + 5),
              markerPaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mainGridPaint = Paint()
      ..color = Color(0xFF7FB3D5).withOpacity(0.15)
      ..strokeWidth = 0.8;
    
    final accentGridPaint = Paint()
      ..color = Color(0xFF85C1E9).withOpacity(0.25)
      ..strokeWidth = 1.2;

    // Major grid lines every 100 pixels with accent
    for (double x = 0; x <= size.width; x += 100) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        accentGridPaint,
      );
    }

    for (double y = 0; y <= size.height; y += 100) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        accentGridPaint,
      );
    }

    // Minor grid lines every 50 pixels
    for (double x = 50; x <= size.width; x += 100) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        mainGridPaint,
      );
    }

    for (double y = 50; y <= size.height; y += 100) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        mainGridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassMarkersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF85C1E9).withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Color(0xFF5DADE2).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = math.Random(999);

    // Add subtle compass rose markers scattered around
    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 12.0;

      // Draw small compass rose
      canvas.drawCircle(Offset(x, y), radius, fillPaint);
      canvas.drawCircle(Offset(x, y), radius, paint);

      // Draw cardinal points
      for (int j = 0; j < 4; j++) {
        final angle = (j * math.pi / 2);
        final startX = x + math.cos(angle) * radius * 0.6;
        final startY = y + math.sin(angle) * radius * 0.6;
        final endX = x + math.cos(angle) * radius;
        final endY = y + math.sin(angle) * radius;
        
        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          paint,
        );
      }
    }

    // Add scale bar indicator in corners
    final scaleBarPaint = Paint()
      ..color = Color(0xFF85C1E9).withOpacity(0.4)
      ..strokeWidth = 2;

    // Bottom right scale bar
    final scaleX = size.width - 100;
    final scaleY = size.height - 30;
    
    canvas.drawLine(
      Offset(scaleX, scaleY),
      Offset(scaleX + 80, scaleY),
      scaleBarPaint,
    );
    
    // Tick marks
    for (int i = 0; i <= 4; i++) {
      final tickX = scaleX + (i * 20);
      canvas.drawLine(
        Offset(tickX, scaleY - 5),
        Offset(tickX, scaleY + 5),
        scaleBarPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}