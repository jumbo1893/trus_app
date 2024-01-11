import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/match/screens/edit_match_screen.dart';
import 'package:trus_app/features/pkfl/screens/pkfl_common_matches_screen.dart';
import 'package:trus_app/features/pkfl/screens/pkfl_match_detail_screen.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/match_detail_options.dart';
import '../../main/screen_controller.dart';
import '../../match/controller/match_controller.dart';

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
          text: 'Upravit zápas',
        ),
      ));
    }
    if (matchOptionList.contains(MatchDetailOptions.pkflDetail)) {
      widgets.add(const FittedBox(
        child: Tab(
          text: 'Detail',
        ),
      ));
    }
    if (matchOptionList.contains(MatchDetailOptions.commonMatches)) {
      widgets.add(const FittedBox(
        child: Tab(
          text: 'Vzájemné zápasy',
        ),
      ));
    }
    return widgets;
  }

  List<Widget> getWidgets(List<MatchDetailOptions> matchOptionList) {
    List<Widget> widgets = [];
    if (matchOptionList.contains(MatchDetailOptions.editMatch)) {
      widgets.add(EditMatchScreen(
        isFocused: isFocused(MatchDetailOptions.editMatch, matchOptionList),
      ));
    }
    if (matchOptionList.contains(MatchDetailOptions.pkflDetail)) {
      widgets.add(PkflMatchDetailScreen(
        isFocused: isFocused(MatchDetailOptions.pkflDetail, matchOptionList),
      ));
    }
    if (matchOptionList.contains(MatchDetailOptions.commonMatches)) {
      widgets.add(PkflCommonMatchesScreen(
        isFocused: isFocused(MatchDetailOptions.commonMatches, matchOptionList),
      ));
    }
    return widgets;
  }

  bool isFocused(
      MatchDetailOptions screen, List<MatchDetailOptions> matchOptionList) {
    int index;
    if (!matchOptionList.contains(screen)) {
      return false;
    }
    if (screen == MatchDetailOptions.editMatch) {
      index = 0;
    } else if (screen == MatchDetailOptions.pkflDetail) {
      if (matchOptionList.contains(MatchDetailOptions.editMatch)) {
        index = 1;
      } else {
        index = 0;
      }
    } else {
      if (matchOptionList.contains(MatchDetailOptions.editMatch)) {
        index = 2;
      } else if (matchOptionList.contains(MatchDetailOptions.pkflDetail)) {
        index = 1;
      } else {
        index = 0;
      }
    }
    return index == activeTab;
  }

  int getInitialIndex(MatchDetailOptions preferredScreen,
      List<MatchDetailOptions> availableOptions) {
    if (preferredScreen == MatchDetailOptions.editMatch) {
      return 0;
    } else if (preferredScreen == MatchDetailOptions.pkflDetail) {
      if (availableOptions.contains(MatchDetailOptions.editMatch) &&
          availableOptions.contains(MatchDetailOptions.pkflDetail)) {
        return 1;
      } else {
        return 0;
      }
    } else {
      if (availableOptions.contains(MatchDetailOptions.editMatch)) {
        if (availableOptions.contains(MatchDetailOptions.commonMatches)) {
          return 2;
        } else if (availableOptions.contains(MatchDetailOptions.pkflDetail)) {
          return 1;
        } else {
          return 0;
        }
      } else {
        if (availableOptions.contains(MatchDetailOptions.commonMatches)) {
          if (availableOptions.contains(MatchDetailOptions.pkflDetail)) {
            return 1;
          }
          return 0;
        } else {
          return 0;
        }
      }
    }
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
                        ref.read(screenControllerProvider).pkflMatchId)
                : ref.read(matchControllerProvider).setupScreen(
                      ref.read(screenControllerProvider).matchId,
                      ref.read(screenControllerProvider).pkflMatch?.id,
                    ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              } else if (snapshot.hasError) {
                Future.delayed(
                    Duration.zero,
                    () => showErrorDialog(
                        snapshot.error!.toString(),
                        () => ref
                            .read(screenControllerProvider)
                            .changeFragment(HomeScreen.id),
                        context));
                return const Loader();
              }
              List<MatchDetailOptions> matchOptionList = snapshot.data!;
              activeTab = getInitialIndex(preferredScreen, matchOptionList);
              tabController = TabController(
                  vsync: this,
                  length: matchOptionList.length,
                  initialIndex:
                      getInitialIndex(preferredScreen, matchOptionList));
              return StreamBuilder<int>(
                  stream:
                      ref.watch(matchControllerProvider).matchDetailScreen(),
                  builder: (context, streamSnapshot) {
                    if (snapshot.hasError) {
                      Future.delayed(
                          Duration.zero,
                          () => showErrorDialog(
                              snapshot.error!.toString(),
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
                          getInitialIndex(preferredScreen, matchOptionList),
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
