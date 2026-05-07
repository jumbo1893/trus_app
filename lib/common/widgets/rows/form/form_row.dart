import 'package:flutter/material.dart';

class FormRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const FormRow({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i != children.length - 1)
            SizedBox(width: spacing),
        ],
      ],
    );
  }
}