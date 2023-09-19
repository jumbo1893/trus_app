import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/dropdown/season_api_dropdown.dart';

import '../../../../colors.dart';
import '../../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../../common/widgets/builder/statistics_error_future_builder.dart';
import '../../../../common/widgets/button/statistics_buttons.dart';
import '../../../../common/widgets/custom_text.dart';
import '../../controller/goal_stats_controller.dart';

class MatchGoalStatsScreen extends ConsumerStatefulWidget {
  final bool isFocused;
  final VoidCallback backToMainMenu;
  const MatchGoalStatsScreen({
    required this.isFocused,
    required this.backToMainMenu,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MatchGoalStatsScreen> createState() =>
      _MatchGoalStatsScreenState();
}

class _MatchGoalStatsScreenState extends ConsumerState<MatchGoalStatsScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
      return StreamBuilder<bool>(
          stream: ref.watch(goalStatsControllerProvider).screenDetailStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data == false) {
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                                width: size.width / 2.5 - padding,
                                child: SeasonApiDropdown(
                                  onSeasonSelected: (season) => ref
                                      .watch(goalStatsControllerProvider)
                                      .setPickedSeason(season),
                                  seasonList: ref
                                      .watch(goalStatsControllerProvider)
                                      .getSeasons(),
                                  pickedSeason: ref
                                      .watch(goalStatsControllerProvider)
                                      .pickedSeason(),
                                  initData: () => ref
                                      .watch(goalStatsControllerProvider)
                                      .setCurrentSeason(),
                                )),
                            StatisticsButtons(
                              onSearchButtonClicked: (text) => ref
                                  .watch(goalStatsControllerProvider)
                                  .getFilteredGoals(text),
                              onOrderButtonClicked: () => ref
                                  .read(goalStatsControllerProvider)
                                  .onRevertTap(),
                              padding: padding,
                              size: size,
                              backToMainMenu: () => widget.backToMainMenu(),
                            )
                          ],
                        ),
                        StatisticsErrorFutureBuilder(
                          future: ref
                              .watch(goalStatsControllerProvider)
                              .getModels(true),
                          onPressed: (model) {
                            ref
                                .watch(goalStatsControllerProvider)
                                .setDetail(model);
                          },
                          context: context,
                          backToMainMenu: () => widget.backToMainMenu(),
                          rebuildStream: ref
                              .watch(goalStatsControllerProvider)
                              .goalListStream(),
                          overallStream: ref
                              .watch(goalStatsControllerProvider)
                              .overAllStatsStream(),
                          overAllStatsInit: () => ref
                              .read(goalStatsControllerProvider)
                              .initOverallStats(),
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                                child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                ref
                                    .read(goalStatsControllerProvider)
                                    .changeScreen(false);
                              },
                              color: orangeColor,
                            )),
                            SizedBox(
                                child: TextButton(
                                    child: const Text(
                                      "Zpět",
                                      style: TextStyle(
                                          color: blackColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    onPressed: () => ref
                                        .read(goalStatsControllerProvider)
                                        .changeScreen(false)))
                          ],
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: CustomText(
                              text:
                                  "Detail kanadských bodů pro ${ref.read(goalStatsControllerProvider).detailString!}"),
                        ),
                        ModelsErrorFutureBuilder(
                          future: ref
                              .watch(goalStatsControllerProvider)
                              .getDetailedModels(),
                          rebuildStream: ref
                              .watch(goalStatsControllerProvider)
                              .detailedGoalListStream(),
                          onPressed: (object) {},
                          backToMainMenu: () => widget.backToMainMenu(),
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          });
    } else {
      return Container();
    }
  }
}
