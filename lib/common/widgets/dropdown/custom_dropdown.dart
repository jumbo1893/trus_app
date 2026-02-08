import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';

import '../../../models/api/interfaces/dropdown_item.dart';

class CustomDropdown extends ConsumerStatefulWidget {
  final Function(DropdownItem dropdownItem) onItemSelected;
  final Future<List<DropdownItem>>? dropdownList;
  final Stream<DropdownItem?> pickedItem;
  final Stream<List<DropdownItem>>? dropDownListStream;
  final VoidCallback? initData;
  final String hint;
  final bool enabled;

  const CustomDropdown({
    Key? key,
    required this.onItemSelected,
    required this.dropdownList,
    required this.pickedItem,
    required this.hint,
    this.dropDownListStream = const Stream.empty(),
    this.initData,
    this.enabled = true,
  }) : super(key: key);

  @override
  ConsumerState<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends ConsumerState<CustomDropdown> {
  List<DropdownMenuItem<DropdownItem>> _addDividersAfterItems(
      List<DropdownItem> items) {
    List<DropdownMenuItem<DropdownItem>> menuItems = [];
    for (var item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<DropdownItem>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.dropdownItem(),
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          //If it's last item, we will not add Divider after it.
          if (item != items.last)
            const DropdownMenuItem<DropdownItem>(
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
    return FutureBuilder<List<DropdownItem>>(
        future: widget.dropdownList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          } else if (snapshot.hasError) {
            return Container();
          }
          List<DropdownItem> dropdownItems = snapshot.data!;
          return StreamBuilder<List<DropdownItem>>(
              stream: widget.dropDownListStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  dropdownItems = snapshot.data!;
                }
                return StreamBuilder<DropdownItem?>(
                    stream: widget.pickedItem,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (widget.initData != null) {
                          widget.initData!();
                        } else {
                          widget.onItemSelected(dropdownItems[0]);
                        }
                        return const Loader();
                      }
                      DropdownItem dropdownItem = snapshot.data!;
                      return DropdownButtonHideUnderline(
                        key: const ValueKey("season_items"),
                        child: DropdownButton2(
                          isExpanded: true,
                          hint: Text(
                            widget.hint,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme
                                  .of(context)
                                  .hintColor,
                            ),
                          ),
                          items: _addDividersAfterItems(dropdownItems),
                          value: dropdownItem,
                          onChanged: (value) {
                            widget.onItemSelected(value as DropdownItem);
                          },
                          buttonStyleData:
                          const ButtonStyleData(height: 40, width: 140),
                          dropdownStyleData: const DropdownStyleData(
                            maxHeight: 200,
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0),
                            customHeights:
                            _getCustomItemsHeights(dropdownItems.length),
                          ),
                        ),
                      );
                    });
              });
        });
  }
}
