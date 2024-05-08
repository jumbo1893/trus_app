import 'package:flutter/material.dart';

class Legend extends StatelessWidget {
  final String text;
  final List<Color> gradientColors;
  const Legend({
    Key? key,
    required this.text,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text),
        SizedBox(
          width: 20,
          height: 4,
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors)
            ),
          ),
        ),
      ],
    );
  }

}

