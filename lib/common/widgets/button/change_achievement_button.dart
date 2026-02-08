import 'package:flutter/material.dart';

import '../confirmation_dialog.dart';

class ChangeAchievementButton extends StatelessWidget {
  final String? confirmationText;
  final VoidCallback onPressed;
  final bool manually;
  final bool accomplished;

  const ChangeAchievementButton({
    Key? key,
    required this.confirmationText,
    required this.onPressed,
    required this.manually,
    required this.accomplished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (manually) {
      return FloatingActionButton(
        onPressed: () => (confirmationText == null) ? onPressed() : showDialog(
            context: context,
            builder: (BuildContext context) => ConfirmationDialog(
              confirmationText!,
              onPressed,
            )
        ),
        elevation: 4.0,
        child: accomplished ? const Icon(
            Icons.close)
            : const Icon(Icons.check),
      );
    }
    return const SizedBox.shrink();
  }
}
