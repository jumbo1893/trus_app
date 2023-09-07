import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/custom_text.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/models/helper/beer_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../../common/widgets/builder/statistics_error_future_builder.dart';
import '../../../../common/widgets/button/statistics_buttons.dart';
import '../../../../common/widgets/dropdown/season_api_dropdown.dart';
import '../../controller/goal_stats_controller.dart';

class PlayerGoalStatsScreen extends ConsumerStatefulWidget {
  final bool isFocused;
  const PlayerGoalStatsScreen({
    required this.isFocused,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PlayerGoalStatsScreen> createState() =>
      _PlayerGoalStatsScreenState();
}

class _PlayerGoalStatsScreenState extends ConsumerState<PlayerGoalStatsScreen> {
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
                            )
                          ],
                        ),
                        StatisticsErrorFutureBuilder(
                          future: ref
                              .watch(goalStatsControllerProvider)
                              .getModels(false),
                          onPressed: (model) {
                            ref
                                .watch(goalStatsControllerProvider)
                                .setDetail(model);
                          },
                          context: context,
                          onDialogCancel: () {},
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
                          onDialogCancel: () {},
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
