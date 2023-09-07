
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/rows/row_text_field.dart';

import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/rows/stream/row_text_field_stream.dart';
import '../../../models/enum/crud.dart';
import '../../notification/controller/notification_controller.dart';
import '../controller/fine_controller.dart';

class AddFineScreen extends ConsumerStatefulWidget {
  final VoidCallback onAddFinePressed;
  final bool isFocused;
  const AddFineScreen({
    Key? key,
    required this.onAddFinePressed,
    required this.isFocused,
  }) : super(key: key);

  @override
  ConsumerState<AddFineScreen> createState() => _AddFineScreenState();
}

class _AddFineScreenState extends ConsumerState<AddFineScreen> {

  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
    const double padding = 8.0;
    final size = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
    return ColumnFutureBuilder(
      loadModelFuture:
      ref.watch(fineControllerProvider).newFine(),
      columns: [
        RowTextFieldStream(
          size: size,
          labelText: "název",
          textFieldText: "Název pokuty:",
          padding: padding,
          textStream: ref.watch(fineControllerProvider).name(),
          errorTextStream: ref.watch(fineControllerProvider).nameErrorText(),
          onTextChanged: (name) =>
          {ref.watch(fineControllerProvider).setName(name)},
        ),
        const SizedBox(height: 10),
        RowTextFieldStream(
          size: size,
          labelText: "v Kč",
          textFieldText: "Výše pokuty:",
          padding: padding,
          textStream: ref.watch(fineControllerProvider).amount(),
          errorTextStream: ref.watch(fineControllerProvider).amountErrorText(),
          onTextChanged: (amount) =>
          {ref.watch(fineControllerProvider).setAmount(amount)},
          number: true,
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 10),
        CrudButton(
          text: "Přidej pokutu",
          context: context,
          crud: Crud.create,
          crudOperations: ref.read(fineControllerProvider),
          onOperationComplete: (id) {
            widget.onAddFinePressed();
          },
        )
      ], loadingScreen: null,
    );
    }
    else {
      return Container();
    }
  }
}
