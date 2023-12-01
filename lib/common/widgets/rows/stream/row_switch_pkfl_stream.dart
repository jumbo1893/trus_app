import 'package:flutter/material.dart';

import '../../../../colors.dart';
import '../../../../models/api/pkfl/pkfl_match_api_model.dart';
import '../../../utils/utils.dart';
import '../../custom_text.dart';
import '../../loader.dart';

class RowSwitchPkflStream extends StatefulWidget {
  final Size size;
  final double padding;
  final String textFieldText;
  final Stream<bool> stream;
  final Function(bool) onChecked;
  final VoidCallback? initStream;
  final PkflMatchApiModel pkflMatch;

  const RowSwitchPkflStream(
      {required Key key,
      required this.size,
      required this.padding,
      required this.textFieldText,
      required this.stream,
      required this.onChecked,
        required this.pkflMatch,
      this.initStream})
      : super(key: key);

  @override
  State<RowSwitchPkflStream> createState() => _RowSwitchPkflStreamState();
}

class _RowSwitchPkflStreamState extends State<RowSwitchPkflStream> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder<bool>(
        stream: widget.stream,
        builder: (context, snapshot) {
          bool isChecked = false;
          if (snapshot.connectionState == ConnectionState.waiting) {
            if (widget.initStream != null) {
              widget.initStream!();
            }
            return const Loader();
          }
          isChecked = snapshot.data!;
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
                child: Row(
                  children: [
                    SizedBox(
                        width: (size.width / 3),
                        child: CustomText(text: widget.pkflMatch.toStringNameWithOpponent())),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Switch(
                          key: ValueKey("${getValueFromValueKey(widget.key!)}_switch"),
                          activeColor: orangeColor,
                          value: isChecked,
                          onChanged: (bool value) {
                            widget.onChecked(value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
