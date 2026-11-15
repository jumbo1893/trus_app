import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/models/api/match/match_setup.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/match/match_stats.dart';
import 'package:trus_app/models/api/beer/beer_detailed_model.dart';
import 'package:trus_app/models/api/goal/goal_detailed_model.dart';
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
    .family<({MatchSetup setup, MatchStats? stats}), int>((ref, matchId) async {
      final repository = ref.read(matchRepositoryProvider);
      final setup = await repository.fetchMatchSetup(matchId);
      MatchStats? stats;
      try {
        stats = await repository.fetchMatchStats(matchId);
      } catch (_) {
        // The lineup is still useful if the optional statistics fail to load.
      }
      return (setup: setup, stats: stats);
    });

/// Actual match roster, taken from the saved match rather than RSVP responses.
class PlayedMatchPitch extends ConsumerStatefulWidget {
  final int matchId;
  final String comment;
  final VoidCallback? onEditMatch;
  const PlayedMatchPitch({
    super.key,
    required this.matchId,
    this.comment = '',
    this.onEditMatch,
  });

  @override
  ConsumerState<PlayedMatchPitch> createState() => _PlayedMatchPitchState();
}

class _PlayedMatchPitchState extends ConsumerState<PlayedMatchPitch> {
  final ScrollController _scrollController = ScrollController();

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
            if (result.goalkeepingMinutes > 0) {
              goalkeepers.add(id);
              if (result.goalkeepingMinutes > goalkeeperMinutes) {
                goalkeeperMinutes = result.goalkeepingMinutes;
                goalkeeperId = id;
              }
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
                        _LineupScoreHeader(match: footballMatch),
                        _LineupMatchDetails(
                          match: footballMatch,
                          onEditMatch: widget.onEditMatch,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
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
              ),
              _RefereeProfile(
                stats: data.stats?.refereeStats,
                name: footballMatch?.referee,
                comment: widget.comment,
              ),
            ],
          );
        },
      );
}

class _LineupScoreHeader extends StatelessWidget {
  final FootballMatchApiModel match;
  const _LineupScoreHeader({required this.match});

  @override
  Widget build(BuildContext context) => Padding(
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
          child: Text(
            match.homeGoalNumber == null || match.awayGoalNumber == null
                ? '–'
                : '${match.homeGoalNumber}:${match.awayGoalNumber}',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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

class _LineupField extends StatefulWidget {
  final int matchId;
  final List<PlayerApiModel> players;
  final List<PlayerApiModel> fans;
  final Map<int, _PlayerStats> playerStats;
  final MatchApiModel? match;
  final String? teamLogoUrl;
  final int? goalkeeperId;
  final Set<int> goalkeeperIds;
  const _LineupField({
    required this.matchId,
    required this.players,
    required this.fans,
    required this.playerStats,
    required this.match,
    required this.teamLogoUrl,
    required this.goalkeeperId,
    required this.goalkeeperIds,
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

  Widget _tile(PlayerApiModel? player) {
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
          if (widget.goalkeeperIds.length > 1 &&
              widget.goalkeeperIds.contains(player.id))
            Positioned(
              right: 5,
              top: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                color: const Color(0xFF183D2D),
                child: const Text(
                  'GK',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
    if (id == null || player.fan || id == widget.goalkeeperId) return child;
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
                  for (final part in breakdown)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(part.$1)),
                        Text(
                          '${part.$2 > 0 ? '+' : ''}${(part.$2 / 10).toStringAsFixed(1)}',
                        ),
                      ],
                    ),
                  const Divider(),
                  Text(
                    'Celkem: ${stats.rating!.toStringAsFixed(1)}',
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
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

  const _RefereeProfile({
    required this.stats,
    required this.name,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final refereeName = stats?.name ?? name?.trim() ?? '';
    if (refereeName.isEmpty) return const SizedBox.shrink();
    final hasComment = comment.trim().isNotEmpty;
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
