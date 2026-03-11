import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/rows/row_multi_select.dart';
import 'package:trus_app/features/match/controller/edit/match_edit_notifier.dart';

import '../../../common/widgets/button/simple_crud_button.dart';
import '../../../common/widgets/rows/row_custom_dropdown.dart';
import '../../../common/widgets/rows/row_date_picker.dart';
import '../../../common/widgets/rows/row_switch.dart';
import '../../../common/widgets/rows/row_text_field.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../../main/controller/screen_variables_notifier.dart';
class AddMatchScreen extends CustomConsumerStatefulWidget {
  static const String id = "add-match-screen";

  const AddMatchScreen({
    Key? key,
  }) : super(key: key, title: "Přidat zápas", name: id);

  @override
  ConsumerState<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends ConsumerState<AddMatchScreen> {
  @override
  Widget build(BuildContext context) {
    final arg = ref.watch(matchNotifierArgsProvider);
    final notifier = ref.read(matchEditNotifierProvider(arg).notifier);
    final state = ref.watch(matchEditNotifierProvider(arg));
    return Padding(
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
            onChanged: (models) =>  notifier.setSelectedPlayers(models, false),
          ),
          const SizedBox(height: 10),
          RowMultiSelect(
            label: "Vyber fanoušky",
            models: state.allFans,
            selectedModels: state.selectedFans,
            onChanged: (models) =>  notifier.setSelectedPlayers(models, true),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          SimpleCrudButton(
            onPressed: () async => notifier.submitCrud(Crud.create, false),
            text: "Ulož zápas",
          ),
          const SizedBox(height: 10),
          SimpleCrudButton(
            onPressed: () async => notifier.submitCrud(Crud.create, true),
            text: "Ulož zápas a přidej góly",
          ),
        ],
      ),
    );
  }
}
