import 'dart:ui';
import 'package:flutter/material.dart';

/// Set CompassMapMode.on.value = true while the map background is showing.
class CompassMapMode {
  static final ValueNotifier<bool> on = ValueNotifier<bool>(false);
}

/// Wraps a compass. When the map is on, draws a soft halo behind it.
class MapHalo extends StatelessWidget {
  final Color halo;
  final Widget Function(bool clear) builder;

  const MapHalo({Key? key, this.halo = Colors.black, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: CompassMapMode.on,
      builder: (context, clear, _) {
        final child = builder(clear);
        if (!clear) return child;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                  sigmaX: 2.5, sigmaY: 2.5, tileMode: TileMode.decal),
              child: ColorFiltered(
                colorFilter:
                    ColorFilter.mode(halo.withOpacity(0.8), BlendMode.srcIn),
                child: child,
              ),
            ),
            child,
          ],
        );
      },
    );
  }
}

/// Clips a filled circle down to a ring when [hollow] is true.
class HollowRing extends StatelessWidget {
  final bool hollow;
  final double thickness;
  final Widget child;

  const HollowRing(
      {Key? key,
      required this.hollow,
      required this.thickness,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!hollow) return child;
    return ClipPath(clipper: _RingClipper(thickness), child: child);
  }
}

class _RingClipper extends CustomClipper<Path> {
  final double thickness;
  _RingClipper(this.thickness);

  @override
  Path getClip(Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addOval(Rect.fromCircle(center: c, radius: r))
      ..addOval(Rect.fromCircle(center: c, radius: r - thickness));
  }

  @override
  bool shouldReclip(_RingClipper old) => old.thickness != thickness;
}