import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/enum/spinner_options.dart';

import '../loader.dart';

class FootballStatsDropdown extends ConsumerStatefulWidget {
  final Function(SpinnerOption spinnerOption) onValueSelected;
  final VoidCallback? initOption;
  final Stream<SpinnerOption> pickedOption;
  const FootballStatsDropdown({
    Key? key,
    required this.onValueSelected,
    required this.pickedOption,
    required this.initOption,
  }) : super(key: key);

  @override
  ConsumerState<FootballStatsDropdown> createState() => _FootballStatsDropdownState();
}

class _FootballStatsDropdownState extends ConsumerState<FootballStatsDropdown> {

  List<SpinnerOption> spinnerOptions = SpinnerOption.values;
  List<DropdownMenuItem<SpinnerOption>> _addDividersAfterItems(List<SpinnerOption> items) {
    List<DropdownMenuItem<SpinnerOption>> menuItems = [];
    for (var item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<SpinnerOption>(
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
            const DropdownMenuItem<SpinnerOption>(
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
          return StreamBuilder<SpinnerOption>(
            stream: widget.pickedOption,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                if(widget.initOption != null) {
                  widget.initOption!();
                }
                else {
                  widget.onValueSelected(spinnerOptions[0]);
                }
                return const Loader();
              }
              SpinnerOption spinnerOption = snapshot.data!;
              return DropdownButtonHideUnderline(
                key: const ValueKey("spinner_options_items"),
                child: DropdownButton2(
                  isExpanded: true,
                  hint: Text(
                    'Vyber možnost',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  items: _addDividersAfterItems(spinnerOptions),
                  value: spinnerOption,
                  onChanged: (value) {
                    widget.onValueSelected(value as SpinnerOption);
                    //});
                  },
                  buttonStyleData: const ButtonStyleData(height: 40, width: 140),
                  dropdownStyleData: const DropdownStyleData(
                    maxHeight: 200,
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    customHeights: _getCustomItemsHeights(spinnerOptions.length),
                  ),
                ),
              );
            }
          );
  }
}
