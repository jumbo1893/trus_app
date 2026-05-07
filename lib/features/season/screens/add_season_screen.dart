import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/season/controller/season_edit_notifier.dart';
import 'package:trus_app/models/enum/crud.dart';

import '../../../common/widgets/bar/action_button_item.dart';
import '../../../common/widgets/rows/app_date_field.dart';
import '../../../common/widgets/rows/app_text_input_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';

class AddSeasonScreen extends CustomConsumerStatefulWidget {
  static const String id = "add-season-screen";

  const AddSeasonScreen({
    Key? key,
  }) : super(key: key, title: "Přidat sezonu", name: id);

  @override
  ConsumerState<AddSeasonScreen> createState() => _AddSeasonScreenState();
}

class _AddSeasonScreenState extends ConsumerState<AddSeasonScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seasonEditProvider(null));
    final notifier = ref.read(seasonEditProvider(null).notifier);

    return BaseFormScreen(
      headerTitle: "Nová sezona",
      headerText: "Vyplň název a časové období",
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
          label: "Uložit sezonu",
          onPressed: () => notifier.submitCrud(Crud.create),
          type: ActionButtonType.primary,
        ),
      ],
    );
  }
}