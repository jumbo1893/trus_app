import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:trus_app/models/api/pkfl/pkfl_match_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../models/api/pkfl/pkfl_player_api_model.dart';

class PkflPlayerApiDropdown extends ConsumerStatefulWidget {
  final Function(PkflPlayerApiModel pkflPlayerApiModel) onPlayerSelected;
  final Future<List<PkflPlayerApiModel>>? playerList;
  final Stream<PkflPlayerApiModel> pickedPlayer;
  final VoidCallback? initData;
  const PkflPlayerApiDropdown({
    Key? key,
    required this.onPlayerSelected,
    required this.playerList,
    required this.pickedPlayer,
    this.initData,
  }) : super(key: key);

  @override
  ConsumerState<PkflPlayerApiDropdown> createState() => _PkflPlayerApiDropdownState();
}

class _PkflPlayerApiDropdownState extends ConsumerState<PkflPlayerApiDropdown> {

  List<DropdownMenuItem<PkflPlayerApiModel>> _addDividersAfterItems(List<PkflPlayerApiModel> items) {
    List<DropdownMenuItem<PkflPlayerApiModel>> menuItems = [];
    for (var item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<PkflPlayerApiModel>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          //If it's last item, we will not add Divider after it.
          if (item != items.last)
            const DropdownMenuItem<PkflPlayerApiModel>(
              enabled: false,
              child: Divider(),
            ),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PkflPlayerApiModel>>(
        future: widget.playerList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          else if (snapshot.hasError) {
            return Container();
          }
          List<PkflPlayerApiModel> players = snapshot.data!;
          return StreamBuilder<PkflPlayerApiModel>(
            stream: widget.pickedPlayer,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                if(widget.initData != null) {
                  widget.initData!();
                }
                else {
                  widget.onPlayerSelected(players[0]);
                }
                return const Loader();
              }
              PkflPlayerApiModel player = snapshot.data!;
              return DropdownButtonHideUnderline(
                key: const ValueKey("season_items"),
                child: DropdownButton2(
                  isExpanded: true,
                  hint: Text(
                    'Vyber hráče',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  items: _addDividersAfterItems(players),
                  value: player,
                  onChanged: (value) {
                    //setState(() {
                      //selectedValue = value as SeasonModel;
                      widget.onPlayerSelected(value as PkflPlayerApiModel);
                    //});
                  },
                  buttonStyleData: const ButtonStyleData(height: 40, width: 140),
                  dropdownStyleData: const DropdownStyleData(
                    maxHeight: 200,
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    customHeights: _getCustomItemsHeights(players.length),
                  ),
                ),
              );
            }
          );
        }
    );
  }
}
