import 'package:flutter/material.dart';

class BlackBackground extends StatelessWidget {
  final Widget child;

  const BlackBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: child,
    );
  }
}