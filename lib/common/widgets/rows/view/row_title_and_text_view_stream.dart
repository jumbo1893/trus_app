import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/text_field_with_underline.dart';
import 'package:trus_app/features/mixin/title_and_text_controller_mixin.dart';
import 'package:trus_app/models/helper/title_and_text.dart';

import '../../custom_text.dart';

class RowTitleAndTextViewStream extends StatefulWidget {
  final double padding;
  final TitleAndTextControllerMixin titleAndTextControllerMixin;
  final String hashKey;
  final bool allowWrap;
  final bool showIfEmptyText;

  const RowTitleAndTextViewStream({
    Key? key,
    required this.padding,
    required this.titleAndTextControllerMixin,
    required this.hashKey,
    this.allowWrap = false,
    this.showIfEmptyText = true,
  }) : super(key: key);

  @override
  State<RowTitleAndTextViewStream> createState() => _RowTitleAndTextViewStream();
}

class _RowTitleAndTextViewStream extends State<RowTitleAndTextViewStream> {
  final _textController = TextEditingController();
  String errorText = "";

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder<TitleAndText>(
        stream: widget.titleAndTextControllerMixin.titleAndTextValue(widget.hashKey),
        initialData: widget.titleAndTextControllerMixin.titleAndTextValues[widget.hashKey],
        builder: (context, snapshot) {
          TitleAndText titleAndText = snapshot.data!;
          _textController.text = titleAndText.text;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.showIfEmptyText || titleAndText.text.isNotEmpty) ...[
                SizedBox(
                    width: (size.width / 3) - widget.padding,
                    child: CustomText(text: titleAndText.title)),
                SizedBox(
                  width: (size.width / 1.5) - widget.padding,
                  child: TextFieldWithUnderline(

                          textController: _textController,
                          align: TextAlign.right,
                          allowWrap: widget.allowWrap,
                        )

                ),
              ],
            ],
          );
        });
  }
}
