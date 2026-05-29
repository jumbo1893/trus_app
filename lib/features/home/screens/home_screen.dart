import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/home/birthday_text.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/home/screens/rotating_stats_widget.dart';

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
  static const double sectionSpacing = 16;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);
    final appTeam = ref.read(globalVariablesControllerProvider).appTeam;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleImagePath = isDark
        ? 'images/nazev_background_dark.png'
        : 'images/nazev_background.png';

    return Scaffold(
      body: RefreshIndicator(
        color: context.appColors.legacyAccent,
        backgroundColor: context.appColors.cardBackground,
        onRefresh: notifier.load,
        notificationPredicate: (n) => n.depth == 0,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          children: [
            state.setup.when(
              data: (setup) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      titleImagePath,
                      height: 76,
                      width: 331,
                    ),
                    const SizedBox(height: sectionSpacing),

                    FootballMatchBox(
                      isNextMatch: true,
                      dashboardMatch: setup.nextMatch,
                      appTeamApiModel: appTeam,
                      onAddPlayers: notifier.onButtonAddPlayersClick,
                      onAddGoals: notifier.onButtonAddGoalsClick,
                      onAddBeer: notifier.onButtonAddBeerClick,
                      onAddFine: notifier.onButtonAddFineClick,
                      onDetailMatch: notifier.onButtonDetailMatchClick,
                      onCommonMatches: notifier.onCommonMatchesClick,
                      onRedirect: notifier.onRedirect,
                    ),
                    const SizedBox(height: sectionSpacing),

                    FootballMatchBox(
                      isNextMatch: false,
                      dashboardMatch: setup.lastMatch,
                      appTeamApiModel: appTeam,
                      onAddPlayers: notifier.onButtonAddPlayersClick,
                      onAddGoals: notifier.onButtonAddGoalsClick,
                      onAddBeer: notifier.onButtonAddBeerClick,
                      onAddFine: notifier.onButtonAddFineClick,
                      onDetailMatch: notifier.onButtonDetailMatchClick,
                      onCommonMatches: notifier.onCommonMatchesClick,
                      onRedirect: notifier.onRedirect,
                    ),
                    const SizedBox(height: sectionSpacing),

                    BirthdayText(
                      nextBirthdayText: setup.nextBirthday,
                    ),
                    const SizedBox(height: sectionSpacing),

                    RotatingStatsWidget(statsBoards: setup.statsBoards, onRedirect: notifier.onRedirect,),
                    const SizedBox(height: sectionSpacing),

                    RandomFactBox(
                      facts: setup.randomFacts,
                    ),

                    const SizedBox(height: 24),
                  ],
                );
              },
              loading: () => const _HomePlaceholder(),
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