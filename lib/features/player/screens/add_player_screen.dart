import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/utils.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/rows/stream/row_calendar_stream.dart';
import '../../../common/widgets/rows/stream/row_switch_stream.dart';
import '../../../common/widgets/rows/stream/row_text_field_stream.dart';
import '../../../models/api/player_api_model.dart';
import '../../../models/enum/crud.dart';
import '../../notification/controller/notification_controller.dart';
import '../controller/player_controller.dart';

class AddPlayerScreen extends ConsumerStatefulWidget {
  final VoidCallback onAddPlayerPressed;
  final bool isFocused;
  const AddPlayerScreen({
    Key? key,
    required this.onAddPlayerPressed,
    required this.isFocused,
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
            text: "Přidej hráče",
            context: context,
            crud: Crud.create,
            crudOperations: ref.read(playerControllerProvider),
            onOperationComplete: (id) {
              widget.onAddPlayerPressed();
            },
          )
        ],
        loadingScreen: null,
      );
    } else {
      return Container();
    }
  }
}
