import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/repository/planned_match_api_service.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/match/match_notifier_args.dart';
import 'package:trus_app/features/match/post_match_flow.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/features/match/screens/match_detail_screen.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/match/planned_match.dart';
import 'package:trus_app/theme/app_colors.dart';

/// Score entry for one match. With [live] it also shows the running clock
/// and lets the editor finish the match, which continues to lineup confirmation.
class MatchScoreBar extends ConsumerStatefulWidget {
  final int matchId;
  final PlannedMatch? live;

  const MatchScoreBar({super.key, required this.matchId, this.live});

  @override
  ConsumerState<MatchScoreBar> createState() => _MatchScoreBarState();
}

class _MatchScoreBarState extends ConsumerState<MatchScoreBar> {
  MatchApiModel? _match;
  Timer? _ticker;
  Future<void> _saving = Future.value();
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.live != null) {
      _ticker = Timer.periodic(
        const Duration(seconds: 1),
        (_) => mounted ? setState(() {}) : null,
      );
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final match =
        (await ref
                .read(matchRepositoryProvider)
                .fetchMatchSetup(widget.matchId))
            .match;
    if (!mounted || match == null) return;
    setState(() => _match = match);
    ref.read(matchScoreProvider(widget.matchId).notifier).state = (
      match.homeGoalNumber,
      match.awayGoalNumber,
    );
    // A live match starts at 0:0 so goals can be added right away.
    if (widget.live != null &&
        missingMatchResult(match.homeGoalNumber, match.awayGoalNumber)) {
      _change(true, 0);
    }
  }

  void _change(bool homeSide, int delta) {
    final scoreNotifier = ref.read(matchScoreProvider(widget.matchId).notifier);
    final previous = scoreNotifier.state;
    final home = previous?.$1 ?? 0;
    final away = previous?.$2 ?? 0;
    final next = homeSide ? (home + delta, away) : (home, away + delta);
    if (next.$1 < 0 || next.$2 < 0) return;
    scoreNotifier.state = next;
    final repository = ref.read(matchRepositoryProvider);
    // Requests are chained so the server always ends with the latest score.
    _saving = _saving.then((_) async {
      try {
        await repository.api.updateMatchScore(widget.matchId, next.$1, next.$2);
        repository.invalidateMatchDetailData(widget.matchId);
        repository.invalidateList();
      } catch (_) {
        if (!mounted) return;
        scoreNotifier.state = previous;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skóre se nepodařilo uložit.')),
        );
      }
    });
  }

  Future<void> _finish(PlannedMatch live) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ukončit zápas?'),
        content: const Text(
          'Zápas se označí jako odehraný a pokračuješ potvrzením sestavy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zpět'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ukončit'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _finishing = true);
    try {
      await _saving;
      await ref
          .read(plannedMatchApiProvider)
          .changeStatus(live.id, 'COMPLETED');
    } catch (_) {
      if (!mounted) return;
      setState(() => _finishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zápas se nepodařilo ukončit.')),
      );
      return;
    }
    if (!mounted) return;
    openLineupConfirmation(ref.read, widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final match = _match;
    final live = widget.live;
    final score = ref.watch(matchScoreProvider(widget.matchId));
    final ourName =
        ref.read(globalVariablesControllerProvider).appTeam?.name ?? 'My';
    final opponent = match?.name ?? '';
    final home = match?.home ?? true;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          children: [
            if (live != null)
              Row(
                children: [
                  Icon(Icons.circle, size: 10, color: colors.errorSolid),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      livePhaseLabel(live, DateTime.now()),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _finishing ? null : () => _finish(live),
                    icon: const Icon(Icons.sports_score_outlined),
                    label: const Text('Ukončit zápas'),
                  ),
                ],
              ),
            if (match == null)
              const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _side(home ? ourName : opponent, score?.$1, true),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _side(home ? opponent : ourName, score?.$2, false),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _side(String name, int? goals, bool homeSide) => Column(
    children: [
      Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            key: ValueKey('score-${homeSide ? 'home' : 'away'}-minus'),
            onPressed: (goals ?? 0) > 0 ? () => _change(homeSide, -1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          InkWell(
            // An empty score is confirmed as 0 by tapping it (e.g. a 0:0 draw).
            onTap: goals == null ? () => _change(homeSide, 0) : null,
            child: Text(
              goals?.toString() ?? '–',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            key: ValueKey('score-${homeSide ? 'home' : 'away'}-plus'),
            onPressed: () => _change(homeSide, 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    ],
  );
}

/// `ref.read` of either a widget or a notifier.
typedef ProviderRead = T Function<T>(ProviderListenable<T> provider);

/// Continues a finished match with lineup confirmation, then score and goals.
void openLineupConfirmation(ProviderRead read, int matchId) {
  read(liveMatchProvider.notifier).state = null;
  read(postMatchFlowProvider.notifier).state = matchId;
  read(
    screenVariablesNotifierProvider.notifier,
  ).setMatchNotifierArgs(MatchNotifierArgs.edit(matchId));
  read(
    screenNotifierProvider.notifier,
  ).changeByFragmentId(MatchDetailScreen.id);
}

/// Opens the screen that fits the planned match's state; returns false when
/// the match has no recorded match yet (scheduled or cancelled).
bool openPlannedMatchByStatus(ProviderRead read, PlannedMatch planned) {
  final matchId = planned.matchId;
  if (matchId == null || planned.isScheduled || planned.isCancelled) {
    return false;
  }
  if (planned.isInProgress && planned.hasScore) {
    read(liveMatchProvider.notifier).state = planned;
    read(screenVariablesNotifierProvider.notifier).setMatchId(matchId);
    read(screenNotifierProvider.notifier).changeByFragmentId(GoalScreen.id);
    return true;
  }
  read(screenVariablesNotifierProvider.notifier).setMatchNotifierArgs(
    MatchNotifierArgs.footballMatchDetailByMatchId(matchId),
  );
  read(
    screenNotifierProvider.notifier,
  ).changeByFragmentId(MatchDetailScreen.id);
  return true;
}

/// After a manual state change: played → lineup confirmation, started → live screen.
bool navigateAfterStatusChange(ProviderRead read, PlannedMatch result) {
  if (result.isCompleted && result.matchId != null) {
    openLineupConfirmation(read, result.matchId!);
    return true;
  }
  return result.isInProgress && openPlannedMatchByStatus(read, result);
}
