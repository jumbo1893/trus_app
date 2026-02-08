import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/custom_text_field2.dart';

import '../custom_text.dart';

class RowTextField extends StatefulWidget {
  final String? label;
  final String value;
  final String? textFieldText;
  final String? error;
  final bool number;
  final bool password;
  final bool enabled;
  final bool showIfEmptyText;
  final ValueChanged<String> onChanged;

  const RowTextField({
    super.key,
    this.label = "",
    this.textFieldText,
    required this.value,
    required this.onChanged,
    this.error,
    this.number = false,
    this.password = false,
    this.enabled = true,
    this.showIfEmptyText = true,
  });

  @override
  State<RowTextField> createState() => _RowTextFieldState();
}

class _RowTextFieldState extends State<RowTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant RowTextField oldWidget) {
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
    Size size = MediaQuery
        .of(context)
        .size;
    const double padding = 8.0;
    if (widget.showIfEmptyText || widget.value.isNotEmpty) {
      if (widget.textFieldText != null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: (size.width / 3) - padding,
                child: CustomText(text: widget.textFieldText!)),
            SizedBox(
                width: (size.width / 1.5) - padding,
                child: CustomTextField2(
                  textController: _controller,
                  onChanged: widget.onChanged,
                  label: widget.label ?? "",
                  number: widget.number,
                  enabled: widget.enabled,
                  password: widget.password,
                  error: widget.error,
                )),
          ],
        );
      } else {
        return CustomTextField2(
          textController: _controller,
          onChanged: widget.onChanged,
          label: widget.label ?? "",
          number: widget.number,
          enabled: widget.enabled,
          password: widget.password,
          error: widget.error,
        );
      }
    }
    return const SizedBox.shrink();
  }
}
