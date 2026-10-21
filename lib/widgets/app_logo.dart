import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool excludeFromSemantics;

  const AppLogo({
    super.key,
    this.size = 32,
    this.borderRadius = 8,
    this.excludeFromSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        'assets/Icon.png',
        width: size,
        height: size,
        semanticLabel: 'Logo NimeList',
        excludeFromSemantics: excludeFromSemantics,
      ),
    );
  }
}
