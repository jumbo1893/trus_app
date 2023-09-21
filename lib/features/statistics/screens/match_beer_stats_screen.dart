import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/dropdown/season_api_dropdown.dart';

import '../../../colors.dart';
import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/builder/statistics_error_future_builder.dart';
import '../../../common/widgets/button/statistics_buttons.dart';
import '../../../common/widgets/custom_text.dart';
import '../controller/beer_stats_controller.dart';

class MatchBeerStatsScreen extends ConsumerStatefulWidget {
  final bool isFocused;
  final VoidCallback backToMainMenu;
  const MatchBeerStatsScreen({
    required this.isFocused,
    required this.backToMainMenu,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MatchBeerStatsScreen> createState() =>
      _MatchBeerStatsScreenState();
}

class _MatchBeerStatsScreenState extends ConsumerState<MatchBeerStatsScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
      return StreamBuilder<bool>(
          stream: ref.watch(beerStatsControllerProvider).screenDetailStream(),
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
                                      .watch(beerStatsControllerProvider)
                                      .setPickedSeason(season),
                                  seasonList: ref
                                      .watch(beerStatsControllerProvider)
                                      .getSeasons(),
                                  pickedSeason: ref
                                      .watch(beerStatsControllerProvider)
                                      .pickedSeason(),
                                  initData: () => ref
                                      .watch(beerStatsControllerProvider)
                                      .setCurrentSeason(),
                                )),
                            StatisticsButtons(
                              onSearchButtonClicked: (text) => ref
                                  .watch(beerStatsControllerProvider)
                                  .getFilteredBeers(text),
                              onOrderButtonClicked: () => ref
                                  .read(beerStatsControllerProvider)
                                  .onRevertTap(),
                              padding: padding,
                              size: size,
                              backToMainMenu: () => widget.backToMainMenu(),
                            )
                          ],
                        ),
                        StatisticsErrorFutureBuilder(
                          future: ref
                              .watch(beerStatsControllerProvider)
                              .getModels(true),
                          onPressed: (model) {
                            ref
                                .watch(beerStatsControllerProvider)
                                .setDetail(model);
                          },
                          context: context,
                          backToMainMenu: () => widget.backToMainMenu(),
                          rebuildStream: ref
                              .watch(beerStatsControllerProvider)
                              .beerListStream(),
                          overallStream: ref
                              .watch(beerStatsControllerProvider)
                              .overAllStatsStream(),
                          overAllStatsInit: () => ref
                              .read(beerStatsControllerProvider)
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
                                    .read(beerStatsControllerProvider)
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
                                        .read(beerStatsControllerProvider)
                                        .changeScreen(false)))
                          ],
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: CustomText(
                              text:
                                  "Detail pitiva pro ${ref.read(beerStatsControllerProvider).detailString!}"),
                        ),
                        ModelsErrorFutureBuilder(
                          future: ref
                              .watch(beerStatsControllerProvider)
                              .getDetailedModels(),
                          rebuildStream: ref
                              .watch(beerStatsControllerProvider)
                              .detailedBeerListStream(),
                          onPressed: (object) {},
                          backToMainMenu: () => widget.backToMainMenu(),
                          context: context,
                          scrollable: false,
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
