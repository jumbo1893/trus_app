import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/features/match/controller/edit/match_edit_notifier.dart';
import 'package:trus_app/features/goal/repository/goal_api_service.dart';
import 'package:trus_app/models/api/match/match_setup.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/match/match_stats.dart';
import 'package:trus_app/models/api/beer/beer_detailed_model.dart';
import 'package:trus_app/models/api/goal/goal_detailed_model.dart';
import 'package:trus_app/models/api/goal/goal_setup.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_detailed_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/features/user/widgets/user_avatar.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/player/screens/view_player_screen.dart';
import 'package:trus_app/common/widgets/football/team_logo.dart';
import 'package:trus_app/common/utils/calendar.dart';

final lineupHeaderProgressProvider = StateProvider.autoDispose<double>(
  (ref) => 0,
);

final _playedMatchSetupProvider = FutureProvider.autoDispose
    .family<
      ({MatchSetup setup, MatchStats? stats, List<GoalSetup> goalSetups}),
      int
    >((ref, matchId) async {
      final repository = ref.read(matchRepositoryProvider);
      final setup = await repository.fetchMatchSetup(matchId);
      MatchStats? stats;
      List<GoalSetup> goalSetups = [];
      try {
        stats = await repository.fetchMatchStats(matchId);
      } catch (_) {
        // The lineup is still useful if the optional statistics fail to load.
      }
      try {
        // This is the same source used by the Goals screen for minutes in goal.
        goalSetups = await ref.read(goalApiServiceProvider).setupGoal(matchId);
      } catch (_) {
        // Keep the lineup visible when the optional goal setup is unavailable.
      }
      return (setup: setup, stats: stats, goalSetups: goalSetups);
    });

/// Actual match roster, taken from the saved match rather than RSVP responses.
class PlayedMatchPitch extends ConsumerStatefulWidget {
  final int matchId;
  final String comment;
  final VoidCallback? onEditMatch;
  final VoidCallback? onOpenMatchDetail;
  const PlayedMatchPitch({
    super.key,
    required this.matchId,
    this.comment = '',
    this.onEditMatch,
    this.onOpenMatchDetail,
  });

  @override
  ConsumerState<PlayedMatchPitch> createState() => _PlayedMatchPitchState();
}

class _PlayedMatchPitchState extends ConsumerState<PlayedMatchPitch> {
  final ScrollController _scrollController = ScrollController();
  bool _showList = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateHeader);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(lineupHeaderProgressProvider.notifier).state = 0;
      }
    });
  }

  void _updateHeader() {
    final progress = (_scrollController.offset / 155).clamp(0.0, 1.0);
    final notifier = ref.read(lineupHeaderProgressProvider.notifier);
    if ((notifier.state - progress).abs() > .005) notifier.state = progress;
  }

  @override
  void didUpdateWidget(covariant PlayedMatchPitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.matchId != widget.matchId) {
      _showList = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_scrollController.hasClients) _scrollController.jumpTo(0);
        ref.read(lineupHeaderProgressProvider.notifier).state = 0;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showPeopleSheet(MatchSetup setup) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.appColors.cardBackground,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * .8,
        child: _MatchRosterPicker(matchId: widget.matchId, setup: setup),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ref
      .watch(_playedMatchSetupProvider(widget.matchId))
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Sestavu se nepodařilo načíst.')),
        data: (data) {
          final setup = data.setup;
          final present = setup.match?.playerIdList.toSet() ?? <int>{};
          final players = setup.playerList
              .where((p) => present.contains(p.id))
              .toList();
          final fans = setup.fanList
              .where((p) => present.contains(p.id))
              .toList();
          final playerStats = <int, _PlayerStats>{};
          data.stats?.playerRatings.forEach((id, rating) {
            playerStats.putIfAbsent(id, _PlayerStats.new).rating = rating;
          });
          data.stats?.playerAchievements.forEach((id, names) {
            playerStats
                .putIfAbsent(id, _PlayerStats.new)
                .achievements
                .addAll(names);
          });
          for (final goal
              in data.stats?.goals.goalList ?? <GoalDetailedModel>[]) {
            final id = goal.player?.id;
            if (id == null) continue;
            final current = playerStats.putIfAbsent(id, _PlayerStats.new);
            current.goals += goal.goalNumber;
            current.assists += goal.assistNumber;
          }
          for (final beer
              in data.stats?.beers.beerList ?? <BeerDetailedModel>[]) {
            final id = beer.player?.id;
            if (id == null) continue;
            final current = playerStats.putIfAbsent(id, _PlayerStats.new);
            current.beers += beer.beerNumber;
            current.liquors += beer.liquorNumber;
          }
          for (final fine
              in data.stats?.fines.fineList ?? <ReceivedFineDetailedModel>[]) {
            final id = fine.player?.id;
            if (id == null) continue;
            final current = playerStats.putIfAbsent(id, _PlayerStats.new);
            if (fine.fineNumber <= 0 || fine.fine == null) continue;
            if (fine.fineAmount > 0) current.fineAmount += fine.fineAmount;
            current.fines.add(fine);
            switch (fine.fine?.code) {
              case 'YELLOW_CARD':
                current.yellowCards += fine.fineNumber;
              case 'RED_CARD':
                current.redCards += fine.fineNumber;
            }
          }
          final footballMatch =
              setup.footballMatch ?? setup.match?.footballMatch;
          final footballIds = {
            for (final player in players)
              if (player.footballPlayer?.id != null)
                player.footballPlayer!.id!: player.id!,
          };
          final goalkeepers = <int>{};
          int? goalkeeperId;
          var goalkeeperMinutes = 0;
          for (final result in [
            ...?footballMatch?.homePlayerList,
            ...?footballMatch?.awayPlayerList,
          ]) {
            final id = footballIds[result.player.id];
            if (id == null) continue;
            final current = playerStats.putIfAbsent(id, _PlayerStats.new);
            current.bestPlayer |= result.bestPlayer;
          }
          for (final goal in data.goalSetups) {
            final id = goal.player.id;
            if (id == null ||
                !present.contains(id) ||
                goal.goalkeepingMinutes <= 0) {
              continue;
            }
            goalkeepers.add(id);
            if (goal.goalkeepingMinutes > goalkeeperMinutes) {
              goalkeeperMinutes = goal.goalkeepingMinutes;
              goalkeeperId = id;
            }
          }
          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            children: [
              if (footballMatch != null)
                Consumer(
                  builder: (context, ref, _) => Opacity(
                    opacity: 1 - ref.watch(lineupHeaderProgressProvider),
                    child: Column(
                      children: [
                        _LineupScoreHeader(
                          match: footballMatch,
                          onTap: widget.onOpenMatchDetail,
                        ),
                        _LineupMatchDetails(
                          match: footballMatch,
                          onEditMatch: widget.onEditMatch,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Center(
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.list),
                      label: Text('Seznam'),
                    ),
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.grid_on),
                      label: Text('Hřiště'),
                    ),
                  ],
                  selected: {_showList},
                  onSelectionChanged: (selection) =>
                      setState(() => _showList = selection.first),
                ),
              ),
              const SizedBox(height: 12),
              _LineupField(
                matchId: widget.matchId,
                players: players,
                fans: fans,
                playerStats: playerStats,
                match: setup.match,
                teamLogoUrl: setup.match?.home == true
                    ? footballMatch?.homeTeam?.logoUrl
                    : footballMatch?.awayTeam?.logoUrl,
                goalkeeperId: goalkeeperId,
                goalkeeperIds: goalkeepers,
                listView: _showList,
                onAddPeople: setup.match == null
                    ? null
                    : () => _showPeopleSheet(setup),
              ),
              _RefereeProfile(
                stats: data.stats?.refereeStats,
                name: footballMatch?.referee,
                comment: widget.comment,
                listView: _showList,
              ),
            ],
          );
        },
      );
}

class _MatchRosterPicker extends ConsumerStatefulWidget {
  final int matchId;
  final MatchSetup setup;

  const _MatchRosterPicker({required this.matchId, required this.setup});

  @override
  ConsumerState<_MatchRosterPicker> createState() => _MatchRosterPickerState();
}

class _MatchRosterPickerState extends ConsumerState<_MatchRosterPicker> {
  late final Set<int> _selectedIds = widget.setup.match!.playerIdList.toSet();
  int? _savingId;
  bool _showInactivePlayers = false;
  bool _showInactiveFans = false;
  Map<int, int>? _attendancePercentages;

  @override
  void initState() {
    super.initState();
    _loadAttendancePercentages();
  }

  Future<void> _loadAttendancePercentages() async {
    try {
      final values = await ref
          .read(matchRepositoryProvider)
          .api
          .getAttendancePercentages();
      if (mounted) setState(() => _attendancePercentages = values);
    } catch (_) {
      // The picker remains usable if attendance statistics are unavailable.
    }
  }

  Color _attendanceColor(int percentage) {
    if (percentage >= 85) return const Color(0xFF8E44AD);
    if (percentage >= 70) return const Color(0xFF287FC6);
    if (percentage >= 55) return const Color(0xFF3FA73B);
    if (percentage >= 40) return const Color(0xFFF4C542);
    if (percentage >= 25) return const Color(0xFFF28C28);
    if (percentage >= 10) return const Color(0xFFE57373);
    return const Color(0xFF99252C);
  }

  List<PlayerApiModel> _ordered(List<PlayerApiModel> people) =>
      [...people]..sort((a, b) {
        final bySelection = (_selectedIds.contains(b.id) ? 1 : 0).compareTo(
          _selectedIds.contains(a.id) ? 1 : 0,
        );
        return bySelection != 0
            ? bySelection
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

  Future<void> _toggle(PlayerApiModel player) async {
    final id = player.id;
    final match = widget.setup.match;
    if (id == null || match == null || _savingId != null) {
      return;
    }
    final wasSelected = _selectedIds.contains(id);
    final updatedIds = {..._selectedIds};
    if (wasSelected) {
      updatedIds.remove(id);
    } else {
      updatedIds.add(id);
    }
    setState(() => _savingId = id);
    final updated = MatchApiModel(
      id: match.id,
      name: match.name,
      date: match.date,
      seasonId: match.seasonId,
      home: match.home,
      playerIdList: updatedIds.toList(),
      homeGoalNumber: match.homeGoalNumber,
      awayGoalNumber: match.awayGoalNumber,
      footballMatch: match.footballMatch,
      weather: match.weather,
    );
    try {
      final repository = ref.read(matchRepositoryProvider);
      await repository.api.editMatch(updated, widget.matchId);
      repository.invalidateMatchSetup(widget.matchId);
      repository.invalidateMatchStats(widget.matchId);
      if (!mounted) return;
      setState(() {
        _selectedIds
          ..clear()
          ..addAll(updatedIds);
        if (wasSelected && !player.active) {
          if (player.fan) {
            _showInactiveFans = true;
          } else {
            _showInactivePlayers = true;
          }
        }
        _savingId = null;
      });
      ref.invalidate(_playedMatchSetupProvider(widget.matchId));
      ref.invalidate(
        matchEditNotifierProvider(ref.read(matchNotifierArgsProvider)),
      );
      _loadAttendancePercentages();
    } catch (_) {
      if (!mounted) return;
      setState(() => _savingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Účast se nepodařilo změnit.')),
      );
    }
  }

  Widget _group(
    String title,
    List<PlayerApiModel> people, {
    required bool fans,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 4.0;
        final width = (constraints.maxWidth - spacing * 4) / 5;
        final height = width * 100 / 90;
        final showInactive = fans ? _showInactiveFans : _showInactivePlayers;
        final visible = _ordered(people)
            .where(
              (person) =>
                  showInactive ||
                  person.active ||
                  _selectedIds.contains(person.id),
            )
            .toList();
        final showMore =
            showInactive ||
            people.any(
              (person) => !person.active && !_selectedIds.contains(person.id),
            );
        final itemCount = visible.length + (showMore ? 1 : 0);
        final rows = (itemCount + 4) ~/ 5;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: constraints.maxWidth,
                height: rows == 0 ? 0 : rows * height + (rows - 1) * spacing,
                child: Stack(
                  children: [
                    for (var i = 0; i < visible.length; i++)
                      AnimatedPositioned(
                        key: ValueKey('person-${visible[i].id}'),
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                        left: (i % 5) * (width + spacing),
                        top: (i ~/ 5) * (height + spacing),
                        width: width,
                        height: height,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: _personTile(visible[i]),
                        ),
                      ),
                    if (showMore)
                      AnimatedPositioned(
                        key: ValueKey('more-$fans'),
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                        left: (visible.length % 5) * (width + spacing),
                        top: (visible.length ~/ 5) * (height + spacing),
                        width: width,
                        height: height,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: _moreTile(
                            showInactive: showInactive,
                            onTap: () => setState(() {
                              if (fans) {
                                _showInactiveFans = !_showInactiveFans;
                              } else {
                                _showInactivePlayers = !_showInactivePlayers;
                              }
                            }),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  Widget _personTile(PlayerApiModel person) {
    final selected = _selectedIds.contains(person.id);
    final percentage = _attendancePercentages?[person.id] ?? 0;
    final attendanceColor = _attendanceColor(percentage);
    final avatar = person.avatarUserId == null
        ? CircleAvatar(
            radius: 17,
            backgroundColor: context.appColors.backgroundSecondary,
            child: Text(person.name.isEmpty ? '?' : person.name[0]),
          )
        : UserAvatar(
            userId: person.avatarUserId!,
            radius: 17,
            backgroundColor: context.appColors.backgroundSecondary,
            fallback: Text(person.name.isEmpty ? '?' : person.name[0]),
          );
    return InkWell(
      onTap: _savingId != null ? null : () => _toggle(person),
      child: SizedBox(
        width: 90,
        height: 100,
        child: Stack(
          children: [
            Positioned(
              left: 24,
              top: 21,
              child: SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_attendancePercentages != null)
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: CircularProgressIndicator(
                          value: percentage / 100,
                          strokeWidth: 3,
                          color: const Color(0xFF3FA73B),
                          backgroundColor: context.appColors.border,
                        ),
                      ),
                    avatar,
                  ],
                ),
              ),
            ),
            if (_attendancePercentages != null)
              Positioned(
                right: 5,
                top: 55,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: attendanceColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$percentage %',
                    style: TextStyle(
                      color: attendanceColor.computeLuminance() > .45
                          ? Colors.black
                          : Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (selected)
              const Positioned(
                right: 10,
                top: 24,
                child: Icon(
                  Icons.check_circle,
                  size: 17,
                  color: Color(0xFF3F8752),
                ),
              ),
            if (_savingId == person.id)
              const Positioned(
                right: 10,
                top: 24,
                child: SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            Positioned(
              left: 2,
              right: 2,
              top: 78,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 86),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.cardBackground,
                    border: Border.all(color: context.appColors.border),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    person.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moreTile({required bool showInactive, required VoidCallback onTap}) =>
      InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 90,
          height: 100,
          child: Stack(
            children: [
              Positioned(
                left: 28,
                top: 28,
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: context.appColors.backgroundSecondary,
                  child: Icon(
                    Icons.more_horiz,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
              Positioned(
                left: 2,
                right: 2,
                top: 67,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.cardBackground,
                      border: Border.all(color: context.appColors.border),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      showInactive ? 'méně' : 'více',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('Přidat do zápasu', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      Expanded(
        child: ListView(
          children: [
            _group('Hráči', widget.setup.playerList, fans: false),
            const SizedBox(height: 16),
            const Divider(),
            _group('Fanoušci', widget.setup.fanList, fans: true),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ],
  );
}

class _LineupScoreHeader extends StatelessWidget {
  final FootballMatchApiModel match;
  final VoidCallback? onTap;
  const _LineupScoreHeader({required this.match, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                TeamLogo(url: match.homeTeam?.logoUrl, size: 52),
                const SizedBox(height: 6),
                Text(
                  match.homeTeam?.name ?? '',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Text(
                  match.homeGoalNumber == null || match.awayGoalNumber == null
                      ? '–'
                      : '${match.homeGoalNumber}:${match.awayGoalNumber}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.expand_more,
                    size: 18,
                    color: context.appColors.textMuted,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                TeamLogo(url: match.awayTeam?.logoUrl, size: 52),
                const SizedBox(height: 6),
                Text(
                  match.awayTeam?.name ?? '',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _LineupMatchDetails extends StatelessWidget {
  final FootballMatchApiModel match;
  final VoidCallback? onEditMatch;
  const _LineupMatchDetails({required this.match, required this.onEditMatch});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              '${match.round}. kolo · ${match.league.name} · ${matchDateToString(match.date, includeTime: true)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          if (onEditMatch != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'Upravit zápas',
              icon: const Icon(Icons.edit_outlined, size: 19),
              onPressed: onEditMatch,
            ),
        ],
      ),
      Text(
        '${match.stadium ?? "–"} · Rozhodčí: ${match.referee?.trim().isNotEmpty == true ? match.referee!.trim() : "neznámý"}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

class _PlayerStats {
  int goals = 0;
  int assists = 0;
  int yellowCards = 0;
  int redCards = 0;
  int beers = 0;
  int liquors = 0;
  int fineAmount = 0;
  final List<ReceivedFineDetailedModel> fines = [];
  final List<String> achievements = [];
  bool bestPlayer = false;
  double? rating;
}

class _RatingBreakdown extends StatefulWidget {
  final List<(String, int)> parts;

  const _RatingBreakdown({required this.parts});

  @override
  State<_RatingBreakdown> createState() => _RatingBreakdownState();
}

class _RatingBreakdownState extends State<_RatingBreakdown> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextButton.icon(
        onPressed: () => setState(() => expanded = !expanded),
        icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
        label: Text(
          expanded ? 'Skrýt důvod hodnocení' : 'Zobrazit důvod hodnocení',
        ),
      ),
      if (expanded) ...[
        for (final part in widget.parts)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(part.$1)),
              Text(
                '${part.$2 > 0 ? '+' : ''}${(part.$2 / 10).toStringAsFixed(1)}',
              ),
            ],
          ),
      ],
    ],
  );
}

class _LineupField extends StatefulWidget {
  final int matchId;
  final List<PlayerApiModel> players;
  final List<PlayerApiModel> fans;
  final Map<int, _PlayerStats> playerStats;
  final MatchApiModel? match;
  final String? teamLogoUrl;
  final int? goalkeeperId;
  final Set<int> goalkeeperIds;
  final bool listView;
  final VoidCallback? onAddPeople;
  const _LineupField({
    required this.matchId,
    required this.players,
    required this.fans,
    required this.playerStats,
    required this.match,
    required this.teamLogoUrl,
    required this.goalkeeperId,
    required this.goalkeeperIds,
    required this.listView,
    this.onAddPeople,
  });

  @override
  State<_LineupField> createState() => _LineupFieldState();
}

class _LineupFieldState extends State<_LineupField> {
  List<int?> slots = [];
  bool loaded = false;
  String get keyPrefix => 'played_match_pitch_${widget.matchId}';
  int get count =>
      (widget.players.length + (widget.goalkeeperId == null ? 1 : 0)).clamp(
        6,
        11,
      );

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _LineupField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.matchId != widget.matchId) {
      loaded = false;
      _load();
    } else if (loaded) {
      _reconcile();
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('${keyPrefix}_slots') ?? [];
    if (!mounted) return;
    setState(() {
      slots = List.generate(
        count,
        (i) => i < saved.length ? int.tryParse(saved[i]) : null,
      );
      loaded = true;
      _reconcile();
    });
  }

  void _reconcile() {
    final ids = widget.players.map((p) => p.id).whereType<int>().toSet();
    final seen = <int>{};
    final goalkeeperId = widget.goalkeeperId;
    if (goalkeeperId != null && ids.contains(goalkeeperId)) {
      seen.add(goalkeeperId);
    }
    slots = List.generate(count, (i) {
      if (i == 0) return goalkeeperId;
      final id = i < slots.length ? slots[i] : null;
      return id != null && ids.contains(id) && seen.add(id) ? id : null;
    });
    for (final player in widget.players) {
      final id = player.id;
      if (id == null || seen.contains(id)) continue;
      final free = slots.indexOf(null, 1);
      if (free < 0) break;
      slots[free] = id;
      seen.add(id);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      '${keyPrefix}_slots',
      slots.map((id) => id?.toString() ?? '').toList(),
    );
  }

  void _move(int id, int target) {
    if (target == 0 || id == widget.goalkeeperId) return;
    setState(() {
      final source = slots.indexOf(id);
      final displaced = slots[target];
      if (source >= 0) slots[source] = displaced;
      slots[target] = id;
    });
    _save();
  }

  PlayerApiModel? _player(int? id) {
    for (final player in widget.players) {
      if (player.id == id) return player;
    }
    return null;
  }

  List<Offset> _positions() {
    final n = count;
    final defenders = n >= 8 ? 3 : 2;
    final midfielders = n >= 10
        ? 4
        : n >= 7
        ? 3
        : 2;
    final forwards = n - 1 - defenders - midfielders;
    final columns = <(double, int)>[
      (47, 1),
      (141, defenders),
      (235, midfielders),
      (329, forwards),
    ];
    final positions = <Offset>[];
    for (final column in columns) {
      final rows = column.$2;
      for (var i = 0; i < rows; i++) {
        final y = rows == 1 ? 220.0 : 65 + i * (310 / (rows - 1));
        positions.add(Offset(column.$1, y));
      }
    }
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listView) return _listView();
    if (!loaded) {
      return const SizedBox(
        height: 350,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final bench = widget.players.where((p) => !slots.contains(p.id)).toList();
    final colors = context.appColors;
    final dark = colors.backgroundPrimary.computeLuminance() < .5;
    final positions = _positions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 376 / 440,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColoredBox(
              color: colors.backgroundPrimary,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 376,
                  height: 440,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _PitchPainter(
                            dark ? Colors.white : const Color(0xFF374151),
                          ),
                        ),
                      ),
                      for (var i = 0; i < slots.length; i++)
                        Positioned(
                          left: positions[i].dx - 45,
                          top: positions[i].dy - 57,
                          child: DragTarget<int>(
                            onWillAcceptWithDetails: (data) =>
                                i != 0 &&
                                data.data != widget.goalkeeperId &&
                                data.data != slots[i] &&
                                widget.players.any((p) => p.id == data.data),
                            onAcceptWithDetails: (data) => _move(data.data, i),
                            builder: (context, candidates, _) => Container(
                              width: 90,
                              height: 100,
                              decoration: candidates.isEmpty
                                  ? null
                                  : BoxDecoration(
                                      color: colors.textPrimary.withAlpha(35),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                              child: _tile(_player(slots[i])),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _sideline(bench, widget.fans),
      ],
    );
  }

  Widget _listView() {
    final players = [...widget.players]
      ..sort((a, b) {
        final aRating = widget.playerStats[a.id]?.rating;
        final bRating = widget.playerStats[b.id]?.rating;
        if (aRating == null && bRating != null) return 1;
        if (bRating == null && aRating != null) return -1;
        final byRating = (bRating ?? 0).compareTo(aRating ?? 0);
        return byRating != 0
            ? byRating
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    final fans = [...widget.fans]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 4.0;
        final tileWidth = (constraints.maxWidth - spacing * 3) / 4;
        Widget grid(List<PlayerApiModel> people, {required bool fans}) {
          final tileHeight = tileWidth * 100 / 90;
          final rowStep = tileWidth * (fans ? 70 : 92) / 90;
          final count = people.length + (widget.onAddPeople == null ? 0 : 1);
          final rows = (count + 3) ~/ 4;
          Widget placed(int index, Widget child) => Positioned(
            left: (index % 4) * (tileWidth + spacing),
            top: (index ~/ 4) * rowStep,
            width: tileWidth,
            height: tileHeight,
            child: FittedBox(fit: BoxFit.contain, child: child),
          );
          return SizedBox(
            width: constraints.maxWidth,
            height: rows == 0 ? 0 : (rows - 1) * rowStep + tileHeight,
            child: Stack(
              children: [
                for (var i = 0; i < people.length; i++)
                  placed(i, _tile(people[i], listTile: true)),
                if (widget.onAddPeople != null)
                  placed(people.length, _listAddTile()),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hráči', style: Theme.of(context).textTheme.titleSmall),
            grid(players, fans: false),
            const SizedBox(height: 12),
            const Divider(),
            Text('Fanoušci', style: Theme.of(context).textTheme.titleSmall),
            grid(fans, fans: true),
          ],
        );
      },
    );
  }

  Widget _listAddTile() => SizedBox(
    width: 90,
    height: 100,
    child: InkWell(
      onTap: widget.onAddPeople,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned(
            left: 28,
            top: 32,
            child: CircleAvatar(
              radius: 17,
              backgroundColor: context.appColors.cardBackground,
              child: Icon(Icons.add, color: context.appColors.textPrimary),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 67,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: context.appColors.cardBackground,
                  border: Border.all(color: context.appColors.border),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'Přidat',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _sideline(
    List<PlayerApiModel> substitutes,
    List<PlayerApiModel> fans,
  ) {
    final color = context.appColors.textSecondary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Stack(
            children: [
              Positioned(
                left: 4,
                right: 4,
                top: 5,
                bottom: 3,
                child: CustomPaint(painter: _BenchPainter(color)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: SizedBox(
                  height: 76,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: substitutes.length,
                    itemBuilder: (context, index) =>
                        _sidelineTile(substitutes[index], 70, 76),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(width: 1, height: 100, color: color.withAlpha(90)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SupporterFlag(logoUrl: widget.teamLogoUrl),
              _sidelinePeople(fans),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sidelinePeople(List<PlayerApiModel> people) => SizedBox(
    height: 80,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: people.length,
      itemBuilder: (context, index) => _fanTile(people[index]),
    ),
  );

  Widget _sidelineTile(PlayerApiModel person, double width, double height) =>
      SizedBox(
        width: width,
        height: height,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(width: 90, height: 100, child: _tile(person)),
        ),
      );

  Widget _fanTile(PlayerApiModel fan) {
    final colors = context.appColors;
    final avatar = fan.avatarUserId == null
        ? CircleAvatar(
            radius: 20,
            backgroundColor: colors.cardBackground,
            child: Text(fan.name.isEmpty ? '?' : fan.name[0]),
          )
        : UserAvatar(
            userId: fan.avatarUserId!,
            radius: 20,
            backgroundColor: colors.cardBackground,
            fallback: Text(fan.name.isEmpty ? '?' : fan.name[0]),
          );
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showPlayerDetail(fan),
              child: avatar,
            ),
          ),
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              fan.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
          _consumptionIcons(widget.playerStats[fan.id], width: 40),
        ],
      ),
    );
  }

  Widget _tile(PlayerApiModel? player, {bool listTile = false}) {
    if (player == null) {
      return const Center(
        child: CircleAvatar(
          radius: 15,
          backgroundColor: Color(0x99FFFFFF),
          child: Icon(
            Icons.person_add_alt_1,
            size: 16,
            color: Color(0xFF668575),
          ),
        ),
      );
    }
    final stats = widget.playerStats[player.id];
    final rating = player.fan ? null : stats?.rating;
    final hasNumberedBadge =
        stats != null &&
        (stats.goals > 1 ||
            stats.assists > 1 ||
            stats.yellowCards > 1 ||
            stats.redCards > 1);
    final badges = <Widget>[
      if (stats != null && stats.goals > 0)
        _statBadge(
          Icons.sports_soccer,
          stats.goals,
          context.appColors.textPrimary,
        ),
      if (stats != null && stats.assists > 0)
        _eventBadge(
          Text(
            'A',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1,
              fontWeight: FontWeight.w900,
              color: context.appColors.infoSolid,
            ),
          ),
          stats.assists,
        ),
      if (stats != null && stats.yellowCards > 0)
        _cardBadge(const Color(0xFFF4C542), stats.yellowCards),
      if (stats != null && stats.redCards > 0)
        _cardBadge(const Color(0xFFE34B4B), stats.redCards),
    ];
    final avatar = player.avatarUserId == null
        ? CircleAvatar(
            radius: 17,
            backgroundColor: context.appColors.cardBackground,
            child: Text(
              player.name.isEmpty ? '?' : player.name[0],
              style: const TextStyle(fontSize: 13),
            ),
          )
        : UserAvatar(
            userId: player.avatarUserId!,
            radius: 17,
            backgroundColor: context.appColors.cardBackground,
            fallback: Text(
              player.name.isEmpty ? '?' : player.name[0],
              style: const TextStyle(fontSize: 13),
            ),
          );
    final child = SizedBox(
      width: 90,
      height: 100,
      child: Stack(
        children: [
          Positioned(
            left: 28,
            top: 32,
            child: GestureDetector(
              onTap: () => _showPlayerDetail(player),
              child: avatar,
            ),
          ),
          if (badges.isNotEmpty)
            Positioned(
              left: hasNumberedBadge ? 14 : 20,
              top: 66.0 - (18 + (badges.length - 1) * 12),
              child: SizedBox(
                width: 18,
                height: 18.0 + (badges.length - 1) * 12,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var i = 0; i < badges.length; i++)
                      Positioned(top: i * 12.0, child: badges[i]),
                  ],
                ),
              ),
            ),
          if (stats?.bestPlayer == true)
            const Positioned(
              left: 57,
              top: 27,
              child: Icon(Icons.star, size: 16, color: Color(0xFFFFB300)),
            ),
          if (rating != null)
            Positioned(
              right: 3,
              top: 48,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: _ratingColor(rating),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          if ((listTile || widget.goalkeeperIds.length > 1) &&
              widget.goalkeeperIds.contains(player.id))
            Positioned(
              left: stats?.bestPlayer == true ? 67 : 57,
              top: stats?.bestPlayer == true ? 25 : 27,
              child: const Tooltip(
                message: 'Brankář',
                child: Icon(
                  Icons.back_hand_outlined,
                  size: 16,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 3)],
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            top: 67,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: hasNumberedBadge ? 62 : 48,
                  maxWidth: 86,
                ),
                child: IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.cardBackground,
                      border: Border.all(color: context.appColors.border),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 84,
            child: _consumptionIcons(stats, width: 90),
          ),
        ],
      ),
    );
    final id = player.id;
    if (listTile || id == null || player.fan || id == widget.goalkeeperId) {
      return child;
    }
    return LongPressDraggable<int>(
      data: id,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 90, height: 100, child: child),
      ),
      childWhenDragging: Opacity(opacity: .3, child: child),
      child: child,
    );
  }

  Widget _consumptionIcons(_PlayerStats? stats, {required double width}) {
    final colors = context.appColors;
    if (stats == null ||
        (stats.beers == 0 && stats.liquors == 0 && stats.fineAmount == 0)) {
      return const SizedBox.shrink();
    }
    Widget badge(IconData icon, String value) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: colors.textPrimary),
          Text(
            value,
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
    final badges = <Widget>[
      if (stats.beers > 0) badge(Icons.sports_bar, '${stats.beers}'),
      if (stats.liquors > 0) badge(Icons.local_bar, '${stats.liquors}'),
      if (stats.fineAmount > 0)
        Container(
          height: 13,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF3F8752),
            border: Border.all(color: const Color(0xFF205C31)),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            '${stats.fineAmount} Kč',
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
    ];
    return SizedBox(
      width: width,
      height: 14,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in badges) ...[
              if (item != badges.first) const SizedBox(width: 1),
              item,
            ],
          ],
        ),
      ),
    );
  }

  void _showPlayerDetail(PlayerApiModel player) {
    final stats = widget.playerStats[player.id] ?? _PlayerStats();
    final match = widget.match;
    final scored =
        match?.homeGoalNumber == null || match?.awayGoalNumber == null
        ? null
        : (match!.home ? match.homeGoalNumber! : match.awayGoalNumber!);
    final conceded =
        match?.homeGoalNumber == null || match?.awayGoalNumber == null
        ? null
        : (match!.home ? match.awayGoalNumber! : match.homeGoalNumber!);
    final overkicks = stats.fines
        .where((fine) => fine.fine?.code == 'OVERKICK')
        .fold<int>(0, (sum, fine) => sum + fine.fineNumber);
    final thirdHalf = stats.fines.any(
      (fine) => fine.fine?.code == 'THIRD_HALF',
    );
    final breakdown = <(String, int)>[
      ('Základ', 60),
      if (stats.goals > 0) ('Góly (${stats.goals} × 0,4)', stats.goals * 4),
      if (stats.assists > 0)
        ('Asistence (${stats.assists} × 0,2)', stats.assists * 2),
      if (stats.yellowCards > 0)
        ('Žluté karty (${stats.yellowCards} × −0,7)', -stats.yellowCards * 7),
      if (stats.redCards > 0)
        ('Červené karty (${stats.redCards} × −2,0)', -stats.redCards * 20),
      if (scored != null) ('Góly týmu ($scored × 0,1)', scored),
      if (conceded != null) ('Obdržené góly ($conceded × −0,2)', -conceded * 2),
      if (thirdHalf) ('Pokuta za třetí poločas', -5),
      if (stats.beers > 0) ('Piva (${stats.beers} × 0,2)', stats.beers * 2),
      if (stats.liquors > 0)
        ('Panáky (${stats.liquors} × 0,3)', stats.liquors * 3),
      if (stats.fineAmount >= 100)
        ('Pokuty (${stats.fineAmount} Kč)', -(stats.fineAmount ~/ 100)),
      if (overkicks > 0) ('Překopy ($overkicks × −0,1)', -overkicks),
      if (stats.achievements.isNotEmpty)
        (
          'Achievementy (${stats.achievements.length} × 0,5)',
          stats.achievements.length * 5,
        ),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.cardBackground,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .8,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                player.name,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Pokuty',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              if (stats.fines.isEmpty) const Text('Žádné pokuty'),
              for (final fine in stats.fines)
                Text(
                  '${fine.fine?.name ?? 'Pokuta'} × ${fine.fineNumber} · ${fine.fineAmount} Kč',
                ),
              const SizedBox(height: 16),
              Text(
                'Achievementy za zápas',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              if (stats.achievements.isEmpty) const Text('Žádné achievementy'),
              for (final name in stats.achievements) Text('★ $name'),
              if (!player.fan) ...[
                const SizedBox(height: 16),
                Text(
                  'Hodnocení',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                if (stats.rating == null)
                  const Text('Hodnocení není k dispozici')
                else ...[
                  Text(
                    'Celkem: ${stats.rating!.toStringAsFixed(1)}',
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  _RatingBreakdown(parts: breakdown),
                ],
              ],
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) => TextButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    ref
                        .read(screenVariablesNotifierProvider.notifier)
                        .setPlayer(player);
                    ref
                        .read(screenNotifierProvider.notifier)
                        .changeByFragmentId(ViewPlayerScreen.id);
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Otevřít profil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBadge(IconData icon, int count, Color color) =>
      _eventBadge(Icon(icon, size: 12, color: color), count);

  Color _ratingColor(double rating) {
    if (rating < 5) return const Color(0xFF99252C);
    if (rating < 6) return const Color(0xFFD65A63);
    if (rating < 7) return const Color(0xFFF28C28);
    if (rating < 8) return const Color(0xFF3FA73B);
    if (rating < 9) return const Color(0xFF287FC6);
    return const Color(0xFF7842B8);
  }

  Widget _cardBadge(Color color, int count) => _eventBadge(
    Container(
      width: 8,
      height: 11,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    ),
    count,
  );

  Widget _eventBadge(Widget symbol, int count) => SizedBox(
    width: 18,
    height: 18,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              border: Border.all(color: context.appColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Center(child: symbol),
        if (count > 1)
          Positioned(
            right: -2,
            top: -3,
            child: Container(
              constraints: const BoxConstraints(minWidth: 9, minHeight: 9),
              padding: const EdgeInsets.symmetric(horizontal: 1),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF263238),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _BenchPainter extends CustomPainter {
  final Color color;
  const _BenchPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final roof = Path()
      ..moveTo(0, 21)
      ..quadraticBezierTo(size.width / 2, -14, size.width, 21);
    canvas.drawPath(roof, paint);
    canvas.drawLine(const Offset(0, 21), Offset(0, size.height), paint);
    canvas.drawLine(
      Offset(size.width, 21),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height - 12),
      Offset(size.width, size.height - 12),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BenchPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PitchPainter extends CustomPainter {
  final Color lineColor;
  const _PitchPainter(this.lineColor);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(7, 7, size.width - 14, size.height - 14),
      paint,
    );
    canvas.drawCircle(Offset(size.width - 7, size.height / 2), 39, paint);
    canvas.drawRect(
      Rect.fromLTWH(7, size.height * .25, 60, size.height * .50),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(7, size.height * .38, 25, size.height * .24),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}

class _RefereeProfile extends StatelessWidget {
  final RefereeStats? stats;
  final String? name;
  final String comment;
  final bool listView;

  const _RefereeProfile({
    required this.stats,
    required this.name,
    required this.comment,
    this.listView = false,
  });

  @override
  Widget build(BuildContext context) {
    final refereeName = stats?.name ?? name?.trim() ?? '';
    if (refereeName.isEmpty) return const SizedBox.shrink();
    final hasComment = comment.trim().isNotEmpty;
    if (listView) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Divider(),
          Text('Rozhodčí', style: Theme.of(context).textTheme.titleSmall),
          InkWell(
            onTap: () => _showDetail(context, refereeName),
            child: SizedBox(
              width: 90,
              height: 100,
              child: Stack(
                children: [
                  Positioned(
                    left: 25,
                    top: 24,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: context.appColors.cardBackground,
                      child: Icon(
                        Icons.sports,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                  ),
                  if (hasComment)
                    const Positioned(
                      right: 4,
                      top: 20,
                      child: Icon(Icons.mode_comment, size: 18),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 67,
                    child: Text(
                      refereeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showDetail(context, refereeName),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: context.appColors.cardBackground,
                      child: Icon(
                        Icons.sports,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    if (hasComment)
                      const Positioned(
                        right: -6,
                        top: -3,
                        child: Icon(Icons.mode_comment, size: 18),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  refereeName,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, String refereeName) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.cardBackground,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .8,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                refereeName,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (stats != null) ...[
                Text('Odpískané zápasy týmu: ${stats!.matchCount}'),
                Text(
                  'Podíl výher týmu: ${stats!.winPercentage.toStringAsFixed(1)} %',
                ),
                Text(
                  'Nejvíce hvězd utkání: ${stats!.mostStarredPlayer ?? '–'} (${stats!.mostStarredCount})',
                ),
                Text(
                  'Žluté karty na zápas: ${stats!.yellowCardsPerMatch.toStringAsFixed(2)}',
                ),
                Text(
                  'Červené karty na zápas: ${stats!.redCardsPerMatch.toStringAsFixed(2)}',
                ),
              ],
              if (comment.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Komentář k zápasu',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                Text(comment.trim()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SupporterFlag extends StatelessWidget {
  final String? logoUrl;
  const _SupporterFlag({required this.logoUrl});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 52,
    height: 36,
    child: Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _FlagPainter(context.appColors.accent)),
        ),
        Positioned.fill(
          child: ClipPath(
            clipper: _FlagClipper(),
            child: Center(child: TeamLogo(url: logoUrl, size: 21)),
          ),
        ),
      ],
    ),
  );
}

Path _flagShape(Size size) => Path()
  ..moveTo(7, 4)
  ..quadraticBezierTo(18, 0, 29, 4)
  ..quadraticBezierTo(40, 8, size.width - 2, 4)
  ..lineTo(size.width - 5, 26)
  ..quadraticBezierTo(40, 30, 29, 26)
  ..quadraticBezierTo(18, 22, 7, 27)
  ..close();

class _FlagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _flagShape(size);

  @override
  bool shouldReclip(covariant _FlagClipper oldClipper) => false;
}

class _FlagPainter extends CustomPainter {
  final Color color;
  const _FlagPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final pole = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(6, 2), Offset(6, size.height - 2), pole);
    final flag = _flagShape(size);
    canvas.drawPath(flag, Paint()..color = color.withAlpha(55));
    canvas.drawPath(
      flag,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _FlagPainter oldDelegate) =>
      oldDelegate.color != color;
}
