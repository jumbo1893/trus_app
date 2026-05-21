import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/match/controller/edit/match_edit_notifier.dart';
import 'package:trus_app/models/enum/match_detail_options.dart';
import 'package:trus_app/theme/app_colors.dart';

import '../../main/controller/screen_variables_notifier.dart';
import 'edit_match_screen.dart';
import 'football_match_detail_screen.dart';
import 'football_mutual_matches_screen.dart';
import 'match_stats_screen.dart';

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

  static const List<MatchDetailOptions> _order = [
    MatchDetailOptions.editMatch,
    MatchDetailOptions.footballMatchDetail,
    MatchDetailOptions.matchStats,
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

    final needsRecreate =
        _tabController == null || _tabController!.length != length;

    if (needsRecreate) {
      _tabController?.dispose();
      _tabController = TabController(
        vsync: this,
        length: length,
        initialIndex: safeInitial,
      );
      return;
    }

    if (_tabController!.index != safeInitial) {
      _tabController!.index = safeInitial;
    }
  }

  List<MatchDetailOptions> _orderedOptions(List<MatchDetailOptions> raw) {
    final set = raw.toSet();
    return _order.where(set.contains).toList();
  }

  Tab _tabLabel(MatchDetailOptions o) {
    switch (o) {
      case MatchDetailOptions.editMatch:
        return _fittedTab("Upravit");
      case MatchDetailOptions.footballMatchDetail:
        return _fittedTab("Detail");
      case MatchDetailOptions.matchStats:
        return _fittedTab("Statistiky");
      case MatchDetailOptions.mutualMatches:
        return _fittedTab("H2H");
    }
  }

  Tab _fittedTab(String text) => Tab(text: text);

  Widget _screenFor(MatchDetailOptions o) {
    switch (o) {
      case MatchDetailOptions.editMatch:
        return const EditMatchScreen();

      case MatchDetailOptions.footballMatchDetail:
        return const FootballMatchDetailScreen();

      case MatchDetailOptions.matchStats:
        return const MatchStatsScreen();

      case MatchDetailOptions.mutualMatches:
        return const FootballMutualMatchesScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final args = ref.watch(matchNotifierArgsProvider);
    final state = ref.watch(matchEditNotifierProvider(args));

    final options = _orderedOptions(state.matchOptions);

    _syncTabController(
      orderedOptions: options,
      preferredInitial: state.initialTab,
    );

    final controller = _tabController;
    if (controller == null || options.isEmpty) {
      return const Loader();
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: colors.backgroundPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: controller,
                  isScrollable: false,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.zero,
                  indicatorPadding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: colors.textPrimary,
                  unselectedLabelColor: colors.textMuted,
                  tabs: options.map(_tabLabel).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: options.map(_screenFor).toList(),
      ),
    );
  }
}