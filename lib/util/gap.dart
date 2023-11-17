import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double? width;
  final double? height;

  const Gap({
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 0.0,
      height: height ?? 0.0,
    );
  }
}
