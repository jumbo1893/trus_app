import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/home/birthday_text.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';

import '../../../common/widgets/chart/home_chart.dart';
import '../../../common/widgets/chart/pick_chart_player.dart';
import '../../../common/widgets/football/football_match_box.dart';
import '../../../common/widgets/home/random_fact_box.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../controller/home_notifier.dart';

class HomeScreen extends CustomConsumerStatefulWidget {
  static const String id = "home-screen";

  const HomeScreen({
    Key? key,
  }) : super(key: key, title: "Trusí appka", name: id);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const double padding = 20;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);
    final appTeam = ref.read(globalVariablesControllerProvider).appTeam;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: RefreshIndicator(
        color: Colors.orange,
        backgroundColor: Colors.white,
        onRefresh: notifier.load,
        notificationPredicate: (n) => n.depth == 0,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            state.setup.when(
              data: (setup) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    Image.asset(
                      'images/nazev.png',
                      height: 76,
                      width: 331,
                    ),
                    const SizedBox(height: 15),

                    // NEXT MATCH
                    FootballMatchBox(
                      padding: padding,
                      isNextMatch: true,
                      detail: setup.nextAndLastFootballMatch[0],
                      appTeamApiModel: appTeam,

                      onAddPlayers: notifier.onButtonAddPlayersClick,
                      onAddGoals: notifier.onButtonAddGoalsClick,
                      onAddBeer: notifier.onButtonAddBeerClick,
                      onAddFine: notifier.onButtonAddFineClick,
                      onDetailMatch: notifier.onButtonDetailMatchClick,
                      onCommonMatches: notifier.onCommonMatchesClick,
                    ),

                    // LAST MATCH
                    FootballMatchBox(
                      padding: padding,
                      isNextMatch: true,
                      detail: setup.nextAndLastFootballMatch[1],
                      appTeamApiModel: appTeam,
                      onAddPlayers: notifier.onButtonAddPlayersClick,
                      onAddGoals: notifier.onButtonAddGoalsClick,
                      onAddBeer: notifier.onButtonAddBeerClick,
                      onAddFine: notifier.onButtonAddFineClick,
                      onDetailMatch: notifier.onButtonDetailMatchClick,
                      onCommonMatches: notifier.onCommonMatchesClick,
                    ),
                    const SizedBox(height: 15),
                    BirthdayText(
                      padding: padding,
                      nextBirthdayText: setup.nextBirthday,
                    ),
                    const SizedBox(key: ValueKey('player_chart'), height: 15),

                    PickChartPlayer(
                      size: size,
                      padding: padding,
                      chart: setup.chart,
                    ),

                    HomeChart(
                      charts: setup.charts,
                    ),

                    RandomFactBox(
                      facts: setup.randomFacts,
                      padding: padding,
                    ),

                    const SizedBox(height: 24),
                  ],
                );
              },

              // ✅ žádný Loader
              loading: () => const _HomePlaceholder(),

              // ✅ žádný Loader; error dialog ti ukáže globální uiFeedback,
              // tady jen placeholder aby šel pull-to-refresh
              error: (_, __) => const _HomePlaceholder(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 600,
      child: Center(child: Text("")),
    );
  }
}
