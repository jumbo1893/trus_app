import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/season/controller/season_edit_notifier.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:trus_app/models/enum/crud.dart';

import '../../../common/widgets/button/simple_crud_button.dart';
import '../../../common/widgets/notifier/loader/loading_overlay.dart';
import '../../../common/widgets/rows/row_date_picker.dart';
import '../../../common/widgets/rows/row_text_field.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../controller/season_notifier.dart';

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
                    Crud.create,
                    seasonNotifierProvider),
                text: "Ulož pokutu",
              ),
            ],
          ),
        ));
  }
}
