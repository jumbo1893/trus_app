import 'package:flutter/material.dart';

class RowWarningText extends StatelessWidget {
  final String text;

  const RowWarningText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        SizedBox(
            width: size.width / 6,
            child: const Icon(
              Icons.warning,
              color: Colors.black,
            )),
        SizedBox(
            width: size.width / 1.3,
            child: Text(
                text))
      ],
    );
  }
}
