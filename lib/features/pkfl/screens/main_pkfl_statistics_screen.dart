import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import '../../../common/widgets/builder/pkfl_stats_error_future_builder.dart';
import '../../../common/widgets/button/statistics_buttons.dart';
import '../../../common/widgets/custom_text.dart';
import '../../../common/widgets/dropdown/pkfl_stats_dropdown.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../controller/pkfl_stats_controller.dart';

class MainPkflStatisticsScreen extends CustomConsumerStatefulWidget {
  static const String id = "main-pkfl-statistics-screen";

  const MainPkflStatisticsScreen({
    Key? key,
  }) : super(key: key, title: "Statistika PKFL", name: id);

  @override
  ConsumerState<MainPkflStatisticsScreen> createState() =>
      _MainPkflStatisticsScreenState();
}

class _MainPkflStatisticsScreenState
    extends ConsumerState<MainPkflStatisticsScreen> {
  void onTabChanged(int tab) {
    if (tab == 0) {
      ref.watch(pkflStatsControllerProvider).setSeason(true);
    } else {
      ref.watch(pkflStatsControllerProvider).setSeason(false);
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
                              child: PkflStatsDropdown(
                                onValueSelected: (option) => ref
                                    .watch(pkflStatsControllerProvider)
                                    .setPickedOption(option),
                                pickedOption: ref
                                    .watch(pkflStatsControllerProvider)
                                    .pickedOption(),
                                initOption: () => ref
                                    .watch(pkflStatsControllerProvider)
                                    .setCurrentOption(),
                              )),
                          StatisticsButtons(
                            onSearchButtonClicked: (text) => ref
                                .read(pkflStatsControllerProvider)
                                .setFilteredText(text),
                            onOrderButtonClicked: () => ref
                                .read(pkflStatsControllerProvider)
                                .onRevertTap(),
                            padding: padding,
                            size: size,
                          )
                        ],
                      ),
                      PkflStatsErrorFutureBuilder(
                        future:
                            ref.watch(pkflStatsControllerProvider).getModels(),
                        context: context,
                        rebuildStream: ref
                            .watch(pkflStatsControllerProvider)
                            .pkflPlayerStats(),
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
