import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/text_field_with_underline.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';

import '../../../utils/utils.dart';
import '../../custom_text.dart';
import '../../loader.dart';

class RowTextViewStream extends StatefulWidget {
  final Size size;
  final double padding;
  final String textFieldText;
  final ViewControllerMixin viewMixin;
  final String hashKey;
  final bool allowWrap;
  final bool showIfEmptyText;

  const RowTextViewStream({
    required Key key,
    required this.size,
    required this.padding,
    required this.textFieldText,
    required this.viewMixin,
    required this.hashKey,
    this.allowWrap = false,
    this.showIfEmptyText = true,
  }) : super(key: key);

  @override
  State<RowTextViewStream> createState() => _RowTextViewStream();
}

class _RowTextViewStream extends State<RowTextViewStream> {
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
    return StreamBuilder<String>(
        stream: widget.viewMixin.viewValue(widget.hashKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          String text = snapshot.data!;
          _textController.text = text;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.showIfEmptyText || text.isNotEmpty) ...[
                SizedBox(
                    width: (size.width / 3) - widget.padding,
                    child: CustomText(text: widget.textFieldText)),
                SizedBox(
                  width: (size.width / 1.5) - widget.padding,
                  child: StreamBuilder<String>(
                      stream: widget.viewMixin.viewErrorText(widget.hashKey),
                      builder: (context, errorTextSnapshot) {
                        if (errorTextSnapshot.connectionState !=
                                ConnectionState.waiting &&
                            errorTextSnapshot.hasData) {
                          errorText = errorTextSnapshot.data!;
                        }
                        return TextFieldWithUnderline(
                          key: ValueKey(
                              "${getValueFromValueKey(widget.key!)}_text"),
                          textController: _textController,
                          align: TextAlign.right,
                          allowWrap: widget.allowWrap,
                        );
                      }),
                ),
              ],
            ],
          );
        });
  }
}
