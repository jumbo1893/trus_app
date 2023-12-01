import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../../models/api/pkfl/pkfl_match_api_model.dart';
import '../../../models/enum/crud.dart';

class AddMatchScreen extends ConsumerStatefulWidget {
  final VoidCallback onAddMatchPressed;
  final Function(int id) setMatchId;
  final VoidCallback onChangePlayerGoalsPressed;
  final VoidCallback backToMainMenu;
  final bool isFocused;
  PkflMatchApiModel? pkflMatch;
  AddMatchScreen({
    Key? key,
    required this.onAddMatchPressed,
    required this.isFocused,
    required this.setMatchId,
    required this.onChangePlayerGoalsPressed,
    required this.backToMainMenu,
    required this.pkflMatch,
  }) : super(key: key);

  @override
  ConsumerState<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends ConsumerState<AddMatchScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      const double padding = 8.0;
      final size =
          MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
      return FutureBuilder<void>(
          future: ref.watch(matchControllerProvider).setupNewMatch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            } else if (snapshot.hasError) {
              Future.delayed(
                  Duration.zero,
                  () => showErrorDialog(snapshot.error!.toString(),
                      widget.onAddMatchPressed, context));
              return const Loader();
            }
            return ColumnFutureBuilder(
              loadModelFuture: widget.pkflMatch == null ? ref.watch(matchControllerProvider).newMatch() : ref.watch(matchControllerProvider).newMatchByPkflMatch(widget.pkflMatch!),
              loadingScreen: null,
              backToMainMenu: () => widget.backToMainMenu(),
              columns: [
                RowTextFieldStream(
                  key: const ValueKey('match_name_field'),
                  size: size,
                  labelText: "jméno",
                  textFieldText: "Jméno soupeře:",
                  padding: padding,
                  textStream: ref.watch(matchControllerProvider).name(),
                  errorTextStream:
                      ref.watch(matchControllerProvider).nameErrorText(),
                  onTextChanged: (name) =>
                      {ref.watch(matchControllerProvider).setName(name)},
                ),
                const SizedBox(height: 10),
                RowCalendarStream(
                  key: const ValueKey('match_date_field'),
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
                  key: const ValueKey('match_home_field'),
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
                  key: const ValueKey('match_season_field'),
                  size: size,
                  padding: padding,
                  seasonList: ref.watch(matchControllerProvider).seasonList(),
                  pickedSeason: ref.watch(matchControllerProvider).season(),
                  onSeasonChanged: (season) {
                    ref.watch(matchControllerProvider).setSeason(season);
                  },
                ),
                const SizedBox(height: 10),
                RowPlayerListStream(
                  key: const ValueKey('match_player_field'),
                  size: size,
                  padding: padding,
                  playerList: ref.watch(matchControllerProvider).playerList(),
                  checkedPlayerList:
                      ref.watch(matchControllerProvider).checkedPlayers(),
                  textFieldText: "Vyber hráče",
                  errorTextStream:
                      ref.watch(matchControllerProvider).playerErrorText(),
                  initData: () =>
                      ref.watch(matchControllerProvider).initCheckedPlayers(),
                  onPlayersChanged: (players) {
                    ref.watch(matchControllerProvider).setPlayers(players);
                  },
                ),
                const SizedBox(height: 10),
                RowPlayerListStream(
                  key: const ValueKey('match_fan_field'),
                  size: size,
                  padding: padding,
                  playerList: ref.watch(matchControllerProvider).fanList(),
                  checkedPlayerList:
                      ref.watch(matchControllerProvider).checkedFans(),
                  textFieldText: "Vyber fanoušky",
                  initData: () =>
                      ref.watch(matchControllerProvider).initCheckedFans(),
                  onPlayersChanged: (players) {
                    ref.watch(matchControllerProvider).setFans(players);
                  },
                ),
                const SizedBox(height: 10),
                CrudButton(
                  key: const ValueKey('confirm_button'),
                  text: "Potvrď",
                  context: context,
                  crud: Crud.create,
                  crudOperations: ref.read(matchControllerProvider),
                  onOperationComplete: (id) {
                    widget.setMatchId(id);
                    widget.onAddMatchPressed();
                  },
                  backToMainMenu: () => widget.backToMainMenu(),
                ),
                CrudButton(
                  key: const ValueKey('confirm_and_goal_button'),
                  text: "Potvrď a přejdi ke gólům",
                  context: context,
                  crud: Crud.create,
                  crudOperations: ref.read(matchControllerProvider),
                  onOperationComplete: (id) {
                    widget.setMatchId(id);
                    widget.onChangePlayerGoalsPressed();
                  },
                  backToMainMenu: () => widget.backToMainMenu(),
                ),
              ],
            );
          });
    } else {
      return Container();
    }
  }
}
