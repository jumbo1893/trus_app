import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class PlayerApiDropdown extends StatelessWidget {
  final void Function(PlayerApiModel player) onPlayerSelected;

  final AsyncValue<List<PlayerApiModel>> players;

  final VoidCallback? onRetry;

  const PlayerApiDropdown({
    super.key,
    required this.onPlayerSelected,
    required this.players,
    this.onRetry,
  });

  List<DropdownMenuItem<PlayerApiModel>> _addDividersAfterItems(
      List<PlayerApiModel> items,
      ) {
    final menuItems = <DropdownMenuItem<PlayerApiModel>>[];
    for (var item in items) {
      menuItems.addAll([
        DropdownMenuItem<PlayerApiModel>(
          value: item,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(item.name, style: const TextStyle(fontSize: 14)),
          ),
        ),
        if (item != items.last)
          const DropdownMenuItem<PlayerApiModel>(
            enabled: false,
            child: Divider(),
          ),
      ]);
    }
    return menuItems;
  }

  List<double> _getCustomItemsHeights(int itemsLength) {
    final itemsHeights = <double>[];
    for (var i = 0; i < (itemsLength * 2) - 1; i++) {
      if (i.isEven) itemsHeights.add(40);
      if (i.isOdd) itemsHeights.add(4);
    }
    return itemsHeights;
  }

  @override
  Widget build(BuildContext context) {
    return players.when(
      loading: () => const Loader(),
      error: (e, st) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 8),
            const Text("Nelze načíst hráče"),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(onPressed: onRetry, child: const Text("Zkusit znovu")),
            ],
          ],
        );
      },
      data: (list) {
        if (list.isEmpty) {
          return const Text("Žádní hráči");
        }

        return DropdownButtonHideUnderline(
          child: DropdownButton2<PlayerApiModel>(
            isExpanded: true,
            hint: Text(
              'Vyber hráče',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
            items: _addDividersAfterItems(list),
            onChanged: (value) {
              if (value == null) return;
              onPlayerSelected(value);
            },
            buttonStyleData: const ButtonStyleData(height: 40, width: 140),
            dropdownStyleData: const DropdownStyleData(maxHeight: 200),
            menuItemStyleData: MenuItemStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              customHeights: _getCustomItemsHeights(list.length),
            ),
          ),
        );
      },
    );
  }
}