import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/football/table/controller/football_table_team_controller.dart';
import 'package:trus_app/features/football/table/screens/table_team_detail_matches_screen.dart';
import 'package:trus_app/features/football/table/screens/table_team_detail_screen.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/football/table_team_api_model.dart';

import '../../../../common/utils/utils.dart';
import '../../../../common/widgets/loader.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../../models/api/football/detail/football_team_detail.dart';
import '../../../home/screens/home_screen.dart';
import '../../../main/screen_controller.dart';
import '../../screens/football_mutual_matches_screen.dart';
class MainTableTeamScreen extends CustomConsumerStatefulWidget {
  static const String id = "main-table-team-screen";

  const MainTableTeamScreen({
    Key? key,
  }) : super(key: key, title: "Detail týmu", name: id);

  @override
  ConsumerState<MainTableTeamScreen> createState() =>
      _MainTableTeamScreenState();
}

class _MainTableTeamScreenState extends ConsumerState<MainTableTeamScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  int activeTab = 0;

  @override
  void initState() {
    /*tabController = TabController(
      vsync: this,
      length: 4,
    );*/
    super.initState();
  }

  bool isFocused(int index) {
    return index == activeTab;
  }

  List<Widget> getWidgets(List<FootballMatchApiModel> mutualMatches) {
    List<Widget> widgets = [];
    widgets.add(
      const FittedBox(
        child: Tab(
          text: 'Detail',
        ),
      ),
    );
    widgets.add(
      const FittedBox(
        child: Tab(
          text: 'Program',
        ),
      ),
    );
    widgets.add(
      const FittedBox(
        child: Tab(
          text: 'Výsledky',
        ),
      ),
    );
    if (mutualMatches.isNotEmpty) {
      widgets.add(
        const FittedBox(
          child: Tab(
            text: 'H2H',
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> getTabs(List<FootballMatchApiModel> mutualMatches) {
    List<Widget> widgets = [];
    widgets.add(const TableTeamDetailScreen());
    widgets.add(const TableTeamDetailMatchesScreen());
    widgets.add(const TableTeamDetailMatchesScreen());
    if (mutualMatches.isNotEmpty) {
      widgets.add(FootballMutualMatchesScreen(
          getMutualMatches:
          ref.watch(footballTableTeamControllerProvider).returnMutualMatches()));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    TableTeamApiModel tableTeamApiModel =
        ref.watch(screenControllerProvider).tableTeamApiModel;
    return Scaffold(
        body: FutureBuilder<FootballTeamDetail>(
            future: ref
                .watch(footballTableTeamControllerProvider)
                .loadFootballDetail(tableTeamApiModel.id!),
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
              FootballTeamDetail footballTeamDetail = snapshot.data!;
              tabController = TabController(
                vsync: this,
                length: getWidgets(footballTeamDetail.mutualMatches).length,
              );
              return StreamBuilder<int>(
                  stream:
                  ref.watch(footballTableTeamControllerProvider).tabControllerScreen(),
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
                    length: getTabs(footballTeamDetail.mutualMatches).length,
                    initialIndex: 0,
                    child: Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        toolbarHeight: 0,
                        bottom: TabBar(
                          controller: tabController,
                          onTap: (index) => ref
                              .read(footballTableTeamControllerProvider)
                              .changeDetailTab(index),
                          labelColor: blackColor,
                          indicatorColor: orangeColor,
                          tabs: getWidgets(footballTeamDetail.mutualMatches),
                        ),
                      ),
                      body: TabBarView(
                        controller: tabController,
                        children: getTabs(footballTeamDetail.mutualMatches),
                      ),
                    ),
                  );
                }
              );
            }));
  }
}
