import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/rows/stream/row_calendar_stream.dart';
import '../../../common/widgets/rows/stream/row_player_list_stream.dart';
import '../../../common/widgets/rows/stream/row_season_stream.dart';
import '../../../common/widgets/rows/stream/row_switch_pkfl_stream.dart';
import '../../../common/widgets/rows/stream/row_switch_stream.dart';
import '../../../common/widgets/rows/stream/row_text_field_stream.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';

class EditMatchScreen extends CustomConsumerStatefulWidget {
  final bool isFocused;
  static const String id = "edit-match-screen";

  const EditMatchScreen({
    Key? key,
    required this.isFocused,
  }) : super(key: key, title: "Upravit zápas", name: id);

  @override
  ConsumerState<EditMatchScreen> createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends ConsumerState<EditMatchScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      const double padding = 8.0;
      final size =
          MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
      return ColumnFutureBuilder(
        loadModelFuture: ref.watch(matchControllerProvider).editMatch(),
        columns: [
          RowTextFieldStream(
            key: const ValueKey('match_name_field'),
            size: size,
            labelText: "jméno",
            textFieldText: "Jméno soupeře:",
            padding: padding,
            textStream: ref.watch(matchControllerProvider).name(),
            errorTextStream: ref.watch(matchControllerProvider).nameErrorText(),
            onTextChanged: (name) =>
                {ref.watch(matchControllerProvider).setName(name)},
          ),
          const SizedBox(height: 10),
          ref.read(matchControllerProvider).pkflMatch != null
              ? RowSwitchPkflStream(
                  key: const ValueKey('set_pkfl_field'),
                  size: size,
                  padding: padding,
                  textFieldText: "Propojit s PKFL zápasem?",
                  stream: ref.watch(matchControllerProvider).connectWithPkfl(),
                  onChecked: (fan) {
                    ref
                        .watch(matchControllerProvider)
                        .setConnectWithPkflMatch(fan);
                  },
                  pkflMatch: ref.read(matchControllerProvider).pkflMatch!,
                )
              : Container(),
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
            initData: () => ref.watch(matchControllerProvider).initSeason(),
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
            checkedPlayerList: ref.watch(matchControllerProvider).checkedFans(),
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
            text: "Potvrď změny",
            context: context,
            crud: Crud.update,
            crudOperations: ref.read(matchControllerProvider),
            onOperationComplete: (id) {
              ref.read(screenControllerProvider).setChangedMatch(true);
              ref.read(screenControllerProvider).changeFragment(HomeScreen.id);
            },
            id: ref.read(matchControllerProvider).returnEditMatch().id!,
          ),
          CrudButton(
            key: const ValueKey('delete_button'),
            text: "Smaž zápas",
            context: context,
            crud: Crud.delete,
            crudOperations: ref.read(matchControllerProvider),
            onOperationComplete: (id) {
              ref.read(screenControllerProvider).setChangedMatch(true);
              ref.read(screenControllerProvider).changeFragment(HomeScreen.id);
            },
            id: ref.read(matchControllerProvider).returnEditMatch().id!,
            modelToString: ref.read(matchControllerProvider).matchSetup.match!,
          ),
          CrudButton(
            key: const ValueKey('confirm_and_goal_button'),
            text: "Uprav statistiky",
            context: context,
            crud: Crud.update,
            id: ref.read(matchControllerProvider).returnEditMatch().id!,
            crudOperations: ref.read(matchControllerProvider),
            onOperationComplete: (id) {
              hideSnackBar(context);
              ref.read(screenControllerProvider).setMatchId(id);
              ref.read(screenControllerProvider).changeFragment(GoalScreen.id);
            },
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
