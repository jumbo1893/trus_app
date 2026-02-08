import 'package:flutter/material.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';

import '../../../../colors.dart';
import '../../../utils/utils.dart';
import '../../custom_text.dart';

class RowLongTextSwitchStream extends StatefulWidget {
  final double padding;
  final String textFieldText;
  final BooleanControllerMixin booleanControllerMixin;
  final String hashKey;

  const RowLongTextSwitchStream(
      {required Key key,
      required this.padding,
      required this.textFieldText,
      required this.booleanControllerMixin,
      required this.hashKey})
      : super(key: key);

  @override
  State<RowLongTextSwitchStream> createState() => _RowLongTextSwitchStream();
}

class _RowLongTextSwitchStream extends State<RowLongTextSwitchStream> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder<bool>(
        stream: widget.booleanControllerMixin.boolean(widget.hashKey),
        builder: (context, snapshot) {
          bool isChecked = false;
          isChecked = snapshot.data?? widget.booleanControllerMixin.boolValues[widget.hashKey]!;
          return Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: orangeColor))),
            alignment: Alignment.centerRight,
            width: size.width - widget.padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(text: widget.textFieldText),
                Switch(
                  key: ValueKey("${getValueFromValueKey(widget.key!)}_switch"),
                  activeColor: orangeColor,
                  value: isChecked,
                  onChanged: (bool value) {
                    widget.booleanControllerMixin.setBoolean(value, widget.hashKey);
                  },
                ),
              ],
            ),
          );
        });
  }
}
