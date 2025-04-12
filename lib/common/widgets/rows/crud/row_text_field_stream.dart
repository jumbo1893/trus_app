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
  final StringControllerMixin stringControllerMixin;
  final String hashKey;
  final bool editEnabled;
  const RowTextFieldStream(
      {required Key key,
      required this.size,
      required this.padding,
      required this.labelText,
      required this.textFieldText,
        required this.stringControllerMixin,
        required this.hashKey,
        this.number = false,
        this.editEnabled = true
      })
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
    _textStreamSubscription = widget.stringControllerMixin.stringValue(widget.hashKey).listen((String name) {
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        String name = snapshot.data ?? "";

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
                stream: widget.stringControllerMixin.stringErrorText(widget.hashKey),
                builder: (context, errorSnapshot) {
                  if (errorSnapshot.hasData) {
                    errorText = errorSnapshot.data!;
                  }
                  return CustomTextField(
                    key: ValueKey("${getValueFromValueKey(widget.key!)}_text"),
                    textController: _nameController,
                    labelText: widget.labelText,
                    errorText: errorText,
                    number: widget.number,
                    onChanged: (string) => widget.stringControllerMixin.setStringValue(string, widget.hashKey),
                    enabled: widget.editEnabled,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

