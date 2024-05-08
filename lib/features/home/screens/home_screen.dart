import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/beer/screens/beer_simple_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_match_screen.dart';
import 'package:trus_app/features/pkfl/screens/match_detail_screen.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/chart/home_chart.dart';
import '../../../common/widgets/pick_chart_player.dart';
import '../../../common/widgets/pkfl/pkfl_match_box.dart';
import '../../../common/widgets/random_fact_box.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/api/home/home_setup.dart';
import '../../../models/api/pkfl/pkfl_match_api_model.dart';
import '../../../models/enum/match_detail_options.dart';
import '../../general/error/api_executor.dart';
import '../../goal/screen/goal_screen.dart';
import '../../main/screen_controller.dart';
import '../../match/screens/add_match_screen.dart';
import '../controller/home_controller.dart';

class HomeScreen extends CustomConsumerStatefulWidget {
  static const String id = "home-screen";

  const HomeScreen(
      {Key? key,
      })
      : super(key: key, title: "Trusí appka", name: id);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const double padding = 20;

  void setScreenToCommonMatches(PkflMatchApiModel pkflMatchApiModel) {
    ref
        .read(screenControllerProvider)
        .setPreferredScreen(MatchDetailOptions.commonMatches);
    ref.read(screenControllerProvider).setPkflMatch(pkflMatchApiModel);
    ref.read(screenControllerProvider).changeFragment(MatchDetailScreen.id);
  }

  void setScreenToEditMatch(int matchId) {
    ref
        .read(screenControllerProvider)
        .setPreferredScreen(MatchDetailOptions.editMatch);
    ref.read(screenControllerProvider).setMatchId(matchId);
    ref.read(screenControllerProvider).changeFragment(MatchDetailScreen.id);
  }

  void setScreenAddGoals(int matchId) {
    ref.read(screenControllerProvider).setMatchId(matchId);
    ref.read(screenControllerProvider).changeFragment(GoalScreen.id);
  }

  void setScreenAddFines(int matchId) {
    ref.read(screenControllerProvider).setMatchId(matchId);
    ref.read(screenControllerProvider).changeFragment(FineMatchScreen.id);
  }

  void setScreenAddBeers(int matchId) {
    ref.read(screenControllerProvider).setMatchId(matchId);
    ref.read(screenControllerProvider).changeFragment(BeerSimpleScreen.id);
  }

  void onEditMatchClicked(PkflMatchApiModel pkflMatch) {
    if (pkflMatch.matchIdList.isEmpty) {
      ref.read(screenControllerProvider).setPkflMatch(pkflMatch);
      ref.read(screenControllerProvider).changeFragment(AddMatchScreen.id);
    } else {
      setScreenToEditMatch(pkflMatch.matchIdList[0]);
      ref.read(screenControllerProvider).setMatchId(pkflMatch.matchIdList[0]);
      ref.read(screenControllerProvider).changeFragment(MatchDetailScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: RefreshIndicator(
        color: Colors.orange,
        backgroundColor: Colors.white,
        onRefresh: () async {
          return executeApi<void>(() async {
            return await ref.read(homeControllerProvider).reloadSetupHome(true);
          }, () => setState(() {}), context, false)
              .whenComplete(() => setState(() {}));
        },
        notificationPredicate: (ScrollNotification notification) {
          return notification.depth == 0;
        },
        child: FutureBuilder<HomeSetup?>(
            future: executeApi<HomeSetup?>(() async {
              return await ref
                  .read(homeControllerProvider)
                  .setupHome(ref.read(screenControllerProvider).isChangedMatch());
            }, () => setState(() {}), context, false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData) {
                return const Loader();
              } else if (snapshot.hasError) {
                Future.delayed(
                    Duration.zero,
                    () => showErrorDialog(snapshot.error!.toString(),
                        () => setState(() {}), context));
                return const Loader();
              }
              HomeSetup homeSetup = snapshot.data!;
              return SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/nazev.png',
                          height: 76,
                          width: 331,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        PkflMatchBox(
                          pkflMatchFuture: ref
                              .read(homeControllerProvider)
                              .getNextPkflMatch(),
                          padding: padding,
                          isNextMatch: true,
                          onButtonAddPlayersClick: (pkflMatch) =>
                              {onEditMatchClicked(pkflMatch)},
                          onButtonAddGoalsClick: (pkflMatch) =>
                              {setScreenAddGoals(pkflMatch.matchIdList[0])},
                          onButtonAddBeerClick: (pkflMatch) =>
                              {setScreenAddBeers(pkflMatch.matchIdList[0])},
                          onButtonAddFineClick: (pkflMatch) =>
                              {setScreenAddFines(pkflMatch.matchIdList[0])},
                          onCommonMatchesClick: (pkflMatch) =>
                              {setScreenToCommonMatches(pkflMatch)},
                        ),
                        PkflMatchBox(
                          pkflMatchFuture: ref
                              .read(homeControllerProvider)
                              .getLastPkflMatch(),
                          padding: padding,
                          isNextMatch: false,
                          onButtonAddPlayersClick: (pkflMatch) =>
                              {onEditMatchClicked(pkflMatch)},
                          onButtonAddGoalsClick: (pkflMatch) =>
                              {setScreenAddGoals(pkflMatch.matchIdList[0])},
                          onButtonAddBeerClick: (pkflMatch) =>
                              {setScreenAddBeers(pkflMatch.matchIdList[0])},
                          onButtonAddFineClick: (pkflMatch) =>
                              {setScreenAddFines(pkflMatch.matchIdList[0])},
                          onCommonMatchesClick: (pkflMatch) =>
                              {setScreenToCommonMatches(pkflMatch)},
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.all(3.0),
                          width: size.width - padding * 2,
                          child: Center(
                              child: Row(
                            children: [
                              const Icon(
                                Icons.cake,
                                color: orangeColor,
                                size: 40,
                              ),
                              Flexible(
                                child: Text(homeSetup.nextBirthday,
                                    textAlign: TextAlign.center,
                                    key: const ValueKey('birthday_text')),
                              ),
                            ],
                          )),
                        ),
                        const SizedBox(
                          key: ValueKey('player_chart'),
                          height: 15,
                        ),
                        homeSetup.chart != null
                            ? (homeSetup.chart!.coordinates.isNotEmpty
                                ? HomeChart(
                                    chart: homeSetup.chart!,
                                    charts: homeSetup.charts!,
                                  )
                                : Container())
                            : PickChartPlayer(
                                size: size,
                                padding: padding,
                                onPlayerSelected: (player) => ref
                                    .watch(homeControllerProvider)
                                    .setupPlayerId(player.id!)
                                    .whenComplete(() => setState(() {
                                          ref
                                              .read(homeControllerProvider)
                                              .playerId = player.id!;
                                        })),
                              ),
                        RandomFactBox(
                          padding: padding,
                          randomFactStream: ref
                              .watch(homeControllerProvider)
                              .getRandomFacts(),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
