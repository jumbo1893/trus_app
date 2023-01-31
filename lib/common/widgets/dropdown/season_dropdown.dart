import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/season/controller/season_controller.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:trus_app/models/season_model.dart';

class SeasonDropdown extends ConsumerStatefulWidget {
  final Function(SeasonModel? seasonModel) onSeasonSelected;
  bool automaticSeason;
  bool allSeasons;
  bool otherSeason;
  SeasonModel? initSeason;
  SeasonDropdown({
    Key? key,
    required this.onSeasonSelected,
    this.automaticSeason = false,
    this.allSeasons = false,
    this.otherSeason = false,
    this.initSeason,
  }) : super(key: key);

  @override
  ConsumerState<SeasonDropdown> createState() => _SeasonDropdownState();
}

class _SeasonDropdownState extends ConsumerState<SeasonDropdown> {

  SeasonModel? selectedValue;

  List<DropdownMenuItem<SeasonModel>> _addDividersAfterItems(List<SeasonModel> items) {
    List<DropdownMenuItem<SeasonModel>> menuItems = [];
    for (var item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<SeasonModel>(
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
            const DropdownMenuItem<SeasonModel>(
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
    return StreamBuilder<List<SeasonModel>>(
        stream: ref.watch(seasonControllerProvider).seasons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          List<SeasonModel> seasons = snapshot.data!;
          if (widget.allSeasons) {
            seasons.insert(0, SeasonModel.allSeason());
          }
          if (widget.otherSeason) {
            seasons.add(SeasonModel.otherSeason());
          }
          if (widget.automaticSeason) {
            seasons.insert(0, SeasonModel.automaticSeason());
          }
          return DropdownButtonHideUnderline(
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
              customItemsHeights: _getCustomItemsHeights(snapshot.data!.length),
              value: selectedValue ?? widget.initSeason ?? seasons[0],
              onChanged: (value) {
                setState(() {
                  selectedValue = value as SeasonModel;
                  widget.onSeasonSelected(value);
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
