import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../colors.dart';
import '../../../features/season/utils/season_calculator.dart';

class SeasonDropdownButton extends StatefulWidget {
  final Function(SeasonModel? seasonModel) onSeasonSelected;
  final String errorText;
  final String? seasonId;
  final List<SeasonModel> items;

  const SeasonDropdownButton(
      {Key? key,
        this.seasonId = "",
      required this.errorText,
      required this.items,
      required this.onSeasonSelected})
      : super(key: key);

  @override
  State<SeasonDropdownButton> createState() => _SeasonDropdown();
}

class _SeasonDropdown extends State<SeasonDropdownButton> {

  late SeasonModel? selectedSeason = calculateSeasonFromId(widget.seasonId, widget.items);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2(
      decoration: InputDecoration(
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: orangeColor),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: orangeColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: orangeColor),
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
        ),
        floatingLabelStyle: const TextStyle(color: textColor),
        contentPadding: const EdgeInsets.only(left: 10, top: 10),
        errorText: widget.errorText.isNotEmpty ? widget.errorText : null,
      ),
      isExpanded: true,
      hint: const Text(
        'Vyber sezonu',
        style: TextStyle(fontSize: 14),
      ),
      /*icon: const Icon(
        Icons.arrow_drop_down,
        color: orangeColor,
      ),
      iconSize: 30,
      buttonHeight: 60,
      buttonPadding: const EdgeInsets.only(left: 20, right: 10),
      dropdownDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),*/
      items: widget.items
          .map((item) => DropdownMenuItem<SeasonModel>(
                value: item,
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ))
          .toList(),
      value: selectedSeason,
      onChanged: (value) {
        setState(() {
          selectedSeason = value as SeasonModel;
          widget.onSeasonSelected(value);
        });
      },
      onSaved: (value) {
        //selectedValue = value.toString();
      },
    );
  }
}
