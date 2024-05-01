import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../models/api/season_api_model.dart';
import '../../../utils/utils.dart';
import '../../custom_text.dart';
import '../../dropdown/custom_dropdown.dart';

class RowSeasonStream extends StatefulWidget {
  final Size size;
  final double padding;
  final Stream<SeasonApiModel> pickedSeason;
  final Future<List<SeasonApiModel>> seasonList;
  final Function(SeasonApiModel) onSeasonChanged;
  final VoidCallback? initData;

  const RowSeasonStream({
    required Key key,
    required this.size,
    required this.padding,
    required this.seasonList,
    required this.pickedSeason,
    required this.onSeasonChanged,
    this.initData,
  }) : super(key: key);

  @override
  State<RowSeasonStream> createState() => _RowSeasonStream();
}

class _RowSeasonStream extends State<RowSeasonStream> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
          width: (widget.size.width / 3) - widget.padding,
          child: CustomText(
              text: "Vyber sezonu:",
              key: ValueKey("${getValueFromValueKey(widget.key!)}_text"))),
      SizedBox(
          width: (widget.size.width / 1.5) - widget.padding,
          child: CustomDropdown(
            key: ValueKey("${getValueFromValueKey(widget.key!)}_dropdown"),
            onItemSelected: (season) => widget.onSeasonChanged(season as SeasonApiModel),
            dropdownList: widget.seasonList,
            pickedItem: widget.pickedSeason,
            initData: widget.initData,
            hint: 'Vyber sezonu',
          )),
    ]);
  }
}
