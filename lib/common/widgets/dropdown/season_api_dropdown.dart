import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:trus_app/models/api/season_api_model.dart';

class SeasonApiDropdown extends ConsumerStatefulWidget {
  final Function(SeasonApiModel seasonModel) onSeasonSelected;
  final Future<List<SeasonApiModel>>? seasonList;
  final Stream<SeasonApiModel> pickedSeason;
  final VoidCallback? initData;
  const SeasonApiDropdown({
    Key? key,
    required this.onSeasonSelected,
    required this.seasonList,
    required this.pickedSeason,
    this.initData,
  }) : super(key: key);

  @override
  ConsumerState<SeasonApiDropdown> createState() => _SeasonApiDropdownState();
}

class _SeasonApiDropdownState extends ConsumerState<SeasonApiDropdown> {

  List<DropdownMenuItem<SeasonApiModel>> _addDividersAfterItems(List<SeasonApiModel> items) {
    List<DropdownMenuItem<SeasonApiModel>> menuItems = [];
    for (var item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<SeasonApiModel>(
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
            const DropdownMenuItem<SeasonApiModel>(
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
    return FutureBuilder<List<SeasonApiModel>>(
        future: widget.seasonList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          else if (snapshot.hasError) {
            return Container();
          }
          List<SeasonApiModel> seasons = snapshot.data!;
          return StreamBuilder<SeasonApiModel>(
            stream: widget.pickedSeason,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                if(widget.initData != null) {
                  widget.initData!();
                }
                else {
                  widget.onSeasonSelected(seasons[0]);
                }
                return const Loader();
              }
              SeasonApiModel season = snapshot.data!;
              return DropdownButtonHideUnderline(
                key: const ValueKey("season_items"),
                child: DropdownButton2(
                  isExpanded: true,
                  hint: Text(
                    'Vyber sezonu',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  items: _addDividersAfterItems(seasons),
                  value: season,
                  onChanged: (value) {
                    //setState(() {
                      //selectedValue = value as SeasonModel;
                      widget.onSeasonSelected(value as SeasonApiModel);
                    //});
                  },
                  buttonStyleData: const ButtonStyleData(height: 40, width: 140),
                  dropdownStyleData: const DropdownStyleData(
                    maxHeight: 200,
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    customHeights: _getCustomItemsHeights(seasons.length),
                  ),
                ),
              );
            }
          );
        }
    );
  }
}
