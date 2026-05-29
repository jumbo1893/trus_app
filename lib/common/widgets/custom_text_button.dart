import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
          text,
          style: TextStyle(
            color: context.appColors.errorSolid,
          )
      ),
    );
  }
}
