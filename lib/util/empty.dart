import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  final String message;

  const Empty({
    this.message = '데이터가 없습니다.',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message),
    );
  }
}
