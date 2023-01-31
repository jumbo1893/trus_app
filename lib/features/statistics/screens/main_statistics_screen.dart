import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/statistics/screens/match_beer_stats_screen.dart';
import 'package:trus_app/features/statistics/screens/player_beer_stats_screen.dart';
import 'package:trus_app/features/statistics/screens/player_fine_stats_screen.dart';
import 'package:trus_app/features/statistics/screens/match_fine_stats_screen.dart';

class MainStatisticsScreen extends StatelessWidget {
  const MainStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 0,
            bottom: const TabBar(
              labelColor: blackColor,
              indicatorColor: orangeColor,
              tabs: [
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
          body: const TabBarView(
            children: [
              PlayerBeerStatsScreen(),
              MatchBeerStatsScreen(),
              PlayerFineStatsScreen(),
              MatchFineStatsScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
