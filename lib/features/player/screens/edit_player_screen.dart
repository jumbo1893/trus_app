import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/widgets/bar/action_button_item.dart';
import '../../../common/widgets/bottomsheet/confirm_action_bottom_sheet.dart';
import '../../../common/widgets/dropdown/custom_dropdown_sheet.dart';
import '../../../common/widgets/rows/app_date_field.dart';
import '../../../common/widgets/rows/app_switch_field.dart';
import '../../../common/widgets/rows/app_text_input_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/api/player/player_api_model.dart';
import '../../../models/enum/crud.dart';
import '../controller/player_edit_notifier.dart';
import '../player_notifier_args.dart';

class EditPlayerScreen extends CustomConsumerStatefulWidget {
  static const String id = "edit-player-screen";

  const EditPlayerScreen({
    Key? key,
  }) : super(key: key, title: "Upravit hráče", name: id);

  @override
  ConsumerState<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends ConsumerState<EditPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final PlayerApiModel player =
        ref.watch(screenVariablesNotifierProvider).playerModel;

    final PlayerNotifierArgs arg = PlayerNotifierArgs.edit(player.id);
    final notifier = ref.read(playerEditNotifierProvider(arg).notifier);
    final state = ref.watch(playerEditNotifierProvider(arg));

    return BaseFormScreen(
      headerTitle: "${state.fan? "fanoušek": "hráč"}: ${state.name}",
      headerText: "Datum narození: ${dateTimeToString(state.birthdate)}",
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
          error: state.errors["football_player"],
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
          label: "Uložit",
          onPressed: () => notifier.submitCrud(Crud.update),
          type: ActionButtonType.primary,
        ),
        ActionButtonItem(
          label: "Smazat",
          onPressed: () {
            ConfirmActionBottomSheet.show(
              context,
              title: "Smazat hráče",
              message:
              "Opravdu chcete smazat hráče ${state.model?.name ?? state.name}?",
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