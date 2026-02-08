import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/custom_dropdown.dart';

import '../custom_text.dart';
import '../notifier/dropdown/i_dropdown_notifier.dart';
import '../notifier/dropdown/i_dropdown_state.dart';



class RowCustomDropdown extends StatefulWidget {
  final String text;
  final String hint;
  final String? error;
  final IDropdownState state;
  final IDropdownNotifier notifier;

  const RowCustomDropdown({
    Key? key,

    required this.text,
    required this.hint,
    this.error,
    required this.state,
    required this.notifier,
  }) : super(key: key);

  @override
  State<RowCustomDropdown> createState() =>
      _RowCustomDropdown();
}

class _RowCustomDropdown extends State<RowCustomDropdown> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    const double padding = 8.0;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
          width: (size.width / 3) - padding,
          child: CustomText(
              text: widget.text,)),
      SizedBox(
          width: (size.width / 1.5) - padding,
          child: CustomDropdown(
           state: widget.state,
           error: widget.error,
           enableBorder: true,
           notifier: widget.notifier,
            hint: widget.hint,
          )),
    ]);
  }
}
