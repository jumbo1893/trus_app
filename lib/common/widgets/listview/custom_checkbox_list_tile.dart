import 'package:flutter/material.dart';
import 'package:trus_app/models/api/player_api_model.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../colors.dart';

class CustomCheckboxListTile extends StatefulWidget {
  final bool initValue;
  final Function(bool value) onCheck;
  final PlayerApiModel player;
  const CustomCheckboxListTile(
      {Key? key,
        required this.initValue,
        required this.onCheck,
      required this.player,})
      : super(key: key);

  @override
  State<CustomCheckboxListTile> createState() => _CustomCheckboxListTile();
}

class _CustomCheckboxListTile extends State<CustomCheckboxListTile> {

  late bool initCheck;

  void setInitCheck() {
      initCheck = widget.initValue;
  }


  @override
  Widget build(BuildContext context) {
    setInitCheck();
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      value: initCheck,
      onChanged: (bool? value) {
        setState(() {
          //initCheck = value!;
          //setInitCheck();
        });
        widget.onCheck(initCheck);
      },
      title: Padding(
        padding:
        const EdgeInsets.only(bottom: 16),
        child: Text(
          widget.player.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      subtitle: Text(
        widget.player.toStringForListView(),
        style: const TextStyle(
            color: listviewSubtitleColor),
      ),
    );
  }
}
