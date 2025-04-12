import 'package:flutter/material.dart';

class WarningText extends StatelessWidget {
  final String text;
  final WarningType warningType;
  const WarningText({
    Key? key,
    required this.text,
    required this.warningType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Icon warningIcon;
    switch (warningType) {
      case WarningType.error:
        warningIcon = const Icon(Icons.error, color: Colors.red);
        break;
      case WarningType.warning:
        warningIcon = const Icon(Icons.warning, color: Colors.orange);
        break;
      case WarningType.info:
        warningIcon = const Icon(Icons.question_mark, color: Colors.blue);
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: warningIcon
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(left: 6, right: 3),
            child: Text(text),
          ))
        ],
      ),
    );
  }
}

enum WarningType {
  warning,
  error,
  info,
}
