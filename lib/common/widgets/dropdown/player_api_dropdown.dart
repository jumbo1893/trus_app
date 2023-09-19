import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/home/controller/home_controller.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:trus_app/models/api/player_api_model.dart';

class PlayerApiDropdown extends ConsumerStatefulWidget {
  final Function(PlayerApiModel player) onPlayerSelected;
  const PlayerApiDropdown({
    Key? key,
    required this.onPlayerSelected,
  }) : super(key: key);

  @override
  ConsumerState<PlayerApiDropdown> createState() => _PlayerApiDropdownState();
}

class _PlayerApiDropdownState extends ConsumerState<PlayerApiDropdown> {
  List<DropdownMenuItem<PlayerApiModel>> _addDividersAfterItems(
      List<PlayerApiModel> items) {
    List<DropdownMenuItem<PlayerApiModel>> menuItems = [];
    for (var item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<PlayerApiModel>(
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
            const DropdownMenuItem<PlayerApiModel>(
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
    return FutureBuilder<List<PlayerApiModel>>(
        future: ref.watch(homeControllerProvider).getModels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          } else if (snapshot.hasError) {
            return Container();
          }
          List<PlayerApiModel> players = snapshot.data!;

          return DropdownButtonHideUnderline(
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
              onChanged: (value) {
                widget.onPlayerSelected(value as PlayerApiModel);
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
        });
  }
}
