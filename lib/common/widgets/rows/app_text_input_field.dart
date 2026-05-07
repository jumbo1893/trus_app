import 'package:flutter/material.dart';

class AppTextInputField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;

  const AppTextInputField({
    super.key,
    required this.value,
    required this.onChanged,
    this.keyboardType,
    this.hintText,
  });

  @override
  State<AppTextInputField> createState() => _AppTextInputFieldState();
}

class _AppTextInputFieldState extends State<AppTextInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant AppTextInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
        composing: TextRange.empty,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: widget.keyboardType,
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
      ),
    );
  }
}