import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/enum/spinner_options.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class PkflStatsDropdown extends ConsumerStatefulWidget {
  final Function(SpinnerOption? spinnerOption) onValueSelected;
  final SpinnerOption? initValue;
  const PkflStatsDropdown({
    Key? key,
    required this.onValueSelected,
    this.initValue,
  }) : super(key: key);

  @override
  ConsumerState<PkflStatsDropdown> createState() => _PkflStatsDropdownState();
}

class _PkflStatsDropdownState extends ConsumerState<PkflStatsDropdown> {

  SpinnerOption? selectedValue;
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

  @override
  Widget build(BuildContext context) {
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
              items: _addDividersAfterItems(SpinnerOption.values),
              value: selectedValue ?? widget.initValue ?? SpinnerOption.values[0],
              onChanged: (value) {
                setState(() {
                  selectedValue = value as SpinnerOption;
                  widget.onValueSelected(value);
                });
              },
            ),
          );
  }
}
