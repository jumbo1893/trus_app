import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';

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
  final bool password;
  final StringControllerMixin stringControllerMixin;
  final String hashKey;
  final bool editEnabled;
  final bool showLabel;

  const RowTextFieldStream(
      {required Key key,
      required this.size,
      required this.padding,
      required this.labelText,
      required this.textFieldText,
      required this.stringControllerMixin,
      required this.hashKey,
      this.number = false,
      this.password = false,
      this.editEnabled = true,
      this.showLabel = true})
      : super(key: key);

  @override
  State<RowTextFieldStream> createState() => _RowTextFieldStream();
}

class _RowTextFieldStream extends State<RowTextFieldStream> {
  String errorText = "";
  final _nameController = TextEditingController();
  StreamSubscription<String>? _textStreamSubscription;

  @override
  void initState() {
    super.initState();
    _textStreamSubscription = widget.stringControllerMixin
        .stringValue(widget.hashKey)
        .listen((String name) {
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
  }

  @override
  void dispose() {
    _textStreamSubscription?.cancel(); // Použij ? pro bezpečné volání
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: widget.stringControllerMixin.stringValue(widget.hashKey),
      builder: (context, snapshot) {
        String name = snapshot.data ??
            widget.stringControllerMixin.stringValues[widget.hashKey]!;

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
        if (widget.showLabel) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: (widget.size.width / 3) - widget.padding,
                  child: CustomText(text: widget.textFieldText)),
              SizedBox(
                  width: (widget.size.width / 1.5) - widget.padding,
                  child: editTextWidget(
                      widget.hashKey,
                      widget.stringControllerMixin,
                      widget.labelText,
                      errorText,
                      _nameController,
                      widget.key!,
                      widget.number,
                      widget.password,
                      widget.editEnabled)),
            ],
          );
        } else {
          return editTextWidget(
              widget.hashKey,
              widget.stringControllerMixin,
              widget.labelText,
              errorText,
              _nameController,
              widget.key!,
              widget.number,
              widget.password,
              widget.editEnabled);
        }
      },
    );
  }

  Widget editTextWidget(
      String hashKey,
      StringControllerMixin stringControllerMixin,
      String labelText,
      String errorText,
      TextEditingController nameController,
      Key key,
      bool number,
      bool password,
      bool editEnabled) {
    return StreamBuilder<String>(
      stream: stringControllerMixin.stringErrorText(hashKey),
      builder: (context, errorSnapshot) {
        if (errorSnapshot.hasData) {
          errorText = errorSnapshot.data!;
        }
        return CustomTextField(
          key: ValueKey("${getValueFromValueKey(key)}_text"),
          textController: nameController,
          labelText: labelText,
          errorText: errorText,
          number: number,
          password: password,
          onChanged: (string) =>
              stringControllerMixin.setStringValue(string, hashKey),
          enabled: editEnabled,
        );
      },
    );
  }
}
