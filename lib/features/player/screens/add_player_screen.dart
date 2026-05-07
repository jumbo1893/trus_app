import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/bar/action_button_item.dart';
import '../../../common/widgets/dropdown/custom_dropdown_sheet.dart';
import '../../../common/widgets/rows/app_date_field.dart';
import '../../../common/widgets/rows/app_switch_field.dart';
import '../../../common/widgets/rows/app_text_input_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../controller/player_edit_notifier.dart';
import '../player_notifier_args.dart';

class AddPlayerScreen extends CustomConsumerStatefulWidget {
  static const String id = "add-player-screen";

  const AddPlayerScreen({
    Key? key,
  }) : super(key: key, title: "Přidat hráče", name: id);

  @override
  ConsumerState<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends ConsumerState<AddPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    const PlayerNotifierArgs arg = PlayerNotifierArgs();

    final notifier = ref.read(playerEditNotifierProvider(arg).notifier);
    final state = ref.watch(playerEditNotifierProvider(arg));

    return BaseFormScreen(
      headerTitle: "Nový hráč",
      headerText: "Vyplň základní údaje hráče",
      fields: [
        FormFieldWrapper(
          label: "Přezdívka",
          error: state.errors["name"],
          child: AppTextInputField(
            value: state.name,
            onChanged: notifier.setName,
          ),
        ),
        FormFieldWrapper(
          label: "Jméno hráče",
          child: CustomDropdownSheet(
            state: state,
            notifier: notifier,
            hint: "Vyber hráče",
          ),
        ),
        FormFieldWrapper(
          label: "Datum narození",
          error: state.errors["fromDate"],
          child: AppDateField(
            label: "Datum narození",
            value: state.birthdate,
            onChanged: notifier.setBirthday,
          ),
        ),
        FormFieldWrapper(
          label: "Fanoušek",
          child: AppSwitchField(
            text: "fanoušek?",
            value: state.fan,
            onChanged: notifier.setFan,
          ),
        ),
        FormFieldWrapper(
          label: "Aktivní",
          child: AppSwitchField(
            text: "aktivní?",
            value: state.active,
            onChanged: notifier.setActive,
          ),
        ),
      ],
      actions: [
        ActionButtonItem(
          label: "Uložit hráče",
          onPressed: () => notifier.submitCrud(Crud.create),
          type: ActionButtonType.primary,
        ),
      ],
    );
  }
}