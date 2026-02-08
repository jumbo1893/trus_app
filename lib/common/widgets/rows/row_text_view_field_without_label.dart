import 'package:flutter/material.dart';

import '../text_field_with_underline.dart';

class RowTextViewFieldWithoutLabel extends StatefulWidget {
  final String value;
  final String? error;
  final bool showIfEmptyText;
  final bool allowWrap;

  const RowTextViewFieldWithoutLabel({
    super.key,
    required this.value,
    this.error,
    this.allowWrap = false,
    this.showIfEmptyText = true,
  });

  @override
  State<RowTextViewFieldWithoutLabel> createState() => _RowTextViewFieldState();
}

class _RowTextViewFieldState extends State<RowTextViewFieldWithoutLabel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant RowTextViewFieldWithoutLabel oldWidget) {
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
      return SizedBox(
        width: size.width - padding,
        child: TextFieldWithUnderline(
          textController: _controller,
          align: TextAlign.left,
          allowWrap: widget.allowWrap,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
