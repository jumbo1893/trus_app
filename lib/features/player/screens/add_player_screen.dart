import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/button/simple_crud_button.dart';
import '../../../common/widgets/rows/row_custom_dropdown.dart';
import '../../../common/widgets/rows/row_date_picker.dart';
import '../../../common/widgets/rows/row_switch.dart';
import '../../../common/widgets/rows/row_text_field.dart';
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
    PlayerNotifierArgs arg = const PlayerNotifierArgs();
    final notifier = ref.read(playerEditNotifierProvider(arg).notifier);
    final state = ref.watch(playerEditNotifierProvider(arg));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          RowTextField(
            label: "jméno",
            textFieldText: "Přezdívka:",
            value: state.name,
            onChanged: notifier.setName,
            error: state.errors["name"],
          ),
          const SizedBox(height: 10),
          RowCustomDropdown(
              text: 'Jméno hráče',
              hint: 'Vyber hráče',
              state: state,
              notifier: notifier),
          const SizedBox(height: 10),
          RowDatePicker(
            textFieldText: "Datum narození:",
            value: state.birthdate,
            onChanged: notifier.setBirthday,
            error: state.errors["fromDate"],
          ),
          const SizedBox(height: 10),
          RowSwitch(
            textFieldText: "fanoušek?",
            value: state.fan,
            onChanged: notifier.setFan,
          ),
          const SizedBox(height: 10),
          RowSwitch(
            textFieldText: "aktivní?",
            value: state.active,
            onChanged: notifier.setActive,
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          SimpleCrudButton(
            onPressed: () async => notifier.submitCrud(Crud.create,),
            text: "Ulož hráče",
          ),
        ],
      ),
    );
  }
}
