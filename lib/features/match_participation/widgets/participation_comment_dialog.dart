import 'package:flutter/material.dart';

class ParticipationCommentDialog extends StatefulWidget {
  final String title;

  const ParticipationCommentDialog({super.key, required this.title});

  static Future<String?> show(BuildContext context, {required String title}) {
    return showDialog<String>(
      context: context,
      builder: (_) => ParticipationCommentDialog(title: title),
    );
  }

  @override
  State<ParticipationCommentDialog> createState() =>
      _ParticipationCommentDialogState();
}

class _ParticipationCommentDialogState
    extends State<ParticipationCommentDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 2,
        maxLines: 5,
        maxLength: 1000,
        textInputAction: TextInputAction.newline,
        decoration: const InputDecoration(hintText: 'Napiš komentář…'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Zrušit'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Odeslat')),
      ],
    );
  }
}
