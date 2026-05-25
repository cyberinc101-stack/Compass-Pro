import 'package:flutter/material.dart';

class SunsetBackground extends StatelessWidget {
  final Widget child;

  const SunsetBackground({
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
            Color(0xFF1e3c72),
            Color(0xFF2a5298),
            Color(0xFFff6b6b),
            Color(0xFFffa500),
            Color(0xFFffcc00),
          ],
          stops: [0.0, 0.3, 0.6, 0.8, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Sun
          Positioned(
            bottom: 100,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.yellow.shade100,
                    Colors.orange.shade400,
                    Colors.orange.shade600,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.6),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}