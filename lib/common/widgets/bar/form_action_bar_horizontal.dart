import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'action_button_item.dart';

class FormActionBarHorizontal extends StatelessWidget {
  final List<ActionButtonItem> actions;

  const FormActionBarHorizontal({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            for (int i = 0; i < actions.length; i++) ...[
              Expanded(
                child: _buildButton(context, actions[i]),
              ),
              if (i != actions.length - 1)
                const SizedBox(width: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, ActionButtonItem action) {
    final colors = context.appColors;

    switch (action.type) {
      case ActionButtonType.primary:
        return ElevatedButton(
          onPressed: action.onPressed,
          style: _baseStyle(),
          child: _ButtonContent(action: action),
        );

      case ActionButtonType.secondary:
        return OutlinedButton(
          onPressed: action.onPressed,
          style: _baseStyle(),
          child: _ButtonContent(action: action),
        );

      case ActionButtonType.danger:
        return ElevatedButton(
          onPressed: action.onPressed,
          style: _baseStyle().copyWith(
            backgroundColor: WidgetStateProperty.all(colors.errorForeground),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
          child: _ButtonContent(action: action),
        );
    }
  }

  ButtonStyle _baseStyle() {
    return ElevatedButton.styleFrom(
      minimumSize: const Size(0, 48), // 👈 nižší než default 52
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
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
          Icon(action.icon, size: 16),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            action.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}