import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/controller/fine_edit_notifier.dart';

import '../../../common/widgets/bar/action_button_item.dart';
import '../../../common/widgets/rows/app_text_input_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';

class AddFineScreen extends CustomConsumerStatefulWidget {
  static const String id = "add-fine-screen";

  const AddFineScreen({
    Key? key,
  }) : super(key: key, title: "Přidat pokutu", name: id);

  @override
  ConsumerState<AddFineScreen> createState() => _AddFineScreenState();
}

class _AddFineScreenState extends ConsumerState<AddFineScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fineAddProvider);
    final notifier = ref.read(fineAddProvider.notifier);

    return BaseFormScreen(
      headerTitle: "Nová pokuta",
      headerText: "Vyplň název a částku pokuty",
      fields: [
        FormFieldWrapper(
          label: "Název pokuty",
          error: state.errors["name"],
          child: AppTextInputField(
            value: state.name,
            onChanged: notifier.setName,
          ),
        ),
        FormFieldWrapper(
          label: "Výše pokuty (Kč)",
          error: state.errors["amount"],
          child: AppTextInputField(
            value: state.amount,
            hintText: "Kč",
            keyboardType: TextInputType.number,
            onChanged: notifier.setAmount,
          ),
        ),
      ],
      actions: [
        ActionButtonItem(
          label: "Uložit pokutu",
          onPressed: () => notifier.submitCrud(Crud.create),
          type: ActionButtonType.primary,
        ),
      ],
    );
  }
}