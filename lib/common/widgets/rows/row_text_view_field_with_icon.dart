import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';

import '../custom_text.dart';

class RowTextViewFieldWithIcon extends StatefulWidget {
  final String value;
  final String textFieldText;
  final String? error;
  final bool showIfEmptyText;
  final bool allowWrap;
  final VoidCallback onCalendarIconPressed;
  final IconData icon;

  const RowTextViewFieldWithIcon({
    super.key,
    required this.textFieldText,
    required this.value,
    this.error,
    this.allowWrap = false,
    this.showIfEmptyText = true,
    required this.onCalendarIconPressed,
    required this.icon,
  });

  @override
  State<RowTextViewFieldWithIcon> createState() => _RowTextViewFieldWithIconState();
}

class _RowTextViewFieldWithIconState extends State<RowTextViewFieldWithIcon> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant RowTextViewFieldWithIcon oldWidget) {
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
              child: TextField(
                onTap: widget.onCalendarIconPressed,
                maxLines: widget.allowWrap ? null : 1,
                minLines: widget.allowWrap ? 1 : null,
                controller: _controller,
                readOnly: true,
                decoration: InputDecoration(
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: orangeColor
                      ),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: orangeColor
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: orangeColor
                      ),
                    ),
                    labelStyle: const TextStyle(
                      fontSize: 12,
                    ),
                    floatingLabelStyle: const TextStyle(
                        color: textColor
                    ),
                    contentPadding: const EdgeInsets.only(left: 10, top: 10),
                    errorText: widget.error != null && widget.error!.isNotEmpty
                        ? widget.error
                        : null,
                    errorMaxLines: 2,
                    suffixIcon: IconButton(
                        onPressed: widget.onCalendarIconPressed,
                        icon: Icon(widget.icon, color: orangeColor,
                        )
                    )
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
