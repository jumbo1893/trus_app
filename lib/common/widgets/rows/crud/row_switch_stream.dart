import 'package:flutter/material.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';

import '../../../../colors.dart';
import '../../../utils/utils.dart';
import '../../custom_text.dart';
import '../../loader.dart';

class RowSwitchStream extends StatefulWidget {
  final Size size;
  final double padding;
  final String textFieldText;
  final BooleanControllerMixin booleanControllerMixin;
  final String hashKey;

  const RowSwitchStream(
      {required Key key,
      required this.size,
      required this.padding,
      required this.textFieldText,
      required this.booleanControllerMixin,
      required this.hashKey})
      : super(key: key);

  @override
  State<RowSwitchStream> createState() => _RowSwitchStream();
}

class _RowSwitchStream extends State<RowSwitchStream> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder<bool>(
        stream: widget.booleanControllerMixin.boolean(widget.hashKey),
        builder: (context, snapshot) {
          bool isChecked = false;
          isChecked = snapshot.data?? widget.booleanControllerMixin.boolValues[widget.hashKey]!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: (size.width / 3) - widget.padding,
                  child: CustomText(text: widget.textFieldText)),
              Container(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: orangeColor))),
                width: (size.width / 1.5) - widget.padding,
                alignment: Alignment.centerRight,
                child: Switch(
                  key: ValueKey("${getValueFromValueKey(widget.key!)}_switch"),
                  activeColor: orangeColor,
                  value: isChecked,
                  onChanged: (bool value) {
                    widget.booleanControllerMixin.setBoolean(value, widget.hashKey);
                  },
                ),
              ),
            ],
          );
        });
  }
}
