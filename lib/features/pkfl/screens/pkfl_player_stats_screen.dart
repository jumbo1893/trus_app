import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/dropdown/pkfl_player_api_dropdown.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../main/screen_controller.dart';
import '../controller/pkfl_player_stats_controller.dart';

class PkflPlayerStatsScreen extends CustomConsumerWidget {
  static const String id = "pkfl-player-stats-screen";

  const PkflPlayerStatsScreen({
    Key? key,
  }) : super(key: key, title: "Detail zápasu", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(PkflPlayerStatsScreen.id)) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
      return Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(padding),
        child: SingleChildScrollView(
          key: const ValueKey('pkfl_player_stats_screen'),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                      width: size.width / 2 - padding,
                      child: PkflPlayerApiDropdown(
                        key: const ValueKey('season_dropdown'),
                        onPlayerSelected: (player) => ref
                            .watch(pkflPlayerStatsControllerProvider)
                            .setPickedPlayer(player),
                        playerList: ref
                            .watch(pkflPlayerStatsControllerProvider)
                            .getPlayers(),
                        pickedPlayer: ref
                            .watch(pkflPlayerStatsControllerProvider)
                            .pickedPlayer(),
                        initData: () => ref
                            .watch(pkflPlayerStatsControllerProvider)
                            .setCurrentPlayer(),
                      )),
                ],
              ),
              ModelsErrorFutureBuilder(
                key: const ValueKey('pkfl_player_stats_list'),
                future:
                    ref.watch(pkflPlayerStatsControllerProvider).getModels(),
                rebuildStream:
                    ref.watch(pkflPlayerStatsControllerProvider).streamText(),
                onPressed: (match) => {},
                context: context,
                scrollable: false,
              ),
            ],
          ),
        ),
      ));
    } else {
      return Container();
    }
  }
}
