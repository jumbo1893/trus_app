import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_state.dart';
import 'package:trus_app/models/api/interfaces/dropdown_item.dart';

import '../../../../colors.dart';
import '../../loader.dart';

class CustomDropdown extends ConsumerWidget {
  final String hint;
  final String? error;
  final bool enableBorder;
  final IDropdownState state;
  final IDropdownNotifier notifier;

  const CustomDropdown({
    Key? key,
    required this.hint,
    this.error,
    this.enableBorder = false,
    required this.state,
    required this.notifier,
  }) : super(key: key);

  List<DropdownMenuItem<DropdownItem>> _buildItems(
    List<DropdownItem> dropdownItems,
  ) {
    final List<DropdownMenuItem<DropdownItem>> items = [];

    for (final item in dropdownItems) {
      items.add(
        DropdownMenuItem<DropdownItem>(
          value: item,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              item.dropdownItem(),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );

      // Divider mezi položkami (ne za poslední)
      if (item != dropdownItems.last) {
        items.add(
          const DropdownMenuItem<DropdownItem>(
            enabled: false,
            child: Divider(),
          ),
        );
      }
    }
    return items;
  }

  List<double> _getCustomItemsHeights(int length) {
    final List<double> heights = [];
    for (int i = 0; i < (length * 2) - 1; i++) {
      heights.add(i.isEven ? 40 : 4);
    }
    return heights;
  }

  InputDecoration _decoration() {
    if (!enableBorder) {
      return InputDecoration(
        labelText: hint,
        errorText: (error != null && error!.isNotEmpty) ? error : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.only(left: 10, top: 10),
      );
    }

    return InputDecoration(
      labelText: hint,
      errorText: (error != null && error!.isNotEmpty) ? error : null,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: orangeColor),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: orangeColor),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.only(left: 10, top: 10),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return state.getDropdownItems().when(
          loading: () => const Loader(),
          error: (_, __) => const SizedBox(),
          data: (dropdownItems) {
            if (dropdownItems.isEmpty) {
              return const SizedBox();
            }

            return InputDecorator(
              decoration: _decoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<DropdownItem>(
                  isExpanded: true,
                  hint: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  value: state.getSelected(),
                  items: _buildItems(dropdownItems),
                  onChanged: (item) {
                    if (item != null) {
                      notifier.selectDropdown(item);
                    }
                  },
                  buttonStyleData: const ButtonStyleData(
                    height: 40,
                    width: double.infinity,
                  ),
                  dropdownStyleData: const DropdownStyleData(
                    maxHeight: 200,
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    customHeights: _getCustomItemsHeights(dropdownItems.length),
                  ),
                ),
              ),
            );
          },
        );
  }
}
