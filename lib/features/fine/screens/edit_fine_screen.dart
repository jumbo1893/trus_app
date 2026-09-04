import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/controller/fine_edit_notifier.dart';
import 'package:trus_app/features/fine/controller/fine_notifier.dart';

import '../../../common/widgets/bar/action_button_item.dart';
import '../../../common/widgets/bottomsheet/confirm_action_bottom_sheet.dart';
import '../../../common/widgets/box/app_warning_box.dart';
import '../../../common/widgets/rows/app_read_only_field.dart';
import '../../../common/widgets/rows/app_text_input_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';

class EditFineScreen extends CustomConsumerStatefulWidget {
  static const String id = "edit-fine-screen";

  const EditFineScreen({Key? key})
    : super(key: key, title: "Upravit pokutu", name: id);

  @override
  ConsumerState<EditFineScreen> createState() => _EditFineScreenState();
}

class _EditFineScreenState extends ConsumerState<EditFineScreen> {
  @override
  Widget build(BuildContext context) {
    final fine = ref.watch(fineNotifierProvider).selectedFine;
    final state = ref.watch(fineEditProvider(fine));
    final notifier = ref.read(fineEditProvider(fine).notifier);

    return BaseFormScreen(
      headerTitle: state.name,
      headerText: "${state.amount} Kč",
      fields: [
        FormFieldWrapper(
          label: "Název pokuty",
          error: state.errors["name"],
          child: state.model?.editable ?? true
              ? AppTextInputField(
                  value: state.name,
                  onChanged: notifier.setName,
                )
              : AppReadOnlyField(value: state.name),
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
        const AppWarningBox(
          text:
              "Změna částky se použije jen na nově udělené pokuty. "
              "Dříve udělené pokuty zůstanou beze změny.",
        ),
      ],
      actions: [
        ActionButtonItem(
          label: "Uložit",
          onPressed: () => notifier.submitCrud(Crud.update),
          type: ActionButtonType.primary,
        ),
        if (state.model?.editable ?? true)
          ActionButtonItem(
            label: "Smazat",
            onPressed: () {
              ConfirmActionBottomSheet.show(
                context,
                title: "Smazat pokutu",
                message:
                    "Opravdu chcete smazat pokutu ${state.model?.name ?? state.name}?",
                confirmText: "Smazat",
                cancelText: "Zrušit",
                icon: Icons.delete_outline_rounded,
                isDanger: true,
                onConfirm: () async => notifier.submitCrud(Crud.delete),
              );
            },
            type: ActionButtonType.danger,
          ),
      ],
    );
  }
}
