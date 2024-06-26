import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';

import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../controller/beer_stats_controller.dart';
import '../controller/fine_stats_controller.dart';
import 'stats_screen.dart';

class MainStatisticsScreen extends CustomConsumerStatefulWidget {
  static const String id = "main-statistics-screen";

  const MainStatisticsScreen({
    Key? key,
  }) : super(key: key, title: "Statistiky pokut/piv", name: id);

  @override
  ConsumerState<MainStatisticsScreen> createState() =>
      _MainStatisticsScreenState();
}

class _MainStatisticsScreenState extends ConsumerState<MainStatisticsScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  int activeTab = 0;

  @override
  void initState() {
    tabController = TabController(
      vsync: this,
      length: 4,
    );
    super.initState();
  }

  void changeTab(int tab) {
    setState(() {
      activeTab = tab;
    });
    tabController.index = tab;
  }

  bool isFocused(int index) {
    return index == activeTab;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 0,
            bottom: TabBar(
              onTap: (index) => changeTab(index),
              labelColor: blackColor,
              indicatorColor: orangeColor,
              tabs: const [
                FittedBox(
                  child: Tab(
                    text: 'Piva\nhráči',
                  ),
                ),
                FittedBox(
                    child: Tab(
                  text: "Piva\nzápasy",
                )),
                FittedBox(
                  child: Tab(
                    text: 'Pokuty\nhráči',
                  ),
                ),
                FittedBox(
                    child: Tab(
                  text: "Pokuty\nzápasy",
                )),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              StatsScreen(
                isFocused: isFocused(0),
                controller: ref.watch(beerStatsControllerProvider),
                detailedText: "Detail pitiva pro ",
                matchStatsOrPlayerStats: false,
                doubleDetail: false,
              ),
              StatsScreen(
                isFocused: isFocused(1),
                controller: ref.watch(beerStatsControllerProvider),
                detailedText: "Detail pitiva pro ",
                matchStatsOrPlayerStats: true,
                doubleDetail: false,
              ),
              StatsScreen(
                isFocused: isFocused(2),
                controller: ref.watch(fineStatsControllerProvider),
                detailedText: "Detail pokut pro",
                matchStatsOrPlayerStats: false,
                doubleDetail: true,
              ),
              StatsScreen(
                isFocused: isFocused(3),
                controller: ref.watch(fineStatsControllerProvider),
                detailedText: "Detail pokut pro",
                matchStatsOrPlayerStats: true,
                doubleDetail: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
