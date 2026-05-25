import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../services/settings_service.dart';

class WeatherParticles extends StatefulWidget {
  final int weatherCode;
  final bool isDay;
  
  const WeatherParticles({
    Key? key,
    required this.weatherCode,
    required this.isDay,
  }) : super(key: key);

  @override
  State<WeatherParticles> createState() => _WeatherParticlesState();
}

class _WeatherParticlesState extends State<WeatherParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _initializeParticles();
  }

  void _initializeParticles() {
    _particles.clear();
    
    // Determine particle type and count based on weather
    if (widget.weatherCode >= 50 && widget.weatherCode <= 67 || 
        (widget.weatherCode >= 80 && widget.weatherCode <= 82)) {
      // Rain - more particles, faster
      for (int i = 0; i < 40; i++) {
        _particles.add(Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.03 + _random.nextDouble() * 0.04,
          size: 2 + _random.nextDouble() * 2,
          colorType: ParticleColorType.rain,
          type: ParticleType.rain,
        ));
      }
    } else if (widget.weatherCode >= 71 && widget.weatherCode <= 77 || 
               (widget.weatherCode >= 85 && widget.weatherCode <= 86)) {
      // Snow - medium particles, slower
      for (int i = 0; i < 30; i++) {
        _particles.add(Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.008 + _random.nextDouble() * 0.015,
          size: 3 + _random.nextDouble() * 4,
          colorType: ParticleColorType.snow,
          type: ParticleType.snow,
        ));
      }
    } else if (widget.weatherCode >= 95) {
      // Thunderstorm - heavy rain with more intensity
      for (int i = 0; i < 50; i++) {
        _particles.add(Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.04 + _random.nextDouble() * 0.05,
          size: 2 + _random.nextDouble() * 3,
          colorType: ParticleColorType.thunder,
          type: ParticleType.rain,
        ));
      }
    } else if (widget.weatherCode == 0) {
      // Clear - sun rays or stars
      if (widget.isDay) {
        // Sun rays - radiating from top
        for (int i = 0; i < 12; i++) {
          _particles.add(Particle(
            x: _random.nextDouble(),
            y: _random.nextDouble(),
            speed: 0.002 + _random.nextDouble() * 0.003,
            size: 30 + _random.nextDouble() * 40,
            colorType: ParticleColorType.sunRays,
            type: ParticleType.sunRay,
            angle: (i * 30.0) * math.pi / 180, // Rays at regular intervals
          ));
        }
      } else {
        // Stars - twinkling
        for (int i = 0; i < 20; i++) {
          _particles.add(Particle(
            x: _random.nextDouble(),
            y: _random.nextDouble(),
            speed: 0.001 + _random.nextDouble() * 0.002,
            size: 2 + _random.nextDouble() * 3,
            colorType: ParticleColorType.stars,
            type: ParticleType.float,
          ));
        }
      }
    } else if (widget.weatherCode >= 1 && widget.weatherCode <= 3) {
      // Partly cloudy - drifting cloud particles
      for (int i = 0; i < 8; i++) {
        _particles.add(Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble() * 0.6, // Keep clouds in upper portion
          speed: 0.003 + _random.nextDouble() * 0.004,
          size: 60 + _random.nextDouble() * 80,
          colorType: ParticleColorType.clouds,
          type: ParticleType.cloud,
        ));
      }
    } else if (widget.weatherCode >= 45 && widget.weatherCode <= 48) {
      // Fog - large drifting particles
      for (int i = 0; i < 15; i++) {
        _particles.add(Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.002 + _random.nextDouble() * 0.003,
          size: 40 + _random.nextDouble() * 60,
          colorType: ParticleColorType.fog,
          type: ParticleType.fog,
        ));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            settings: settings,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

enum ParticleType { rain, snow, float, fog, sunRay, cloud }
enum ParticleColorType { rain, snow, thunder, stars, sunRays, clouds, fog }

class Particle {
  double x;
  double y;
  final double speed;
  final double size;
  final ParticleColorType colorType;
  final ParticleType type;
  double? angle; // For sun rays
  double opacity = 1.0;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.colorType,
    required this.type,
    this.angle,
  });

  void update() {
    switch (type) {
      case ParticleType.rain:
        y += speed;
        if (y > 1.0) y = -0.05;
        break;
      case ParticleType.snow:
        y += speed;
        x += math.sin(y * 10) * 0.002;
        if (y > 1.0) {
          y = -0.05;
          x = math.Random().nextDouble();
        }
        break;
      case ParticleType.float:
        // Stars twinkle
        opacity = 0.3 + (math.sin(y * 20) * 0.7);
        y -= speed * 0.2;
        if (y < 0) y = 1.0;
        break;
      case ParticleType.fog:
        x += speed;
        if (x > 1.05) x = -0.05;
        break;
      case ParticleType.sunRay:
        // Sun rays pulse
        opacity = 0.1 + (math.sin(y * 5) * 0.15);
        break;
      case ParticleType.cloud:
        x += speed;
        if (x > 1.1) x = -0.1;
        break;
    }
  }

  Color getColor(SettingsService settings) {
    switch (settings.iconThemeMode) {
      case 'day':
        switch (colorType) {
          case ParticleColorType.rain:
            return Colors.lightBlue.withOpacity(0.6);
          case ParticleColorType.snow:
            return Colors.white.withOpacity(0.9);
          case ParticleColorType.thunder:
            return Colors.lightBlue.withOpacity(0.8);
          case ParticleColorType.stars:
            return Colors.white.withOpacity(opacity);
          case ParticleColorType.sunRays:
            return Colors.amber.withOpacity(opacity);
          case ParticleColorType.clouds:
            return Colors.white.withOpacity(0.4);
          case ParticleColorType.fog:
            return Colors.grey.withOpacity(0.3);
        }
        
      case 'glow':
        switch (colorType) {
          case ParticleColorType.rain:
            return const Color(0xFF00DDFF).withOpacity(0.6);
          case ParticleColorType.snow:
            return const Color(0xFF88FFFF).withOpacity(0.9);
          case ParticleColorType.thunder:
            return const Color(0xFF00FFFF).withOpacity(0.8);
          case ParticleColorType.stars:
            return const Color(0xFF00FF88).withOpacity(opacity);
          case ParticleColorType.sunRays:
            return const Color(0xFF00FFCC).withOpacity(opacity);
          case ParticleColorType.clouds:
            return const Color(0xFF00FF88).withOpacity(0.25);
          case ParticleColorType.fog:
            return const Color(0xFF00FF88).withOpacity(0.2);
        }
        
      case 'night':
        switch (colorType) {
          case ParticleColorType.rain:
            return const Color(0xFFFF4444).withOpacity(0.6);
          case ParticleColorType.snow:
            return const Color(0xFFFFAAAA).withOpacity(0.9);
          case ParticleColorType.thunder:
            return const Color(0xFFFF6666).withOpacity(0.8);
          case ParticleColorType.stars:
            return const Color(0xFFFF3333).withOpacity(opacity);
          case ParticleColorType.sunRays:
            return const Color(0xFFFF6666).withOpacity(opacity);
          case ParticleColorType.clouds:
            return const Color(0xFFFF3333).withOpacity(0.25);
          case ParticleColorType.fog:
            return const Color(0xFFFF3333).withOpacity(0.2);
        }
        
      default:
        return Colors.white.withOpacity(0.5);
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final SettingsService settings;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.settings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();
      
      final paint = Paint()
        ..color = particle.getColor(settings)
        ..style = PaintingStyle.fill;

      if (particle.type == ParticleType.rain) {
        // Draw rain as angled lines
        final start = Offset(particle.x * size.width, particle.y * size.height);
        final end = Offset(
          (particle.x * size.width) + 2, 
          (particle.y * size.height) + particle.size * 8
        );
        paint.strokeWidth = particle.size;
        paint.strokeCap = StrokeCap.round;
        canvas.drawLine(start, end, paint);
      } else if (particle.type == ParticleType.fog || particle.type == ParticleType.cloud) {
        // Draw fog and clouds as large blurred circles
        canvas.drawCircle(
          Offset(particle.x * size.width, particle.y * size.height),
          particle.size,
          paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
        );
      } else if (particle.type == ParticleType.sunRay) {
        // Draw sun rays as gradient lines from center-top
        final centerX = size.width * 0.5;
        final centerY = size.height * 0.15;
        
        final angle = particle.angle ?? 0;
        final length = particle.size * 2;
        
        final endX = centerX + math.cos(angle) * length;
        final endY = centerY + math.sin(angle) * length;
        
        paint.strokeWidth = 3;
        paint.strokeCap = StrokeCap.round;
        paint.shader = LinearGradient(
          colors: [
            particle.getColor(settings).withOpacity(0.8),
            particle.getColor(settings).withOpacity(0),
          ],
        ).createShader(Rect.fromPoints(
          Offset(centerX, centerY),
          Offset(endX, endY),
        ));
        
        canvas.drawLine(
          Offset(centerX, centerY),
          Offset(endX, endY),
          paint,
        );
      } else {
        // Draw snow and stars as circles
        canvas.drawCircle(
          Offset(particle.x * size.width, particle.y * size.height),
          particle.size,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}