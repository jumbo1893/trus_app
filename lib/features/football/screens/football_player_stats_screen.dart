import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/football/football_player_api_model.dart';

import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/dropdown/custom_dropdown.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../main/screen_controller.dart';
import '../controller/football_player_stats_controller.dart';

class FootballPlayerStatsScreen extends CustomConsumerWidget {
  static const String id = "pkfl-player-stats-screen";

  const FootballPlayerStatsScreen({
    Key? key,
  }) : super(key: key, title: "Hráčské statistiky", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(FootballPlayerStatsScreen.id)) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
      return Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(padding),
        child: SingleChildScrollView(
          key: const ValueKey('football_player_stats_screen'),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                      width: size.width / 2 - padding,
                      child: CustomDropdown(
                        key: const ValueKey('player_dropdown'),
                        onItemSelected: (player) => ref
                            .watch(footballPlayerStatsControllerProvider)
                            .setPickedPlayer(player as FootballPlayerApiModel),
                        dropdownList: ref
                            .watch(footballPlayerStatsControllerProvider)
                            .getPlayers(),
                        pickedItem: ref
                            .watch(footballPlayerStatsControllerProvider)
                            .pickedPlayer(),
                        initData: () => ref
                            .watch(footballPlayerStatsControllerProvider)
                            .setCurrentPlayer(),
                        hint: 'Vyber hráče',
                      )),
                ],
              ),
              ModelsErrorFutureBuilder(
                key: const ValueKey('football_player_stats_list'),
                future:
                    ref.watch(footballPlayerStatsControllerProvider).getModels(),
                rebuildStream:
                    ref.watch(footballPlayerStatsControllerProvider).streamText(),
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
