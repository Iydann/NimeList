import 'package:flutter/material.dart';

class AnimePoster extends StatelessWidget {
  final double width;
  final double? height;
  final double borderRadius;

  const AnimePoster({
    super.key,
    this.width = double.infinity,
    this.height,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
