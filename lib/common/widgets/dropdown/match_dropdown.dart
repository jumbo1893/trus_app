import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/season/controller/season_controller.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../features/match/controller/match_controller.dart';

class MatchDropdown extends ConsumerStatefulWidget {
  final Function(MatchModel? matchModel) onMatchSelected;
  final Function(List<String> playersIds) onPlayersSelected;
  final Function(MatchModel? matchModel) onInitMatchSelected;
  final MatchModel? initMatch;
  bool init;
  MatchDropdown({
    Key? key,
    required this.onMatchSelected,
    required this.onInitMatchSelected,
    required this.onPlayersSelected,
    required this.initMatch,
    this.init = true,
  }) : super(key: key);

  @override
  ConsumerState<MatchDropdown> createState() => _MatchDropdownState();
}

class _MatchDropdownState extends ConsumerState<MatchDropdown> {

  late MatchModel? selectedValue;

  List<DropdownMenuItem<MatchModel>> _addDividersAfterItems(List<MatchModel> items) {
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

  List<double> _getCustomItemsHeights(int itemsLength) {
    List<double> itemsHeights = [];
    for (var i = 0; i < (itemsLength * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      //Dividers indexes will be the odd indexes
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  void initSelectedMatch(List<MatchModel> matches) {
    if(widget.init) {
      if (widget.initMatch != null) {
        selectedValue = widget.initMatch;
      }
      else {
        selectedValue = matches[0];
        widget.init = false;
      }
      widget.onInitMatchSelected(selectedValue);
      widget.onPlayersSelected(selectedValue!.playerIdList);
    }
  }





  @override
  Widget build(BuildContext context) {
    //print(selectedValue?.playerIdList);
    return StreamBuilder<List<MatchModel>>(
        stream: ref.watch(matchControllerProvider).matches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          List<MatchModel> matches = snapshot.data!;
          matches.sort(
                  (a, b) => b.date.compareTo(a.date));
          initSelectedMatch(matches);
          return DropdownButtonHideUnderline(
            child: DropdownButton2(
              selectedItemBuilder: (_) {
                return matches
                    .map((e) => Container(
                  alignment: Alignment.center,
                  child: Text(
                    e.toStringWithOpponentName(),
                    style: const TextStyle(color: Colors.white, fontSize: 20,),
                  ),
                ))
                    .toList();
              },
              isExpanded: true,
              items: _addDividersAfterItems(matches),
              //customItemsHeights: _getCustomItemsHeights(snapshot.data!.length),
              iconEnabledColor: Colors.white,
              value: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value as MatchModel;
                  widget.onMatchSelected(value);
                  widget.onPlayersSelected(selectedValue!.playerIdList);
                });
              },
              buttonHeight: 40,
              dropdownMaxHeight: 200,
              buttonWidth: 140,
              itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            ),
          );
        }
    );
  }
}
