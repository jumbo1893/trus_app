import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/dropdown/match_dropdown.dart';
import 'package:trus_app/models/api/player_api_model.dart';
import 'package:trus_app/models/match_model.dart';

import '../../../../common/repository/exception/loading_exception.dart';
import '../../../../common/widgets/builder/error_future_builder.dart';
import '../../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../../common/widgets/button/floating_finematch_button.dart';
import '../../../../common/widgets/dropdown/match_dropdown2.dart';
import '../../../../common/widgets/dropdown/season_api_dropdown.dart';
import '../../../../common/widgets/listview/custom_checkbox_list_tile.dart';
import '../../../../common/widgets/listview/fine_match_listview.dart';
import '../../../../models/api/match/match_api_model.dart';
import '../../../../models/player_model.dart';
import '../../../player/controller/player_controller.dart';
import '../controller/fine_match_controller.dart';

class FineMatchScreen extends ConsumerStatefulWidget {
  final Function(PlayerApiModel player) setPlayer;
  final Function(MatchApiModel match) setMatch;
  final Function(List<int> playerIdListToChangeFines)
      playerIdListToChangeFines;
  final MatchApiModel mainMatch;
  final bool isFocused;
  const FineMatchScreen({
    Key? key,
    required this.setPlayer,
    required this.playerIdListToChangeFines,
    required this.setMatch,
    required this.mainMatch,
    required this.isFocused,
  }) : super(key: key);

  @override
  ConsumerState<FineMatchScreen> createState() => _FineMatchScreenState();
}

class _FineMatchScreenState extends ConsumerState<FineMatchScreen> {

  void onIconClick(int index) {
    if(index == 0) {
      List<int> players = ref
          .read(fineMatchControllerProvider)
          .getCheckedPlayerIdList();
      if (players.isEmpty) {
        showSnackBarWithPostFrame(
            context: context,
            content: "Musí být označen aspoň jeden hráč!");
      } else {
        widget.setMatch(ref.read(fineMatchControllerProvider).pickedMatch!);
        widget.playerIdListToChangeFines(players);
      }
    }
    else {
      ref.read(fineMatchControllerProvider).onIconClick(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
      return ErrorFutureBuilder<void>(
        future: ref
            .read(fineMatchControllerProvider)
            .initScreen(widget.mainMatch.id),
        context: context,
        onDialogCancel: () => {},
        widget: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: size.width),
                  child: MatchDropdown2(
                    onMatchSelected: (match) => ref
                        .watch(fineMatchControllerProvider)
                        .setMatch(match),
                    matchesStream: ref
                        .watch(fineMatchControllerProvider)
                        .matches(),
                    initMatchListStream: () => ref.read(fineMatchControllerProvider).initMatchesStream(),
                    matchReader: ref.read(fineMatchControllerProvider),
                  )),
            ),
            body: Padding(
              padding: const EdgeInsets.all(padding),
              child: Column(children: [
                Row(
                  children: [
                    SizedBox(
                        width: size.width / 2 - padding,
                        child: SeasonApiDropdown(
                          onSeasonSelected: (season) => ref
                              .watch(fineMatchControllerProvider)
                              .setSeason(season),
                          seasonList:
                              ref.watch(fineMatchControllerProvider).getSeasons(),
                          pickedSeason:
                              ref.watch(fineMatchControllerProvider).pickedSeason(),
                          initData: () => ref
                              .watch(fineMatchControllerProvider)
                              .setInitSeason(),
                        )),
                  ],
                ),
                FineMatchListview(
                  initPlayerStream: () => ref.read(fineMatchControllerProvider).initPlayersStream(),
                  playersStream: ref.watch(fineMatchControllerProvider).players(),
                  multiselectStream: ref.watch(fineMatchControllerProvider).multiselect(),
                  onPlayerSelected: (player) => {widget.setPlayer(player), widget.setMatch(ref.read(fineMatchControllerProvider).pickedMatch!)},
                  onPlayerChecked: (player) => ref.read(fineMatchControllerProvider).setCheckedPlayer(player),
                  checkedPlayersStream: ref.watch(fineMatchControllerProvider).checkedPlayers(),
                )
              ]),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
            floatingActionButton: FloatingFineMatchButton(
              onMultiselectClicked: (multi) => ref.read(fineMatchControllerProvider).switchScreen(multi),
              onIconClicked: (index) => onIconClick(index),

            )
          )
      );
    } else {
      return Container();
    }
  }
}
