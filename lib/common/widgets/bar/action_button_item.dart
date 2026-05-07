import 'package:flutter/material.dart';

enum ActionButtonType {
  primary,
  secondary,
  danger,
}

class ActionButtonItem {
  final String label;
  final VoidCallback? onPressed;
  final ActionButtonType type;
  final IconData? icon;
  final String? confirmationText;


  const ActionButtonItem({
    required this.label,
    required this.onPressed,
    this.type = ActionButtonType.primary,
    this.icon,
    this.confirmationText,
  });
}