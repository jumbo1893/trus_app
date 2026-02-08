import 'package:flutter/material.dart';
import 'package:trus_app/features/mixin/dropdown_controller_mixin.dart';

import 'custom_dropdown.dart';

class CustomDropdownWithMixin extends StatefulWidget {
  final String hint;
  final DropdownControllerMixin dropdownControllerMixin;
  final String hashKey;
  final bool editEnabled;

  const CustomDropdownWithMixin({
    Key? key,
    required this.hint,
    required this.dropdownControllerMixin,
    required this.hashKey,
    this.editEnabled = true
  }) : super(key: key);

  @override
  State<CustomDropdownWithMixin> createState() =>
      _CustomDropdownWithMixin();
}

class _CustomDropdownWithMixin extends State<CustomDropdownWithMixin> {
  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      onItemSelected: (model) => widget.dropdownControllerMixin.setDropdownItem(model, widget.hashKey),
      dropdownList: widget.dropdownControllerMixin.dropdownItemList(widget.hashKey),
      pickedItem: widget.dropdownControllerMixin.dropdownItem(widget.hashKey),
      initData: () => widget.dropdownControllerMixin.initDropdownItem(widget.hashKey),
      dropDownListStream: widget.dropdownControllerMixin.dropdownItemListStream(widget.hashKey),
      hint: widget.hint,
      enabled: widget.editEnabled,
    );
  }
}
