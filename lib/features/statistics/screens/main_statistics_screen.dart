import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/statistics/screens/match_beer_stats_screen.dart';
import 'package:trus_app/features/statistics/screens/player_beer_stats_screen.dart';
import 'package:trus_app/features/statistics/screens/player_fine_stats_screen.dart';
import 'package:trus_app/features/statistics/screens/match_fine_stats_screen.dart';

class MainStatisticsScreen extends StatefulWidget {
  const MainStatisticsScreen({super.key});

  @override
  State<MainStatisticsScreen> createState() => _MainStatisticsScreenState();
}

  class _MainStatisticsScreenState extends State<MainStatisticsScreen> with TickerProviderStateMixin {

    late TabController tabController;
    int activeTab = 0;

    @override
    void initState() {
      tabController = TabController(
          vsync: this, length: 4,);
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
              PlayerBeerStatsScreen(isFocused: isFocused(0),),
              MatchBeerStatsScreen(isFocused: isFocused(1),),
              PlayerFineStatsScreen(isFocused: isFocused(2),),
              MatchFineStatsScreen(isFocused: isFocused(3),),
            ],
          ),
        ),
      ),
    );
  }
}
