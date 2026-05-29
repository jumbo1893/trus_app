import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ElevatedButton(
        onPressed: () => {onPressed(), FocusManager.instance.primaryFocus?.unfocus()},
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(context.appColors.legacyAccent),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: context.appColors.legacyAccent),
              )
          ),
        ),
        child: Text(
            text,
            style: TextStyle(
              color: context.appColors.buttonForeground,
            )
        ),
      ),
    );
  }
}
