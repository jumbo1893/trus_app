import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';


class SimpleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SimpleButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
          minimumSize:
          WidgetStateProperty.all(const Size(double.infinity, 50)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: const BorderSide(color: Colors.orange),
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: blackColor,
          ),
        ),
      ),
    );
  }
}
