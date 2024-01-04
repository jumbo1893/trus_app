import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';

import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/rows/stream/row_calendar_stream.dart';
import '../../../common/widgets/rows/stream/row_switch_stream.dart';
import '../../../common/widgets/rows/stream/row_text_field_stream.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/api/player_api_model.dart';
import '../../../models/enum/crud.dart';
import '../../main/screen_controller.dart';
import '../controller/player_controller.dart';

class EditPlayerScreen extends CustomConsumerStatefulWidget {

  static const String id = "edit-player-screen";
  const EditPlayerScreen(
    {
    Key? key,
  }) : super(key: key, title: "Upravit hráče", name: id);

  @override
  ConsumerState<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends ConsumerState<EditPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    PlayerApiModel player = ref.watch(screenControllerProvider).playerModel;
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(EditPlayerScreen.id)) {
      const double padding = 8.0;
      final size =
          MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
      return ColumnFutureBuilder(
        loadModelFuture:
            ref.watch(playerControllerProvider).player(player),
        columns: [
          RowTextFieldStream(
            key: const ValueKey('player_name_field'),
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
            key: const ValueKey('player_date_field'),
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
            key: const ValueKey('player_fan_field'),
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
            key: const ValueKey('player_active_field'),
            size: size,
            padding: padding,
            textFieldText: "aktivní?",
            stream: ref.watch(playerControllerProvider).active(),
            onChecked: (active) {
              ref.watch(playerControllerProvider).setActive(active);
            },
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          CrudButton(
            key: const ValueKey('confirm_button'),
            text: "Potvrď změny",
            context: context,
            crud: Crud.update,
            crudOperations: ref.read(playerControllerProvider),
            onOperationComplete: (id) {
              ref
                  .read(screenControllerProvider)
                  .changeFragment(PlayerScreen.id);
            },
            id: player.id!,
          ),
          CrudButton(
            key: const ValueKey('delete_button'),
            text: "Smaž hráče",
            context: context,
            crud: Crud.delete,
            crudOperations: ref.read(playerControllerProvider),
            onOperationComplete: (id) {
              ref
                  .read(screenControllerProvider)
                  .changeFragment(PlayerScreen.id);
            },
            id: player.id!,
            modelToString: player,
          ),
        ],
        loadingScreen: null,
      );
    } else {
      return Container();
    }
  }
}
