import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/birthday_text.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/chart/home_chart.dart';
import '../../../common/widgets/chart/pick_chart_player.dart';
import '../../../common/widgets/football/football_match_box.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/random_fact_box.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../general/error/api_executor.dart';
import '../../main/screen_controller.dart';
import '../controller/home_controller.dart';

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
    final size = MediaQuery.of(context).size;
    final isLoading = ref.watch(homeLoadingProvider);
    return Stack(
      children: [
        Scaffold(
          body: RefreshIndicator(
            color: Colors.orange,
            backgroundColor: Colors.white,
            onRefresh: () async {
              return executeApi<void>(() async {
                return await ref.read(homeControllerProvider).reloadSetupHome();
              }, () => setState(() {}), context, false);
            },
            notificationPredicate: (ScrollNotification notification) {
              return notification.depth == 0;
            },
            child: FutureBuilder<void>(
                future: ref.watch(homeControllerProvider).setupHome(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  } else if (snapshot.hasError) {
                    Future.delayed(
                        Duration.zero,
                        () => showErrorDialog(snapshot, () {
                              ref
                                  .read(screenControllerProvider)
                                  .changeFragment(HomeScreen.id);
                            }, context));
                    return const Loader();
                  }
                  return ColumnFutureBuilder(
                    loadModelFuture:
                        ref.watch(homeControllerProvider).homeSetupView(),
                    loadingScreen: null,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    columns: [
                      Image.asset(
                        'images/nazev.png',
                        height: 76,
                        width: 331,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      FootballMatchBox(
                        footballMatchBoxCallback: ref.watch(homeControllerProvider),
                        footballMatchDetailControllerMixin:
                            ref.watch(homeControllerProvider),
                        padding: padding,
                        isNextMatch: true,
                        hashKey: ref.read(homeControllerProvider).nextMatchKey(),
                        appTeamApiModel: ref.read(globalVariablesControllerProvider).appTeam,
                      ),
                      FootballMatchBox(
                        footballMatchBoxCallback: ref.watch(homeControllerProvider),
                        footballMatchDetailControllerMixin:
                            ref.watch(homeControllerProvider),
                        padding: padding,
                        isNextMatch: false,
                        hashKey: ref.read(homeControllerProvider).lastMatchKey(),
                        appTeamApiModel: ref.read(globalVariablesControllerProvider).appTeam,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      BirthdayText(
                          viewControllerMixin: ref.watch(homeControllerProvider),
                          padding: padding,
                          hashKey:
                              ref.read(homeControllerProvider).nextBirthdayKey()),
                      const SizedBox(
                        key: ValueKey('player_chart'),
                        height: 15,
                      ),
                      PickChartPlayer(
                          size: size,
                          padding: padding,
                          iChartPickedPlayerCallback:
                              ref.watch(homeControllerProvider),
                          chartControllerMixin: ref.watch(homeControllerProvider),
                          hashKey: ref.read(homeControllerProvider).chartKey()),
                      HomeChart(
                          chartListControllerMixin:
                              ref.watch(homeControllerProvider),
                          hashKey: ref.read(homeControllerProvider).chartsKey()),
                      RandomFactBox(
                          stringListControllerMixin:
                              ref.watch(homeControllerProvider),
                          hashKey: ref.read(homeControllerProvider).randomFactKey(),
                          padding: padding)
                    ],
                  );
                }),
          ),
        ),
        if (isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.orange)),
      ],
    );
  }
}
