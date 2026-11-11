import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/match/controller/edit/match_edit_notifier.dart';
import 'package:trus_app/models/enum/match_detail_options.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/common/widgets/football/team_logo.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/match/match_notifier_args.dart';
import 'package:trus_app/features/match_participation/screens/match_participation_screen.dart';

import '../../main/controller/screen_variables_notifier.dart';
import 'edit_match_screen.dart';
import 'football_mutual_matches_screen.dart';
import 'match_stats_screen.dart';

class MatchScoreAppBarTitle extends ConsumerWidget {
  const MatchScoreAppBarTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ref.watch(matchNotifierArgsProvider);
    final match =
        ref.watch(matchEditNotifierProvider(args)).footballMatch ??
        args.footballMatchApiModel;
    if (match == null) return const Text('Detail zápasu');
    return Row(
      children: [
        TeamLogo(url: match.homeTeam?.logoUrl, size: 26),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            match.homeTeam?.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            match.homeGoalNumber == null || match.awayGoalNumber == null
                ? '–'
                : '${match.homeGoalNumber}:${match.awayGoalNumber}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: Text(
            match.awayTeam?.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        const SizedBox(width: 4),
        TeamLogo(url: match.awayTeam?.logoUrl, size: 26),
      ],
    );
  }
}

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
  List<MatchDetailOptions> _currentOptions = const [];

  static const List<MatchDetailOptions> _order = [
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
        _tabController == null ||
        _tabController!.length != length ||
        !_sameOptions(_currentOptions, orderedOptions);

    if (needsRecreate) {
      _tabController?.dispose();
      _tabController = TabController(
        vsync: this,
        length: length,
        initialIndex: safeInitial,
      );
      _currentOptions = List.of(orderedOptions);
      return;
    }
  }

  bool _sameOptions(List<MatchDetailOptions> a, List<MatchDetailOptions> b) =>
      a.length == b.length &&
      List.generate(a.length, (i) => a[i] == b[i]).every((same) => same);

  List<MatchDetailOptions> _orderedOptions(List<MatchDetailOptions> raw) {
    final set = raw.toSet();
    return _order.where(set.contains).toList();
  }

  Tab _tabLabel(MatchDetailOptions o) {
    switch (o) {
      case MatchDetailOptions.editMatch:
        return _fittedTab("Upravit");
      case MatchDetailOptions.footballMatchDetail:
        return _fittedTab("Sestava");
      case MatchDetailOptions.matchStats:
        return _fittedTab("Statistiky");
      case MatchDetailOptions.mutualMatches:
        return _fittedTab("H2H");
    }
  }

  Tab _fittedTab(String text) => Tab(text: text);

  Widget _screenFor(MatchDetailOptions o, int? footballMatchId) {
    switch (o) {
      case MatchDetailOptions.editMatch:
        return const EditMatchScreen();

      case MatchDetailOptions.footballMatchDetail:
        return MatchParticipationScreen(matchId: footballMatchId);

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
    if (args.preferredScreen == MatchDetailOptions.editMatch) {
      return const EditMatchScreen();
    }

    final fm = state.footballMatch ?? args.footballMatchApiModel;

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
      body: Column(
        children: [
          if (options.length > 1)
            Padding(
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
          Expanded(
            child: TabBarView(
              controller: controller,
              children: options.map((option) {
                if (option != MatchDetailOptions.footballMatchDetail) {
                  return _screenFor(option, fm?.id);
                }
                return Column(
                  children: [
                    if (fm != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${fm.round}. kolo · ${fm.league.name} · ${matchDateToString(fm.date, includeTime: true)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ),
                                if (fm.alreadyPlayed &&
                                    fm.findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(
                                          ref
                                              .read(
                                                globalVariablesControllerProvider,
                                              )
                                              .appTeam,
                                        ) !=
                                        null)
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    tooltip: 'Upravit zápas',
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 19,
                                    ),
                                    onPressed: () {
                                      final team = ref
                                          .read(
                                            globalVariablesControllerProvider,
                                          )
                                          .appTeam;
                                      final matchId = fm
                                          .findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(
                                            team,
                                          );
                                      if (matchId == null) return;
                                      ref
                                          .read(
                                            screenVariablesNotifierProvider
                                                .notifier,
                                          )
                                          .setMatchNotifierArgs(
                                            MatchNotifierArgs.edit(matchId),
                                          );
                                      ref
                                          .read(screenNotifierProvider.notifier)
                                          .changeByFragmentId(
                                            MatchDetailScreen.id,
                                          );
                                    },
                                  ),
                              ],
                            ),
                            Text(
                              '${fm.stadium ?? "–"} · Rozhodčí: ${fm.referee?.trim().isNotEmpty == true ? fm.referee!.trim() : "neznámý"}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    if (state.footballMatchDetailState.refereeComment
                        .trim()
                        .isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Text(
                          state.footballMatchDetailState.refereeComment,
                        ),
                      ),
                    Expanded(child: _screenFor(option, fm?.id)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
