import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:trus_app/models/match_model.dart';

class MatchDropdownWithoutStream extends ConsumerStatefulWidget {
  final Function(MatchModel? matchModel) onMatchSelected;
  final List<MatchModel> matchList;
  final MatchModel initMatch;
  const MatchDropdownWithoutStream({
    Key? key,
    required this.matchList,
    required this.onMatchSelected,
    required this.initMatch,
  }) : super(key: key);

  @override
  ConsumerState<MatchDropdownWithoutStream> createState() =>
      _MatchDropdownWithoutStream();
}

class _MatchDropdownWithoutStream
    extends ConsumerState<MatchDropdownWithoutStream> {
  late MatchModel selectedValue;

  List<DropdownMenuItem<MatchModel>> _addDividersAfterItems(
      List<MatchModel> items) {
    List<DropdownMenuItem<MatchModel>> menuItems = [];
    for (var item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<MatchModel>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.toStringWithOpponentName(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          //If it's last item, we will not add Divider after it.
          /*if (item != items.last)
            const DropdownMenuItem<MatchModel>(
              enabled: false,
              child: Divider(),
            ),*/
        ],
      );
    }
    return menuItems;
  }

  void _initSelectedValue() {
    selectedValue = widget.initMatch;
  }

  @override
  Widget build(BuildContext context) {
    _initSelectedValue();
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        selectedItemBuilder: (_) {
          return widget.matchList
              .map((e) => Container(
                    alignment: Alignment.center,
                    child: Text(
                      e.toStringWithOpponentName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ))
              .toList();
        },
        isExpanded: true,
        items: _addDividersAfterItems(widget.matchList),
        //customItemsHeights: _getCustomItemsHeights(snapshot.data!.length),
        iconEnabledColor: Colors.white,
        value: selectedValue,
        onChanged: (value) {
          setState(() {
            selectedValue = value as MatchModel;
            widget.onMatchSelected(value);
          });
        },
        buttonHeight: 40,
        dropdownMaxHeight: 200,
        buttonWidth: 140,
        itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      ),
    );
  }
}
