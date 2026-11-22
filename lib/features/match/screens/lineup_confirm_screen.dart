import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/match_context_header.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/match/post_match_flow.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/features/match/widget/match_score_bar.dart';
import 'package:trus_app/features/match_participation/widgets/participation_pitch.dart';
import 'package:trus_app/models/api/match/match_setup.dart';

final _lineupSetupProvider = FutureProvider.autoDispose.family<MatchSetup, int>(
  (ref, matchId) => ref.read(matchRepositoryProvider).fetchMatchSetup(matchId),
);

/// First step after a match: confirm players and fans (pre-filled from
/// attendance) and the score. Everything else comes from the planned match.
class LineupConfirmScreen extends ConsumerWidget {
  final int matchId;

  const LineupConfirmScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(_lineupSetupProvider(matchId))
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Sestavu se nepodařilo načíst.')),
        data: (setup) {
          final match = setup.match;
          if (match == null) {
            return const Center(child: Text('Zápas nebyl nalezen.'));
          }
          final hasScore = !scorelessMatchType(match.type);
          final score = ref.watch(matchScoreProvider(matchId));
          final scoreMissing =
              hasScore &&
              (score == null || missingMatchResult(score.$1, score.$2));
          return Column(
            children: [
              MatchContextHeader(match: match),
              if (hasScore) MatchScoreBar(matchId: matchId),
              const SizedBox(height: 12),
              Expanded(
                child: MatchRosterPicker(
                  matchId: matchId,
                  setup: setup,
                  title: 'Potvrdit sestavu',
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check_rounded),
                      label: Text(
                        scoreMissing
                            ? 'Nejdřív zapiš skóre'
                            : 'Potvrdit a zapsat góly',
                      ),
                      onPressed: scoreMissing
                          ? null
                          : () async {
                              final repository = ref.read(
                                matchRepositoryProvider,
                              );
                              repository.invalidateMatchSetup(matchId);
                              final saved =
                                  (await repository.fetchMatchSetup(
                                    matchId,
                                  )).match ??
                                  match;
                              final variables = ref.read(
                                screenVariablesNotifierProvider.notifier,
                              );
                              variables.setMatch(saved);
                              variables.setMatchId(matchId);
                              ref
                                  .read(screenNotifierProvider.notifier)
                                  .changeByFragmentId(GoalScreen.id);
                            },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
}
