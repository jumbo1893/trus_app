import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/dropdown/season_api_dropdown.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../colors.dart';
import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/builder/statistics_error_future_builder.dart';
import '../../../common/widgets/button/statistics_buttons.dart';
import '../../../common/widgets/custom_text.dart';
import '../controller/beer_stats_controller.dart';
import '../controller/fine_stats_controller.dart';
import '../fine_screen_enum.dart';

class PlayerFineStatsScreen extends ConsumerStatefulWidget {
  final bool isFocused;
  const PlayerFineStatsScreen({
    required this.isFocused,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PlayerFineStatsScreen> createState() =>
      _PlayerFineStatsScreenState();
}

class _PlayerFineStatsScreenState extends ConsumerState<PlayerFineStatsScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
      return StreamBuilder<FineScreenEnum>(
          stream: ref.watch(fineStatsControllerProvider).screenDetailStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data == FineScreenEnum.firstScreen) {
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
                                      .watch(fineStatsControllerProvider)
                                      .setPickedSeason(season),
                                  seasonList: ref
                                      .watch(fineStatsControllerProvider)
                                      .getSeasons(),
                                  pickedSeason: ref
                                      .watch(fineStatsControllerProvider)
                                      .pickedSeason(),
                                  initData: () => ref
                                      .watch(fineStatsControllerProvider)
                                      .setCurrentSeason(),
                                )),
                            StatisticsButtons(
                              onSearchButtonClicked: (text) => ref
                                  .watch(fineStatsControllerProvider)
                                  .getFilteredFines(text),
                              onOrderButtonClicked: () => ref
                                  .read(fineStatsControllerProvider)
                                  .onRevertTap(),
                              padding: padding,
                              size: size,
                            )
                          ],
                        ),
                        StatisticsErrorFutureBuilder(
                          future: ref
                              .watch(fineStatsControllerProvider)
                              .getModels(false),
                          onPressed: (model) {
                            ref
                                .watch(fineStatsControllerProvider)
                                .setDetail(model);
                          },
                          context: context,
                          onDialogCancel: () {},
                          rebuildStream: ref
                              .watch(fineStatsControllerProvider)
                              .fineListStream(),
                          overallStream: ref
                              .watch(fineStatsControllerProvider)
                              .overAllStatsStream(),
                          overAllStatsInit: () => ref
                              .read(fineStatsControllerProvider)
                              .initOverallStats(),
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else if(snapshot.data! == FineScreenEnum.detailScreen) {
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
                                        .read(fineStatsControllerProvider)
                                        .changeScreen(FineScreenEnum.firstScreen);
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
                                        .read(fineStatsControllerProvider)
                                        .changeScreen(FineScreenEnum.firstScreen)))
                          ],
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: CustomText(
                              text:
                              "Detail pokut pro ${ref.read(fineStatsControllerProvider).detailString!}"),
                        ),
                        ModelsErrorFutureBuilder(
                          future: ref
                              .watch(fineStatsControllerProvider)
                              .getDetailedModels(),
                          rebuildStream: ref
                              .watch(fineStatsControllerProvider)
                              .detailedFineListStream(),
                          onPressed: (model) {ref
                              .watch(fineStatsControllerProvider)
                              .setFineDetail(model);},
                          onDialogCancel: () {},
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            else {
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
                                        .read(fineStatsControllerProvider)
                                        .changeScreen(FineScreenEnum.detailScreen);
                                  },
                                  color: orangeColor,
                                )),
                            SizedBox(
                                child: TextButton(
                                    child: const Text(
                                      "Zpět na detail",
                                      style: TextStyle(
                                          color: blackColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    onPressed: () => ref
                                        .read(fineStatsControllerProvider)
                                        .changeScreen(FineScreenEnum.detailScreen))),
                            SizedBox(
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () {
                                    ref
                                        .read(fineStatsControllerProvider)
                                        .changeScreen(FineScreenEnum.firstScreen);
                                  },
                                  color: orangeColor,
                                )),
                            SizedBox(
                                child: TextButton(
                                    child: const Text(
                                      "Zpět na seznam",
                                      style: TextStyle(
                                          color: blackColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    onPressed: () => ref
                                        .read(fineStatsControllerProvider)
                                        .changeScreen(FineScreenEnum.firstScreen)))
                          ],
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: CustomText(
                              text:
                              ref.read(fineStatsControllerProvider).detailDetailString!),
                        ),
                        ModelsErrorFutureBuilder(
                          future: ref
                              .watch(fineStatsControllerProvider)
                              .getDetailedDetailedModels(),
                          rebuildStream: ref
                              .watch(fineStatsControllerProvider)
                              .detailedFineFineListStream(),
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
