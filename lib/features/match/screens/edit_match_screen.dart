import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';

import '../../../common/widgets/button/simple_crud_button.dart';
import '../../../common/widgets/notifier/loader/loading_overlay.dart';
import '../../../common/widgets/rows/row_custom_dropdown.dart';
import '../../../common/widgets/rows/row_date_picker.dart';
import '../../../common/widgets/rows/row_multi_select.dart';
import '../../../common/widgets/rows/row_switch.dart';
import '../../../common/widgets/rows/row_text_field.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';
import '../controller/edit/match_edit_notifier.dart';
import '../controller/match_notifier.dart';

class EditMatchScreen extends CustomConsumerStatefulWidget {
  static const String id = "edit-match-screen";

  const EditMatchScreen({
    Key? key,
  }) : super(key: key, title: "Upravit zápas", name: id);

  @override
  ConsumerState<EditMatchScreen> createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends ConsumerState<EditMatchScreen> {
  @override
  Widget build(BuildContext context) {
    final arg = ref.watch(matchNotifierArgsProvider);
    final notifier = ref.read(matchEditNotifierProvider(arg).notifier);
    final state = ref.watch(matchEditNotifierProvider(arg));
    return SingleChildScrollView(
      child: LoadingOverlay(
          state: state,
          onClearError: notifier.clearErrorMessage,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                RowTextField(
                  label: "jméno",
                  textFieldText: "Jméno soupeře:",
                  value: state.name,
                  onChanged: notifier.setName,
                  error: state.errors["name"],
                ),
                const SizedBox(height: 10),
                RowDatePicker(
                  textFieldText: "Datum zápasu:",
                  value: state.date,
                  onChanged: notifier.setDate,
                  error: state.errors["fromDate"],
                ),
                const SizedBox(height: 10),
                RowSwitch(
                  textFieldText: "domácí zápas?",
                  value: state.home,
                  onChanged: notifier.setHome,
                ),
                const SizedBox(height: 10),
                RowCustomDropdown(
                    text: 'Vyber sezonu',
                    hint: 'Vyber sezonu',
                    state: state,
                    notifier: notifier),
                const SizedBox(height: 10),
                RowMultiSelect(
                  label: "Vyber hráče",
                  models: state.allPlayers,
                  selectedModels: state.selectedPlayers,
                  onChanged: (models) =>
                      notifier.setSelectedPlayers(models, false),
                ),
                const SizedBox(height: 10),
                RowMultiSelect(
                  label: "Vyber fanoušky",
                  models: state.allFans,
                  selectedModels: state.selectedFans,
                  onChanged: (models) =>
                      notifier.setSelectedPlayers(models, true),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                SimpleCrudButton(
                  onPressed: () async =>
                  await notifier.submit(
                      "Ukládám zápas...",
                      "Zápas byl úspěšně uložen",
                      HomeScreen.id,
                      Crud.update,
                      matchNotifierProvider),
                  text: "Potvrď změny",
                ),
                const SizedBox(height: 10),
                SimpleCrudButton(
                  onPressed: () async =>
                  await notifier.submit(
                      "Ukládám zápas...",
                      "Zápas byl úspěšně uložen",
                      GoalScreen.id,
                      Crud.update,
                      matchNotifierProvider, onSuccessAction: (model) =>
                  {
                    ref.read(screenControllerProvider).setMatchId(model.id!),
                    ref.read(screenControllerProvider).changeFragment(
                        GoalScreen.id)
                  }),
                  text: "Potvrď a uprav góly",
                ),
                const SizedBox(height: 10),
                SimpleCrudButton(
                  onPressed: () async =>
                  await notifier.submit(
                      "Mažu zápas...",
                      "Zápas byl úspěšně smazán",
                      HomeScreen.id,
                      Crud.delete,
                      matchNotifierProvider),
                  text: "Smaž zápas",
                  deleteConfirmationText:
                  "Opravdu chcete smazat zápas ${state.model?.name}?",
                ),
              ],
            ),)
      ),
    );
  }
}