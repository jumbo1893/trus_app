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
import 'package:trus_app/features/match/post_match_flow.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/features/match_participation/screens/match_participation_screen.dart';
import 'package:trus_app/features/football/screens/planned_match_sheet.dart';
import 'package:trus_app/features/match_participation/widgets/participation_pitch.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/features/match/state/footbal_match_detail_state.dart';

import '../../main/controller/screen_variables_notifier.dart';
import 'edit_match_screen.dart';
import 'football_mutual_matches_screen.dart';
import 'match_stats_screen.dart';

final _lineupTabActiveProvider = StateProvider.autoDispose<bool>((ref) => true);
final matchEditReturnArgsProvider = StateProvider<MatchNotifierArgs?>(
  (ref) => null,
);
final _openMatchDetailProvider =
    StateProvider.autoDispose<void Function(BuildContext)?>((ref) => null);
final postMatchResultProvider = FutureProvider.autoDispose.family<bool, int>((
  ref,
  matchId,
) async {
  final match =
      (await ref.read(matchRepositoryProvider).fetchMatchSetup(matchId)).match;
  return match != null &&
      missingMatchResult(match.homeGoalNumber, match.awayGoalNumber);
});

Future<void> _openPlannedMatchSheet(
  BuildContext context,
  int footballMatchId,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: context.appColors.backgroundPrimary,
  builder: (_) => PlannedMatchSheet(
    footballMatchId: footballMatchId,
    showParticipationButton: false,
    showPlannedMatchTab: false,
  ),
);

class MatchScoreAppBarTitle extends ConsumerWidget {
  const MatchScoreAppBarTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(_lineupTabActiveProvider)
        ? ref.watch(lineupHeaderProgressProvider)
        : 1.0;
    final args = ref.watch(matchNotifierArgsProvider);
    final match =
        ref.watch(matchEditNotifierProvider(args)).footballMatch ??
        args.footballMatchApiModel;
    if (match == null) return const SizedBox.shrink();
    final openDetail = ref.watch(_openMatchDetailProvider);
    return Opacity(
      opacity: match.alreadyPlayed ? progress : 1.0,
      child: Transform.translate(
        offset: Offset(0, 8 * (1 - progress)),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: args.showParticipationMatchLink && match.id != null
              ? () => _openPlannedMatchSheet(context, match.id!)
              : openDetail == null
              ? null
              : () => openDetail(context),
          child: _compactScore(context, match, args.plannedDescription),
        ),
      ),
    );
  }

  Widget _compactScore(
    BuildContext context,
    FootballMatchApiModel match,
    String? plannedDescription,
  ) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        key: const ValueKey('compact-lineup-score'),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  match.homeGoalNumber == null || match.awayGoalNumber == null
                      ? '–'
                      : '${match.homeGoalNumber}:${match.awayGoalNumber}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
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
      ),
      if (plannedDescription?.trim().isNotEmpty == true)
        Text(
          plannedDescription!.trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
    ],
  );
}

class MatchDetailScreen extends CustomConsumerStatefulWidget {
  static const String id = "match-detail-screen";

  const MatchDetailScreen({Key? key})
    : super(key: key, title: "Detail zápasu", name: id);

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  Widget _screenFor(
    MatchDetailOptions o,
    FootballMatchApiModel? footballMatch,
    String comment,
  ) {
    switch (o) {
      case MatchDetailOptions.editMatch:
        return const EditMatchScreen();

      case MatchDetailOptions.footballMatchDetail:
        if (footballMatch == null) {
          final matchId = ref.read(matchNotifierArgsProvider).matchId;
          if (matchId != null) {
            return PlayedMatchPitch(
              matchId: matchId,
              comment: comment,
              onEditMatch: () => _editMatch(matchId),
            );
          }
        }
        if (footballMatch?.alreadyPlayed == true) {
          final team = ref.read(globalVariablesControllerProvider).appTeam;
          final matchId = footballMatch!
              .findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(team);
          if (matchId != null) {
            return PlayedMatchPitch(
              matchId: matchId,
              comment: comment,
              onEditMatch: () => _editMatch(matchId),
              onOpenMatchDetail: () {
                final args = ref.read(matchNotifierArgsProvider);
                final current = ref.read(matchEditNotifierProvider(args));
                _showOptions(
                  context,
                  current.footballMatch ?? args.footballMatchApiModel,
                  current.matchOptions,
                );
              },
            );
          }
          return const Center(
            child: Text('Sestava pro tento zápas není zapsaná.'),
          );
        }
        return MatchParticipationScreen(matchId: footballMatch?.id);

      case MatchDetailOptions.matchStats:
        return const MatchStatsScreen();

      case MatchDetailOptions.mutualMatches:
        return const FootballMutualMatchesScreen();
    }
  }

  void _editMatch(int matchId) {
    ref.read(matchEditReturnArgsProvider.notifier).state = ref.read(
      matchNotifierArgsProvider,
    );
    ref
        .read(screenVariablesNotifierProvider.notifier)
        .setMatchNotifierArgs(MatchNotifierArgs.edit(matchId));
    ref
        .read(screenNotifierProvider.notifier)
        .changeByFragmentId(MatchDetailScreen.id);
  }

  Future<void> _showOptions(
    BuildContext context,
    FootballMatchApiModel? match,
    List<MatchDetailOptions> options,
  ) async {
    final team = ref.read(globalVariablesControllerProvider).appTeam;
    final matchId = match
        ?.findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(team);
    final choice = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.appColors.cardBackground,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Detail zápasu',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (options.contains(MatchDetailOptions.matchStats)) ...[
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Statistiky domácích'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(sheetContext, 'home'),
              ),
              ListTile(
                leading: const Icon(Icons.flight_outlined),
                title: const Text('Statistiky hostů'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(sheetContext, 'away'),
              ),
            ],
            if (options.contains(MatchDetailOptions.mutualMatches))
              ListTile(
                leading: const Icon(Icons.compare_arrows),
                title: const Text('H2H · vzájemné zápasy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(sheetContext, 'h2h'),
              ),
            if (matchId != null)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Upravit zápas'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(sheetContext, 'edit'),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (!mounted || !context.mounted) return;
    if (choice == 'edit' && matchId != null) {
      _editMatch(matchId);
    } else if (choice != null) {
      _showDetailSheet(context, choice);
    }
  }

  void _showDetailSheet(BuildContext context, String choice) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.appColors.cardBackground,
      builder: (sheetContext) {
        final args = ref.read(matchNotifierArgsProvider);
        final detail = ref
            .read(matchEditNotifierProvider(args))
            .footballMatchDetailState;
        final isHome = choice == 'home';
        final title = choice == 'h2h'
            ? 'Vzájemné zápasy'
            : isHome
            ? 'Statistiky domácích'
            : 'Statistiky hostů';
        return SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.82,
          child: Column(
            children: [
              Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 12),
              Expanded(
                child: choice == 'h2h'
                    ? const FootballMutualMatchesScreen()
                    : _teamStatistics(sheetContext, detail, isHome),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _teamStatistics(
    BuildContext context,
    FootballMatchDetailState detail,
    bool home,
  ) {
    final entries = <(String, String)>[
      ('Hvězda zápasu', home ? detail.homeBestPlayer : detail.awayBestPlayer),
      ('Střelci', home ? detail.homeGoalScorers : detail.awayGoalScorers),
      ('Vlastní góly', home ? detail.homeOwnGoals : detail.awayOwnGoals),
      ('Žluté karty', home ? detail.homeYellowCards : detail.awayYellowCards),
      ('Červené karty', home ? detail.homeRedCards : detail.awayRedCards),
    ].where((entry) => entry.$2.trim().isNotEmpty).toList();
    if (entries.isEmpty) {
      return const Center(child: Text('Statistiky zatím nejsou zapsané.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) => ListTile(
        title: Text(entries[index].$1),
        subtitle: Text(entries[index].$2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final args = ref.watch(matchNotifierArgsProvider);
    final state = ref.watch(matchEditNotifierProvider(args));

    if (args.preferredScreen == MatchDetailOptions.editMatch) {
      return const EditMatchScreen();
    }

    final fm = state.footballMatch ?? args.footballMatchApiModel;
    final matchId =
        args.matchId ??
        fm?.findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(
          ref.read(globalVariablesControllerProvider).appTeam,
        );
    if (matchId != null &&
        (fm?.alreadyPlayed == true ||
            (fm == null &&
                state.model != null &&
                state.model!.date.isBefore(DateTime.now())))) {
      final missing = ref.watch(postMatchResultProvider(matchId));
      if (missing.isLoading) return const Loader();
      if (missing.hasError) {
        return const Center(child: Text('Výsledek se nepodařilo načíst.'));
      }
      if (missing.asData?.value == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || ref.read(matchNotifierArgsProvider) != args) return;
          ref.read(postMatchFlowProvider.notifier).state = matchId;
          ref
              .read(screenVariablesNotifierProvider.notifier)
              .setMatchNotifierArgs(MatchNotifierArgs.edit(matchId));
        });
        return const Loader();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(_openMatchDetailProvider.notifier).state = (tapContext) {
        final current = ref.read(matchEditNotifierProvider(args));
        _showOptions(
          tapContext,
          current.footballMatch ?? args.footballMatchApiModel,
          current.matchOptions,
        );
      };
    });

    if (state.matchOptions.isEmpty) {
      return const Loader();
    }
    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                const option = MatchDetailOptions.footballMatchDetail;
                return Column(
                  children: [
                    if (fm != null && fm.alreadyPlayed != true)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap:
                                        args.showParticipationMatchLink &&
                                            fm.id != null
                                        ? () => _openPlannedMatchSheet(
                                            context,
                                            fm.id!,
                                          )
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${fm.round}. kolo · ${fm.league.name} · ${matchDateToString(fm.date, includeTime: true)}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.labelMedium,
                                                ),
                                                if (args.plannedDescription
                                                        ?.trim()
                                                        .isNotEmpty ==
                                                    true)
                                                  Text(
                                                    args.plannedDescription!
                                                        .trim(),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: colors
                                                              .textSecondary,
                                                        ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (args.showParticipationMatchLink &&
                                              fm.id != null)
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              color: colors.accent,
                                              size: 25,
                                            ),
                                        ],
                                      ),
                                    ),
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
                    if ((option != MatchDetailOptions.footballMatchDetail ||
                            fm?.alreadyPlayed != true) &&
                        state.footballMatchDetailState.refereeComment
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
                    Expanded(
                      child: _screenFor(
                        option,
                        fm,
                        state.footballMatchDetailState.refereeComment,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
