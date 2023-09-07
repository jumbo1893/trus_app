import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  
  final String content;
  final VoidCallback continueCallBack;

  const ConfirmationDialog(this.content, this.continueCallBack, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Vážený pane,"),
      content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("CANCEL")),
        TextButton(onPressed: () {Navigator.of(context).pop(); continueCallBack.call(); }, child: const Text("OK"))
      ],
    );
  }
}