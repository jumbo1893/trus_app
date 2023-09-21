import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/rows/stream/row_calendar_stream.dart';
import '../../../common/widgets/rows/stream/row_switch_stream.dart';
import '../../../common/widgets/rows/stream/row_text_field_stream.dart';
import '../../../models/enum/crud.dart';
import '../controller/player_controller.dart';

class AddPlayerScreen extends ConsumerStatefulWidget {
  final VoidCallback onAddPlayerPressed;
  final bool isFocused;
  final VoidCallback backToMainMenu;
  const AddPlayerScreen({
    Key? key,
    required this.onAddPlayerPressed,
    required this.isFocused,
    required this.backToMainMenu,
  }) : super(key: key);

  @override
  ConsumerState<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends ConsumerState<AddPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      const double padding = 8.0;
      final size =
          MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
      return ColumnFutureBuilder(
        loadModelFuture: ref.watch(playerControllerProvider).newPlayer(),
        backToMainMenu: () => widget.backToMainMenu(),
        columns: [
          RowTextFieldStream(
            size: size,
            labelText: "jméno",
            textFieldText: "Jméno hráče:",
            padding: padding,
            textStream: ref.watch(playerControllerProvider).name(),
            errorTextStream:
                ref.watch(playerControllerProvider).nameErrorText(),
            onTextChanged: (name) =>
                {ref.watch(playerControllerProvider).setName(name)},
          ),
          const SizedBox(height: 10),
          RowCalendarStream(
            size: size,
            padding: padding,
            textFieldText: "Datum narození:",
            onDateChanged: (date) {
              ref.watch(playerControllerProvider).setDate(date);
            },
            dateStream: ref.watch(playerControllerProvider).date(),
            errorTextStream: null,
          ),
          const SizedBox(height: 10),
          RowSwitchStream(
            size: size,
            padding: padding,
            textFieldText: "fanoušek?",
            stream: ref.watch(playerControllerProvider).fan(),
            onChecked: (fan) {
              ref.watch(playerControllerProvider).setFan(fan);
            },
          ),
          const SizedBox(height: 10),
          RowSwitchStream(
            size: size,
            padding: padding,
            textFieldText: "aktivní?",
            stream: ref.watch(playerControllerProvider).active(),
            onChecked: (active) {
              ref.watch(playerControllerProvider).setActive(active);
            },
          ),
          const SizedBox(height: 10),
          CrudButton(
            text: "Potvrď",
            context: context,
            crud: Crud.create,
            crudOperations: ref.read(playerControllerProvider),
            onOperationComplete: (id) {
              widget.onAddPlayerPressed();
            },
            backToMainMenu: () => widget.backToMainMenu(),
          )
        ],
        loadingScreen: null,
      );
    } else {
      return Container();
    }
  }
}
