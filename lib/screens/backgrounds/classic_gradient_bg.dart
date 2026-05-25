import 'package:flutter/material.dart';

class ClassicGradientBackground extends StatelessWidget {
  final Widget child;

  const ClassicGradientBackground({
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
            Color(0xFF4A90E2),
            Color(0xFF63B3ED),
          ],
        ),
      ),
      child: child,
    );
  }
}