import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';

import '../../../common/widgets/builder/pkfl_stats_error_future_builder.dart';
import '../../../common/widgets/button/statistics_buttons.dart';
import '../../../common/widgets/custom_text.dart';
import '../../../common/widgets/dropdown/football_stats_dropdown.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../controller/football_stats_controller.dart';

class MainFootballStatisticsScreen extends CustomConsumerStatefulWidget {
  static const String id = "main-football-statistics-screen";

  const MainFootballStatisticsScreen({
    Key? key,
  }) : super(key: key, title: "Statistika ligy", name: id);

  @override
  ConsumerState<MainFootballStatisticsScreen> createState() =>
      _MainFootballStatisticsScreenState();
}

class _MainFootballStatisticsScreenState
    extends ConsumerState<MainFootballStatisticsScreen> {
  void onTabChanged(int tab) {
    if (tab == 0) {
      ref.watch(footballStatsControllerProvider).setSeason(true);
    } else {
      ref.watch(footballStatsControllerProvider).setSeason(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double padding = 8.0;
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              toolbarHeight: 0,
              bottom: TabBar(
                onTap: (tab) => onTabChanged(tab),
                labelColor: blackColor,
                indicatorColor: orangeColor,
                tabs: const [
                  FittedBox(
                      child: Tab(
                    child: CustomText(text: "Aktuální sezona"),
                  )),
                  FittedBox(
                      child: Tab(
                    child: CustomText(text: "Všechny zápasy"),
                  )),
                ],
              ),
            ),
            body: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(padding),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              width: size.width / 2.5 - padding,
                              child: FootballStatsDropdown(
                                onValueSelected: (option) => ref
                                    .watch(footballStatsControllerProvider)
                                    .setPickedOption(option),
                                pickedOption: ref
                                    .watch(footballStatsControllerProvider)
                                    .pickedOption(),
                                initOption: () => ref
                                    .watch(footballStatsControllerProvider)
                                    .setCurrentOption(),
                              )),
                          StatisticsButtons(
                            onSearchButtonClicked: (text) => ref
                                .read(footballStatsControllerProvider)
                                .setFilteredText(text),
                            onOrderButtonClicked: () => ref
                                .read(footballStatsControllerProvider)
                                .onRevertTap(),
                            padding: padding,
                            size: size,
                          )
                        ],
                      ),
                      FootballStatsErrorFutureBuilder(
                        future:
                            ref.watch(footballStatsControllerProvider).getModels(),
                        context: context,
                        rebuildStream: ref
                            .watch(footballStatsControllerProvider)
                            .footballPlayerStats(),
                      )
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
