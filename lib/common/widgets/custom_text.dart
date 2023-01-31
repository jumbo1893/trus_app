import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';

class CustomText extends StatelessWidget {
  final String text;
  double fontSize;
  CustomText({
    Key? key,
    required this.text,
    this.fontSize = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize
      ),
    );
  }
}
