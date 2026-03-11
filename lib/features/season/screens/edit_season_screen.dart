import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/button/simple_crud_button.dart';
import '../../../common/widgets/rows/row_date_picker.dart';
import '../../../common/widgets/rows/row_text_field.dart';
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
  ConsumerState<EditSeasonScreen> createState() => _EditSeasonScreenState();
}

class _EditSeasonScreenState extends ConsumerState<EditSeasonScreen> {
  @override
  Widget build(BuildContext context) {
    final season = ref.watch(seasonNotifierProvider).selectedSeason;
    final state = ref.watch(seasonEditProvider(season));
    final notifier = ref.read(seasonEditProvider(season).notifier);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          RowTextField(
            label: "Název",
            textFieldText: "Název sezony:",
            value: state.name,
            onChanged: notifier.setName,
            error: state.errors["name"],
          ),
          const SizedBox(height: 10),
          RowDatePicker(
            textFieldText: "Začátek sezony",
            value: state.from,
            onChanged: notifier.setFrom,
            error: state.errors["fromDate"],
          ),
          const SizedBox(height: 10),
          RowDatePicker(
            textFieldText: "Konec sezony",
            value: state.to,
            onChanged: notifier.setTo,
            error: state.errors["toDate"],
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          SimpleCrudButton(
            onPressed: () async => notifier.submitCrud(Crud.update,),
            text: "Potvrď změny",
          ),
          const SizedBox(height: 10),
          SimpleCrudButton(
            onPressed: () async => notifier.submitCrud(Crud.delete,),
            text: "Smaž sezonu",
            deleteConfirmationText:
                "Opravdu chcete smazat sezonu ${state.model?.name}?",
          ),
        ],
      ),
    );
  }
}
