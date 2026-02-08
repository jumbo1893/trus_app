import 'package:flutter/material.dart';

import '../custom_text.dart';
import '../text_field_with_underline.dart';

class RowTextViewField extends StatefulWidget {
  final String value;
  final String textFieldText;
  final String? error;
  final bool showIfEmptyText;
  final bool allowWrap;

  const RowTextViewField({
    super.key,
    required this.textFieldText,
    required this.value,
    this.error,
    this.allowWrap = false,
    this.showIfEmptyText = true,
  });

  @override
  State<RowTextViewField> createState() => _RowTextViewFieldState();
}

class _RowTextViewFieldState extends State<RowTextViewField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant RowTextViewField oldWidget) {
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
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
            SizedBox(
                width: (size.width / 3) - padding,
                child: CustomText(text: widget.textFieldText)),
            SizedBox(
              width: (size.width / 1.5) - padding,
              child: TextFieldWithUnderline(
                textController: _controller,
                align: TextAlign.right,
                allowWrap: widget.allowWrap,
              ),
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
