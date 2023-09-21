import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/dropdown/season_api_dropdown.dart';
import '../../../models/api/match/match_api_model.dart';
import '../controller/match_screen_controller.dart';

class MatchScreen extends ConsumerWidget {
  final VoidCallback onPlusButtonPressed;
  final VoidCallback backToMainMenu;
  final Function(MatchApiModel matchModel) setMatch;
  final bool isFocused;
  const MatchScreen({
    Key? key,
    required this.onPlusButtonPressed,
    required this.setMatch,
    required this.backToMainMenu,
    required this.isFocused,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isFocused) {
      final size = MediaQuery
          .of(context)
          .size;
      const double padding = 8.0;
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(padding),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                          width: size.width / 2 - padding,
                          child: SeasonApiDropdown(
                            onSeasonSelected: (season) =>
                                ref.watch(matchScreenControllerProvider)
                                    .setPickedSeason(season),
                            seasonList: ref.watch(matchScreenControllerProvider)
                                .getSeasons(),
                            pickedSeason: ref.watch(matchScreenControllerProvider)
                                .pickedSeason(),
                            initData: () =>
                                ref.watch(matchScreenControllerProvider)
                                    .setCurrentSeason(),
                          )),
                    ],
                  ),
                  ModelsErrorFutureBuilder(
                    future: ref.watch(matchScreenControllerProvider).getModels(),
                    rebuildStream: ref.watch(matchScreenControllerProvider)
                        .streamMatches(),
                    onPressed: (match) => {setMatch(match as MatchApiModel)},
                    backToMainMenu: () => backToMainMenu(),
                    context: context,
                    scrollable: false,
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: onPlusButtonPressed,
            elevation: 4.0,
            child: const Icon(Icons.add),
          ));
    }
    else {
      return Container();
    }
  }
}
