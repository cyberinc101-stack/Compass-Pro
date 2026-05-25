import 'package:flutter/material.dart';

class DarkModeBackground extends StatelessWidget {
  final Widget child;

  const DarkModeBackground({
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
            Color(0xFF0F0F1E),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
      ),
      child: child,
    );
  }
}