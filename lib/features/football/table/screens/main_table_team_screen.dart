import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/notifier/loader/loading_overlay.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/football/table/screens/table_team_mutual_matches_screen.dart';
import 'package:trus_app/features/main/screen_controller.dart';

import '../controller/football_table_team_detail_notifier.dart';
import '../football_team_detail_tab.dart';
import 'table_team_detail_matches_screen.dart';
import 'table_team_detail_screen.dart';

class MainTableTeamScreen extends CustomConsumerStatefulWidget {
  static const String id = "main-table-team-screen";

  const MainTableTeamScreen({Key? key})
      : super(key: key, title: "Detail týmu", name: id);

  @override
  ConsumerState<MainTableTeamScreen> createState() => _MainTableTeamScreenState();
}

class _MainTableTeamScreenState extends ConsumerState<MainTableTeamScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _syncTabController(List<FootballTeamDetailTab> tabs, FootballTeamDetailTab activeTab) {
    if (tabs.isEmpty) return;

    final idx = tabs.indexOf(activeTab);
    final safeIndex = idx >= 0 ? idx : 0;

    final needsRecreate = _tabController == null || _tabController!.length != tabs.length;
    if (needsRecreate) {
      _tabController?.dispose();
      _tabController = TabController(
        vsync: this,
        length: tabs.length,
        initialIndex: safeIndex,
      );
      return;
    }

    if (_tabController!.index != safeIndex) {
      _tabController!.index = safeIndex;
    }
  }

  Tab _tabLabel(FootballTeamDetailTab t) {
    switch (t) {
      case FootballTeamDetailTab.detail:
        return const Tab(text: "Detail");
      case FootballTeamDetailTab.nextMatches:
        return const Tab(text: "Program");
      case FootballTeamDetailTab.pastMatches:
        return const Tab(text: "Výsledky");
      case FootballTeamDetailTab.mutualMatches:
        return const Tab(text: "H2H");
    }
  }

  Widget _screenFor(FootballTeamDetailTab t) {
    switch (t) {
      case FootballTeamDetailTab.detail:
        return const TableTeamDetailScreen();
      case FootballTeamDetailTab.nextMatches:
        return const TableTeamDetailMatchesScreen();
      case FootballTeamDetailTab.pastMatches:
        return const TableTeamDetailMatchesScreen();
      case FootballTeamDetailTab.mutualMatches:
        return const TableTeamMutualMatchesScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(screenControllerProvider).tableTeamApiModel.id!;
    final state = ref.watch(footballTableTeamDetailNotifierProvider(teamId));
    final notifier = ref.read(footballTableTeamDetailNotifierProvider(teamId).notifier);

    _syncTabController(state.tabs, state.activeTab);

    final controller = _tabController;
    if (controller == null || state.tabs.isEmpty) {
      return const Loader();
    }

    return LoadingOverlay(
      state: state,
      onClearError: () => {},
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 0,
          bottom: TabBar(
            controller: controller,
            labelColor: blackColor,
            indicatorColor: orangeColor,
            tabs: state.tabs.map(_tabLabel).toList(),
            onTap: notifier.changeTabByIndex,
          ),
        ),
        body: TabBarView(
          controller: controller,
          children: state.tabs.map(_screenFor).toList(),
        ),
      ),
    );
  }
}
