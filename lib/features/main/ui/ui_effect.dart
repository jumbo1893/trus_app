import 'package:flutter/material.dart';

sealed class UiEffect {
  const UiEffect();
}

class UiSnack extends UiEffect {
  final String message;
  final Duration duration;
  const UiSnack(this.message, {this.duration = const Duration(seconds: 1)});
}

class UiErrorDialog extends UiEffect {
  final String title;
  final String message;
  const UiErrorDialog(this.message, {this.title = "Chyba"});
}

class UiConfirmationDialog extends UiEffect {
  final String message;
  final VoidCallback continueCallBack;
  const UiConfirmationDialog(this.message, this.continueCallBack);
}