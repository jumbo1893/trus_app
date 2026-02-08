import 'package:flutter/material.dart';

import '../../../colors.dart';
import '../confirmation_dialog.dart';


class SimpleCrudButton extends StatelessWidget {
  final String text;
  final String? deleteConfirmationText;
  final VoidCallback onPressed;

  const SimpleCrudButton({
    super.key,
    required this.text,
    this.deleteConfirmationText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style:  ButtonStyle(
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
      onPressed: () => (deleteConfirmationText == null) ? onPressed() : showDialog(
        context: context,
        builder: (BuildContext context) => ConfirmationDialog(
          deleteConfirmationText!,
          onPressed,
      )
      ), child: Text(
      text,
      style: const TextStyle(
        color: blackColor,
      ),
    ),
    );
  }
}
