import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/rows/stream/row_calendar_stream.dart';
import '../../../common/widgets/rows/stream/row_player_list_stream.dart';
import '../../../common/widgets/rows/stream/row_season_stream.dart';
import '../../../common/widgets/rows/stream/row_switch_stream.dart';
import '../../../common/widgets/rows/stream/row_text_field_stream.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../../models/enum/crud.dart';

class EditMatchScreen extends ConsumerStatefulWidget {
  final VoidCallback onButtonConfirmPressed;
  final MatchApiModel? matchModel;
  final Function(int id) setMatchId;
  final VoidCallback onChangePlayerGoalsPressed;
  final bool isFocused;
  const EditMatchScreen({
    Key? key,
    required this.onButtonConfirmPressed,
    required this.matchModel,
    required this.setMatchId,
    required this.onChangePlayerGoalsPressed,
    required this.isFocused,
  }) : super(key: key);

  @override
  ConsumerState<EditMatchScreen> createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends ConsumerState<EditMatchScreen> {

  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      const double padding = 8.0;
      final size = MediaQueryData
          .fromWindow(WidgetsBinding.instance.window)
          .size;
      return FutureBuilder<void>(
          future: ref.watch(matchControllerProvider).setupEditMatch(
              widget.matchModel!.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            else if (snapshot.hasError) {
              Future.delayed(Duration.zero, () => showErrorDialog(
                  snapshot.error!.toString(), widget.onButtonConfirmPressed,
                  context));
              return const Loader();
            }
            return ColumnFutureBuilder(
              loadModelFuture: ref.watch(matchControllerProvider).editMatch(),
              columns: [
                RowTextFieldStream(
                  size: size,
                  labelText: "jméno",
                  textFieldText: "Jméno soupeře:",
                  padding: padding,
                  textStream: ref.watch(matchControllerProvider).name(),
                  errorTextStream: ref.watch(matchControllerProvider)
                      .nameErrorText(),
                  onTextChanged: (name) =>
                  {ref.watch(matchControllerProvider).setName(name)},
                ),
                const SizedBox(height: 10),
                RowCalendarStream(
                  size: size,
                  padding: padding,
                  textFieldText: "Datum zápasu:",
                  onDateChanged: (date) {
                    ref.watch(matchControllerProvider).setDate(date);
                  },
                  dateStream: ref.watch(matchControllerProvider).date(),
                ),
                const SizedBox(height: 10),
                RowSwitchStream(
                  size: size,
                  padding: padding,
                  textFieldText: "domácí zápas?",
                  stream: ref.watch(matchControllerProvider).home(),
                  onChecked: (fan) {
                    ref.watch(matchControllerProvider).setHome(fan);
                  },
                ),
                const SizedBox(height: 10),
                RowSeasonStream(
                  size: size,
                  padding: padding,
                  seasonList: ref.watch(matchControllerProvider).seasonList(),
                  pickedSeason: ref.watch(matchControllerProvider).season(),
                  onSeasonChanged: (season) {
                    ref.watch(matchControllerProvider).setSeason(season);
                  },
                  initData: () =>
                      ref.watch(matchControllerProvider).initSeason(),
                ),
                const SizedBox(height: 10),
                RowPlayerListStream(
                  size: size,
                  padding: padding,
                  playerList: ref.watch(matchControllerProvider).playerList(),
                  checkedPlayerList: ref.watch(matchControllerProvider)
                      .checkedPlayers(),
                  textFieldText: "Vyber hráče",
                  errorTextStream: ref.watch(matchControllerProvider)
                      .playerErrorText(),
                  initData: () =>
                      ref.watch(matchControllerProvider).initCheckedPlayers(),
                  onPlayersChanged: (players) {
                    ref.watch(matchControllerProvider).setPlayers(players);
                  },
                ),
                const SizedBox(height: 10),
                RowPlayerListStream(
                  size: size,
                  padding: padding,
                  playerList: ref.watch(matchControllerProvider).fanList(),
                  checkedPlayerList: ref.watch(matchControllerProvider)
                      .checkedFans(),
                  textFieldText: "Vyber fanoušky",
                  initData: () =>
                      ref.watch(matchControllerProvider).initCheckedFans(),
                  onPlayersChanged: (players) {
                    ref.watch(matchControllerProvider).setFans(players);
                  },
                ),
                const SizedBox(height: 10),
                CrudButton(
                  text: "Potvrď změny",
                  context: context,
                  crud: Crud.update,
                  crudOperations: ref.read(matchControllerProvider),
                  onOperationComplete: (id) {
                    widget.onButtonConfirmPressed();
                  },
                  id: widget.matchModel!.id!,
                ),
                CrudButton(
                  text: "Smaž zápas",
                  context: context,
                  crud: Crud.delete,
                  crudOperations: ref.read(matchControllerProvider),
                  onOperationComplete: (id) {
                    widget.onButtonConfirmPressed();
                  },
                  id: widget.matchModel!.id!,
                  modelToString: widget.matchModel!,
                ),
                CrudButton(
                  text: "Uprav statistiky",
                  context: context,
                  crud: Crud.update,
                  id: widget.matchModel!.id!,
                  crudOperations: ref.read(matchControllerProvider),
                  onOperationComplete: (id) {
                    widget.setMatchId(id);
                    widget.onChangePlayerGoalsPressed();
                  },
                ),
              ],
            );
          }
      );
    }
    else {
      return Container();
    }
  }
}
