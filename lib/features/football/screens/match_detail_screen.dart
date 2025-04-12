import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/match/screens/edit_match_screen.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/match_detail_options.dart';
import '../../main/screen_controller.dart';
import '../../match/controller/match_controller.dart';
import 'football_match_detail_screen.dart';
import 'football_mutual_matches_screen.dart';

class MatchDetailScreen extends CustomConsumerStatefulWidget {
  static const String id = "match-detail-screen";

  const MatchDetailScreen({
    Key? key,
  }) : super(key: key, title: "Detail zápasu", name: id);

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  int activeTab = 0;

  List<Widget> getTabs(List<MatchDetailOptions> matchOptionList) {
    List<Widget> widgets = [];
    if (matchOptionList.contains(MatchDetailOptions.editMatch)) {
      widgets.add(const FittedBox(
        child: Tab(
          text: 'Upravit',
        ),
      ));
    }
    if (matchOptionList.contains(MatchDetailOptions.footballMatchDetail)) {
      widgets.add(const FittedBox(
        child: Tab(
          text: 'Detail',
        ),
      ));
    }
    if (matchOptionList.contains(MatchDetailOptions.homeMatchDetail)) {
      widgets.add(const FittedBox(
        child: Tab(
          text: 'Domácí',
        ),
      ));
    }
    if (matchOptionList.contains(MatchDetailOptions.awayMatchDetail)) {
      widgets.add(const FittedBox(
        child: Tab(
          text: 'Hosté',
        ),
      ));
    }
    if (matchOptionList.contains(MatchDetailOptions.mutualMatches)) {
      widgets.add(const FittedBox(
        child: Tab(
          text: 'H2H',
        ),
      ));
    }
    return widgets;
  }

  //podle tohodle poznáme pořadí
  List<Widget> getWidgets(List<MatchDetailOptions> matchOptionList) {
    List<Widget> widgets = [];
    if (matchOptionList.contains(MatchDetailOptions.editMatch)) {
      widgets.add(EditMatchScreen(
          isFocused:
              true //isFocused(MatchDetailOptions.editMatch, matchOptionList),
          ));
    }
    if (matchOptionList.contains(MatchDetailOptions.footballMatchDetail)) {
      widgets.add(const FootballMatchDetailScreen());
    }
    if (matchOptionList.contains(MatchDetailOptions.homeMatchDetail)) {
      widgets.add(const FootballMatchDetailScreen());
    }
    if (matchOptionList.contains(MatchDetailOptions.awayMatchDetail)) {
      widgets.add(const FootballMatchDetailScreen());
    }
    if (matchOptionList.contains(MatchDetailOptions.mutualMatches)) {
      widgets.add(FootballMutualMatchesScreen(
          getMutualMatches:
              ref.watch(matchControllerProvider).returnMutualMatches()));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(MatchDetailScreen.id)) {
      MatchDetailOptions preferredScreen =
          ref.read(screenControllerProvider).preferredScreen;
      return MaterialApp(
        home: FutureBuilder<List<MatchDetailOptions>>(
            future: ref.read(screenControllerProvider).isCommonMatchesOnly
                ? ref
                    .read(matchControllerProvider)
                    .setupScreenForCommonMatchesOnly(
                        ref.read(screenControllerProvider).footballTeamId)
                : ref.read(matchControllerProvider).setupScreen(
                      ref.read(screenControllerProvider).matchId,
                      ref.read(screenControllerProvider).footballMatch?.id,
                    ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              } else if (snapshot.hasError) {
                Future.delayed(
                    Duration.zero,
                    () => showErrorDialog(
                        snapshot,
                        () => ref
                            .read(screenControllerProvider)
                            .changeFragment(HomeScreen.id),
                        context));
                return const Loader();
              }
              List<MatchDetailOptions> matchOptionList = snapshot.data!;
              activeTab = ref.read(matchControllerProvider).getInitialIndex(preferredScreen, matchOptionList);
              tabController = TabController(
                  vsync: this,
                  length: matchOptionList.length,
                  initialIndex: activeTab);
              return StreamBuilder<int>(
                  stream:
                      ref.watch(matchControllerProvider).matchDetailScreen(),
                  builder: (context, streamSnapshot) {
                    if (snapshot.hasError) {
                      Future.delayed(
                          Duration.zero,
                          () => showErrorDialog(
                              snapshot,
                              () => ref
                                  .read(screenControllerProvider)
                                  .changeFragment(HomeScreen.id),
                              context));
                      return const Loader();
                    }
                    if (streamSnapshot.data != null) {
                      activeTab = streamSnapshot.data!;
                      tabController.index = streamSnapshot.data!;
                    }
                    return DefaultTabController(
                      length: matchOptionList.length,
                      initialIndex:
                      activeTab,
                      child: Scaffold(
                        appBar: AppBar(
                          backgroundColor: Colors.white,
                          toolbarHeight: 0,
                          bottom: TabBar(
                            onTap: (index) => ref
                                .read(matchControllerProvider)
                                .changeMatchDetailScreen(index),
                            labelColor: blackColor,
                            indicatorColor: orangeColor,
                            tabs: getTabs(matchOptionList),
                          ),
                        ),
                        body: TabBarView(
                          controller: tabController,
                          children: getWidgets(matchOptionList),
                        ),
                      ),
                    );
                  });
            }),
      );
    } else {
      return Container();
    }
  }
}
