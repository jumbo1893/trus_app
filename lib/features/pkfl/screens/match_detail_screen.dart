import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/match/screens/edit_match_screen.dart';
import 'package:trus_app/features/pkfl/screens/pkfl_common_matches_screen.dart';
import 'package:trus_app/features/pkfl/screens/pkfl_match_detail_screen.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/loader.dart';
import '../../../models/enum/match_detail_options.dart';
import '../../match/controller/match_controller.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  final VoidCallback backToMainMenu;
  final int? pkflMatchId;
  final int? matchId;
  final MatchDetailOptions preferredScreen;
  final bool isFocused;
  final VoidCallback onButtonConfirmPressed;
  final Function(int id) setMatchId;
  final VoidCallback onChangePlayerGoalsPressed;

  const MatchDetailScreen({
    super.key,
    required this.onButtonConfirmPressed,
    required this.setMatchId,
    required this.onChangePlayerGoalsPressed,
    required this.backToMainMenu,
    required this.pkflMatchId,
    required this.matchId,
    required this.preferredScreen,
    required this.isFocused,
  });

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
        backToMainMenu: () => widget.backToMainMenu(), onButtonConfirmPressed: () => widget.onButtonConfirmPressed(), setMatchId: (id) => widget.setMatchId(id), onChangePlayerGoalsPressed: ()  => widget.onChangePlayerGoalsPressed(),
      ));
    }
    if (matchOptionList.contains(MatchDetailOptions.pkflDetail)) {
      widgets.add(PkflMatchDetailScreen(
        isFocused: isFocused(MatchDetailOptions.pkflDetail, matchOptionList),
        backToMainMenu: () => widget.backToMainMenu(),
      ));
    }
    if (matchOptionList.contains(MatchDetailOptions.commonMatches)) {
      widgets.add(PkflCommonMatchesScreen(
        isFocused: isFocused(MatchDetailOptions.commonMatches, matchOptionList),
        backToMainMenu: () => widget.backToMainMenu(),
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
      } else {
        index = 1;
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
          return 1;
        } else {
          return 0;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      return MaterialApp(
        home: FutureBuilder<List<MatchDetailOptions>>(
            future: ref
                .watch(matchControllerProvider)
                .setupScreen(widget.matchId, widget.pkflMatchId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              } else if (snapshot.hasError) {
                Future.delayed(
                    Duration.zero,
                    () => showErrorDialog(snapshot.error!.toString(),
                        widget.backToMainMenu, context));
                return const Loader();
              }
              List<MatchDetailOptions> matchOptionList = snapshot.data!;
              activeTab =
                  getInitialIndex(widget.preferredScreen, matchOptionList);
              tabController = TabController(
                  vsync: this,
                  length: matchOptionList.length,
                  initialIndex:
                      getInitialIndex(widget.preferredScreen, matchOptionList));
              return StreamBuilder<int>(
                  stream:
                      ref.watch(matchControllerProvider).matchDetailScreen(),
                  builder: (context, streamSnapshot) {
                    if (snapshot.hasError) {
                      Future.delayed(
                          Duration.zero,
                          () => showErrorDialog(snapshot.error!.toString(),
                              widget.backToMainMenu, context));
                      return const Loader();
                    }
                    if (streamSnapshot.data != null) {
                      activeTab = streamSnapshot.data!;
                      tabController.index = streamSnapshot.data!;
                    }
                    return DefaultTabController(
                      length: matchOptionList.length,
                      initialIndex: getInitialIndex(
                          widget.preferredScreen, matchOptionList),
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
