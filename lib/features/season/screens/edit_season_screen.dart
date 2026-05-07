import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/bar/action_button_item.dart';
import '../../../common/widgets/bottomsheet/confirm_action_bottom_sheet.dart';
import '../../../common/widgets/rows/app_date_field.dart';
import '../../../common/widgets/rows/app_text_input_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../controller/season_edit_notifier.dart';
import '../controller/season_notifier.dart';

class EditSeasonScreen extends CustomConsumerStatefulWidget {
  static const String id = "edit-season-screen";

  const EditSeasonScreen({
    Key? key,
  }) : super(key: key, title: "Upravit sezonu", name: id);

  @override
  ConsumerState<EditSeasonScreen> createState() =>
      _EditSeasonScreenState();
}

class _EditSeasonScreenState extends ConsumerState<EditSeasonScreen> {
  @override
  Widget build(BuildContext context) {
    final season = ref.watch(seasonNotifierProvider).selectedSeason;
    final state = ref.watch(seasonEditProvider(season));
    final notifier = ref.read(seasonEditProvider(season).notifier);

    return BaseFormScreen(
      headerTitle: "Upravit sezonu",
      headerText: state.name,
      fields: [
        FormFieldWrapper(
          label: "Název sezony",
          error: state.errors["name"],
          child: AppTextInputField(
            value: state.name,
            onChanged: notifier.setName,
          ),
        ),
        FormFieldWrapper(
          label: "Začátek sezony",
          error: state.errors["fromDate"],
          child: AppDateField(
            label: "Začátek sezony",
            value: state.from,
            onChanged: notifier.setFrom,
          ),
        ),
        FormFieldWrapper(
          label: "Konec sezony",
          error: state.errors["toDate"],
          child: AppDateField(
            label: "Konec sezony",
            value: state.to,
            onChanged: notifier.setTo,
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
              title: "Smazat sezonu",
              message:
              "Opravdu chcete smazat sezonu ${state.model?.name ?? state.name}?",
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