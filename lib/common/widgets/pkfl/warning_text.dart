import 'package:flutter/material.dart';

class WarningText extends StatelessWidget {
  final String text;
  final bool error;
  const WarningText({
    Key? key,
    required this.text,
    required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: error ? const Icon(Icons.error, color: Colors.red) : const Icon(Icons.warning, color: Colors.yellow),
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
