import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/statistics/screens/goal/player_goal_stats_screen.dart';

import 'match_goal_stats_screen.dart';

class MainGoalStatisticsScreen extends StatefulWidget {
  final VoidCallback backToMainMenu;
  const MainGoalStatisticsScreen(
      {super.key, required this.backToMainMenu});

  @override
  State<MainGoalStatisticsScreen> createState() => _MainGoalStatisticsScreenState();
}

  class _MainGoalStatisticsScreenState extends State<MainGoalStatisticsScreen> with TickerProviderStateMixin {

    late TabController tabController;
    int activeTab = 0;

    @override
    void initState() {
      tabController = TabController(
          vsync: this, length: 2,);
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
        length: 2,
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
                    text: 'Body\nhráči',
                  ),
                ),
                FittedBox(
                    child: Tab(
                  text: "Body\nzápasy",
                )),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              PlayerGoalStatsScreen(isFocused: isFocused(0), backToMainMenu: () => widget.backToMainMenu()),
              MatchGoalStatsScreen(isFocused: isFocused(1), backToMainMenu: () => widget.backToMainMenu()),
            ],
          ),
        ),
      ),
    );
  }
}
