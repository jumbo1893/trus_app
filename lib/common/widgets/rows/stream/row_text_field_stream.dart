import 'dart:async';

import 'package:flutter/material.dart';

import '../../../utils/utils.dart';
import '../../custom_text.dart';
import '../../custom_text_field.dart';
import '../../loader.dart';

class RowTextFieldStream extends StatefulWidget {
  final Size size;
  final double padding;
  final String labelText;
  final String textFieldText;
  final bool number;
  final Stream<String> textStream;
  final Stream<String>? errorTextStream;
  final Function(String) onTextChanged;
  const RowTextFieldStream(
      {required Key key,
      required this.size,
      required this.padding,
      required this.labelText,
      required this.textFieldText,
      required this.textStream,
      required this.errorTextStream,
        required this.onTextChanged,
      this.number = false})
      : super(key: key);

  @override
  State<RowTextFieldStream> createState() => _RowTextFieldStream();
}

class _RowTextFieldStream extends State<RowTextFieldStream> {
  String errorText = "";
  final _nameController = TextEditingController();
  late StreamSubscription<String> _textStreamSubscription;

  @override
  void dispose() {
    _textStreamSubscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: widget.textStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          String name = snapshot.data!;
          _textStreamSubscription = widget.textStream.listen((String name) {
            final updatedSelection = _nameController.selection.copyWith(
              baseOffset: name.length < _nameController.selection.baseOffset
                  ? name.length
                  : _nameController.selection.baseOffset,
              extentOffset: name.length < _nameController.selection.extentOffset
                  ? name.length
                  : _nameController.selection.extentOffset,
            );
            _nameController.value = _nameController.value.copyWith(
              text: name,
              selection: updatedSelection,
            );
          });
          final updatedSelection = _nameController.selection.copyWith(
            baseOffset: name.length < _nameController.selection.baseOffset
                ? name.length
                : _nameController.selection.baseOffset,
            extentOffset: name.length < _nameController.selection.extentOffset
                ? name.length
                : _nameController.selection.extentOffset,
          );
          _nameController.value = _nameController.value.copyWith(
            text: name,
            selection: updatedSelection,
          );
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: (widget.size.width / 3) - widget.padding,
                  child: CustomText(text: widget.textFieldText)),
              SizedBox(
                width: (widget.size.width / 1.5) - widget.padding,
                child: StreamBuilder<String>(
                  stream: widget.errorTextStream,
                  builder: (context, errorSnapshot) {
                    if(errorSnapshot.hasData) {
                      print(errorSnapshot.data);
                      errorText = errorSnapshot.data!;
                    }
                    return CustomTextField(
                      key: ValueKey("${getValueFromValueKey(widget.key!)}_text"),
                      textController: _nameController,
                      labelText: widget.labelText,
                      errorText: errorText,
                      number: widget.number,
                      onChanged: widget.onTextChanged,
                    );
                  }
                ),
              ),
            ],
          );
        });
  }
}
