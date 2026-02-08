import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/notifier/loader/loading_overlay.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/match/controller/edit/match_edit_notifier.dart';
import 'package:trus_app/models/enum/match_detail_options.dart';

import '../../main/screen_controller.dart';
import 'edit_match_screen.dart';
import 'football_match_detail_away_screen.dart';
import 'football_match_detail_home_screen.dart';
import 'football_match_detail_screen.dart';
import 'football_mutual_matches_screen.dart';

class MatchDetailScreen extends CustomConsumerStatefulWidget {
  static const String id = "match-detail-screen";

  const MatchDetailScreen({Key? key})
      : super(key: key, title: "Detail zápasu", name: id);

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  // pevné pořadí tabů
  static const List<MatchDetailOptions> _order = [
    MatchDetailOptions.editMatch,
    MatchDetailOptions.footballMatchDetail,
    MatchDetailOptions.homeMatchDetail,
    MatchDetailOptions.awayMatchDetail,
    MatchDetailOptions.mutualMatches,
  ];

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _syncTabController({
    required List<MatchDetailOptions> orderedOptions,
    required MatchDetailOptions preferredInitial,
  }) {
    final length = orderedOptions.length;
    if (length == 0) return;

    final initialIndex = orderedOptions.indexOf(preferredInitial);
    final safeInitial = initialIndex >= 0 ? initialIndex : 0;

    final needsRecreate = _tabController == null || _tabController!.length != length;

    if (needsRecreate) {
      _tabController?.dispose();
      _tabController = TabController(
        vsync: this,
        length: length,
        initialIndex: safeInitial,
      );
      return;
    }

    // length sedí, jen případně přepni index (bez recreate)
    if (_tabController!.index != safeInitial) {
      _tabController!.index = safeInitial;
    }
  }

  List<MatchDetailOptions> _orderedOptions(List<MatchDetailOptions> raw) {
    // raw může být v libovolném pořadí → přeuspořádej do _order
    final set = raw.toSet();
    return _order.where(set.contains).toList();
  }

  Tab _tabLabel(MatchDetailOptions o) {
    switch (o) {
      case MatchDetailOptions.editMatch:
        return _fittedTab("Upravit");
      case MatchDetailOptions.footballMatchDetail:
        return _fittedTab("Detail");
      case MatchDetailOptions.homeMatchDetail:
        return _fittedTab("Domácí");
      case MatchDetailOptions.awayMatchDetail:
        return  _fittedTab("Hosté");
      case MatchDetailOptions.mutualMatches:
        return _fittedTab("H2H");
    }
  }

  Tab _fittedTab(String text) {
    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _screenFor(MatchDetailOptions o) {
    switch (o) {
      case MatchDetailOptions.editMatch:
        return const EditMatchScreen();
      case MatchDetailOptions.footballMatchDetail:
        return const FootballMatchDetailScreen();
      case MatchDetailOptions.homeMatchDetail:
        return const FootballMatchDetailHomeScreen();
      case MatchDetailOptions.awayMatchDetail:
        return const FootballMatchDetailAwayScreen();
      case MatchDetailOptions.mutualMatches:
        return const FootballMutualMatchesScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ref.watch(matchNotifierArgsProvider);
    final state = ref.watch(matchEditNotifierProvider(args));

    // když se načítá a ještě nemáš taby → loader
    /*if (state.loading.isLoading && state.matchOptions.isEmpty) {
      return const Loader();
    }*/

    final options = _orderedOptions(state.matchOptions);
    _syncTabController(
      orderedOptions: options,
      preferredInitial: state.initialTab,
    );

    final controller = _tabController;
    if (controller == null || options.isEmpty) {
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
            tabs: options.map(_tabLabel).toList(),
          ),
        ),
        body: TabBarView(
          controller: controller,
          children: options.map(_screenFor).toList(),
        ),
      ),
    );
  }
}
