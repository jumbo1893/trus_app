import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'action_button_item.dart';

class FormActionBar extends StatelessWidget {
  final List<ActionButtonItem> actions;

  const FormActionBar({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < actions.length; i++) ...[
              _buildButton(context, actions[i]),
              if (i != actions.length - 1)
                const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, ActionButtonItem action) {
    switch (action.type) {
      case ActionButtonType.primary:
        return ElevatedButton(
          onPressed: action.onPressed,
          child: _ButtonContent(action: action),
        );

      case ActionButtonType.secondary:
        return OutlinedButton(
          onPressed: action.onPressed,
          child: _ButtonContent(action: action),
        );

      case ActionButtonType.danger:
        final colors = context.appColors;

        return ElevatedButton(
          onPressed: action.onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            elevation: 0,
            backgroundColor: colors.errorForeground,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: _ButtonContent(action: action),
        );
    }
  }
}

class _ButtonContent extends StatelessWidget {
  final ActionButtonItem action;

  const _ButtonContent({required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (action.icon != null) ...[
          Icon(action.icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(action.label),
      ],
    );
  }
}