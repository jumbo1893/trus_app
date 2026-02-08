import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/loader/loading_overlay.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';

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
    return LoadingOverlay(
        state: state,
        onClearError: notifier.clearErrorMessage,
        child: Padding(
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
                onPressed: () async => await notifier.submit(
                    "Ukládám sezonu...",
                    "Sezona byla úspěšně uložena",
                    SeasonScreen.id,
                    Crud.update,
                    seasonNotifierProvider),
                text: "Potvrď změny",
              ),
              const SizedBox(height: 10),
              SimpleCrudButton(
                onPressed: () async => await notifier.submit(
                    "Mažu sezonu...",
                    "Sezona byla úspěšně smazána",
                    SeasonScreen.id,
                    Crud.delete,
                    seasonNotifierProvider),
                text: "Smaž sezonu",
                deleteConfirmationText:
                    "Opravdu chcete smazat sezonu ${state.model?.name}?",
              ),
            ],
          ),
        ));
  }
}
