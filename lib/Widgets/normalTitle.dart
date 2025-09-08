import 'package:flutter/material.dart';
import 'package:nubmed/utils/Color_codes.dart';

class Normal_Title extends StatelessWidget {
  const Normal_Title({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17,
        color: Color_codes.deep_plus,
      ),
    );
  }
}
