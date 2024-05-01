import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/custom_text.dart';

import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/builder/statistics_error_future_builder.dart';
import '../../../common/widgets/button/statistics_buttons.dart';
import '../../../common/widgets/dropdown/custom_dropdown.dart';
import '../../../models/api/season_api_model.dart';
import '../controller/stats_controller.dart';
import '../stats_screen_enum.dart';

class StatsScreen extends ConsumerStatefulWidget {
  final bool isFocused;
  final StatsController controller;
  final String detailedText;
  final bool matchStatsOrPlayerStats;
  final bool doubleDetail;

  const StatsScreen({
    required this.isFocused,
    required this.controller,
    required this.detailedText,
    required this.matchStatsOrPlayerStats,
    required this.doubleDetail,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
      return StreamBuilder<StatsScreenEnum>(
          stream: widget.controller.screenDetailStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data == StatsScreenEnum.firstScreen) {
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              width: size.width / 2.5 - padding,
                              child: CustomDropdown(
                                onItemSelected: (season) =>
                                    widget.controller.setPickedSeason(season as SeasonApiModel),
                                dropdownList: widget.controller.getSeasons(),
                                pickedItem: widget.controller.pickedSeason(),
                                initData: () =>
                                    widget.controller.setCurrentSeason(),
                                hint: 'Vyber sezonu',
                              )),
                          StatisticsButtons(
                            onSearchButtonClicked: (text) =>
                                widget.controller.getFilteredModels(text),
                            onOrderButtonClicked: () =>
                                widget.controller.onRevertTap(),
                            padding: padding,
                            size: size,
                          )
                        ],
                      ),
                      Expanded(
                        child: StatisticsErrorFutureBuilder(
                          future: widget.controller
                              .getModels(widget.matchStatsOrPlayerStats),
                          onPressed: (model) {
                            widget.controller.setDetail(model);
                          },
                          context: context,
                          rebuildStream: widget.controller.listStream(),
                          overallStream: widget.controller.overAllStatsStream(),
                          overAllStatsInit: () =>
                              widget.controller.initOverallStats(),
                        ),
                      )
                    ],
                  ),
                ),
              );
            } else if (snapshot.data! == StatsScreenEnum.detailScreen) {
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              widget.controller
                                  .changeScreen(StatsScreenEnum.firstScreen);
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
                                  onPressed: () => widget.controller
                                      .changeScreen(
                                          StatsScreenEnum.firstScreen)))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                        child: CustomText(
                            text:
                                "${widget.detailedText} ${widget.controller.getDetailString()!}"),
                      ),
                      Expanded(
                        child: ModelsErrorFutureBuilder(
                          future: widget.controller.getDetailedModels(),
                          rebuildStream: widget.controller.detailedListStream(),
                          onPressed: (model) {
                            widget.doubleDetail ? widget.controller.setDoubleDetail(model) : null;
                          },
                          context: context,
                        ),
                      ),
                    ],
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
                                widget.controller
                                    .changeScreen(StatsScreenEnum.detailScreen);
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
                                    onPressed: () => widget.controller
                                        .changeScreen(
                                            StatsScreenEnum.detailScreen))),
                            SizedBox(
                                child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                widget.controller
                                    .changeScreen(StatsScreenEnum.firstScreen);
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
                                    onPressed: () => widget.controller
                                        .changeScreen(
                                            StatsScreenEnum.firstScreen)))
                          ],
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: CustomText(
                              text: widget.controller.doubleDetailString!),
                        ),
                        ModelsErrorFutureBuilder(
                          future: widget.controller.getDoubleDetailedModels(),
                          rebuildStream:
                              widget.controller.doubleDetailedListStream(),
                          onPressed: (object) {},
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
