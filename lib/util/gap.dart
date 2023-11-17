import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double? width;
  final double? height;

  const Gap({
    this.width = 0.0,
    this.height = 0.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
    );
  }
}
