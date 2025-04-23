import 'package:flutter/material.dart';
import 'package:trus_app/features/mixin/dropdown_controller_mixin.dart';

import '../../../utils/utils.dart';
import '../../custom_text.dart';
import '../../dropdown/custom_dropdown.dart';

class RowApiModelDropDownStream extends StatefulWidget {
  final Size size;
  final double padding;
  final String text;
  final String hint;
  final DropdownControllerMixin dropdownControllerMixin;
  final String hashKey;
  final bool editEnabled;

  const RowApiModelDropDownStream({
    required Key key,
    required this.size,
    required this.padding,
    required this.text,
    required this.hint,
    required this.dropdownControllerMixin,
    required this.hashKey,
    this.editEnabled = true
  }) : super(key: key);

  @override
  State<RowApiModelDropDownStream> createState() =>
      _RowApiModelDropDownStream();
}

class _RowApiModelDropDownStream extends State<RowApiModelDropDownStream> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
          width: (widget.size.width / 3) - widget.padding,
          child: CustomText(
              text: widget.text,
              key: ValueKey("${getValueFromValueKey(widget.key!)}_text"))),
      SizedBox(
          width: (widget.size.width / 1.5) - widget.padding,
          child: CustomDropdown(
            key: ValueKey("${getValueFromValueKey(widget.key!)}_dropdown"),
            onItemSelected: (model) => widget.dropdownControllerMixin.setDropdownItem(model, widget.hashKey),
            dropdownList: widget.dropdownControllerMixin.dropdownItemList(widget.hashKey),
            pickedItem: widget.dropdownControllerMixin.dropdownItem(widget.hashKey),
            initData: () => widget.dropdownControllerMixin.initDropdownItem(widget.hashKey),
            dropDownListStream: widget.dropdownControllerMixin.dropdownItemListStream(widget.hashKey),
            hint: widget.hint,
            enabled: widget.editEnabled,
          )),
    ]);
  }
}
