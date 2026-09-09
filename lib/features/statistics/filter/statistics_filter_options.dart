import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/search_text.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/attendance/attendance_detailed_model.dart';
import 'package:trus_app/models/api/beer/beer_detailed_model.dart';
import 'package:trus_app/models/api/goal/goal_detailed_model.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_detailed_model.dart';
import 'statistics_filter.dart';
import 'package:trus_app/features/season/repository/season_api_service.dart';
import 'package:trus_app/features/statistics/repository/stats_api_service.dart';
import 'package:trus_app/features/statistics/stat_args.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

final statisticsSeasonsProvider = FutureProvider.autoDispose(
  (ref) => ref
      .read(seasonApiServiceProvider)
      .getSeasons(false, true, false, playedOnly: true),
);

final statisticsFilterOptionsProvider = FutureProvider.autoDispose
    .family<StatisticsFilterOptions, StatsArgs>((ref, args) async {
      final seasons = ref.watch(statisticsSeasonsProvider.future);
      final statistics = ref
          .read(statsApiServiceProvider)
          .getDetailedStats(
            null,
            null,
            null,
            !args.matchOrPlayer,
            null,
            null,
            args.api,
            advancedFilter: StatisticsFilter(
              seasonIds: args.seasonIds,
              fineIds: args.fineIds,
            ),
          );
      final fines = args.api == receivedFineApi
          ? ref.read(statsApiServiceProvider).getFineOptions()
          : Future.value(<FineApiModel>[]);
      final results = await Future.wait<Object>([seasons, fines, statistics]);
      final players = <int, PlayerApiModel>{};
      final opponents = <String>{};
      final response = await statistics;
      for (final row in response.modelList()) {
        final (player, match) = switch (row) {
          BeerDetailedModel r => (r.player, r.match),
          GoalDetailedModel r => (r.player, r.match),
          ReceivedFineDetailedModel r => (r.player, r.match),
          AttendanceDetailedModel r => (r.player, r.match),
          _ => (null, null),
        };
        if (player?.id != null) players[player!.id!] = player;
        if (match != null) opponents.add(match.name);
      }
      return StatisticsFilterOptions(
        seasons: results[0] as List<SeasonApiModel>,
        players: players.values.toList()
          ..sort((a, b) => a.name.compareTo(b.name)),
        opponents: opponents.toList()..sort(),
        fines: [...results[1] as List<FineApiModel>]
          ..sort((a, b) => a.name.compareTo(b.name)),
      );
    });

class StatisticsFilterOptions {
  final List<SeasonApiModel> seasons;
  final List<PlayerApiModel> players;
  final List<String> opponents;
  final List<FineApiModel> fines;
  const StatisticsFilterOptions({
    required this.seasons,
    required this.players,
    required this.opponents,
    required this.fines,
  });

  /// Keep original names for exact API matching, but expose one choice per name.
  Map<String, Set<String>> get opponentGroups {
    final groups = <String, Set<String>>{};
    for (final name in opponents) {
      final key = opponentKey(name);
      if (key.isNotEmpty) (groups[key] ??= <String>{}).add(name);
    }
    return groups;
  }

  static String opponentKey(String name) => normalizeSearchText(
    name,
  ).replaceAll(RegExp(r'[\u0300-\u036f]'), '').replaceAll(RegExp(r'\s+'), ' ');

  static String opponentLabel(Iterable<String> names) {
    final labels =
        names
            .map((name) => name.trim().replaceAll(RegExp(r'\s+'), ' '))
            .toList()
          ..sort();
    return labels.firstWhere(
      (name) => normalizeSearchText(name) != name.toLowerCase(),
      orElse: () => labels.first,
    );
  }
}

// These providers are read only after opening their corresponding selector.
final statisticsFineOptionsProvider =
    FutureProvider.autoDispose<List<FineApiModel>>((ref) async {
      var alive = true;
      ref.onDispose(() => alive = false);
      final link = ref.keepAlive();
      final timer = Timer(const Duration(minutes: 2), link.close);
      ref.onDispose(timer.cancel);
      final rows = await ref.read(statsApiServiceProvider).getFineOptions();
      if (alive)
        ref.read(statisticsFineLabelsProvider.notifier).state = {
          for (final f in rows)
            if (f.id != null) f.id!: f.name,
        };
      return rows;
    });
final statisticsPlayerLabelsProvider = StateProvider<Map<int, String>>(
  (ref) => {},
);
final statisticsFineLabelsProvider = StateProvider<Map<int, String>>(
  (ref) => {},
);
final statisticsContextOptionsProvider = FutureProvider.autoDispose
    .family<StatisticsFilterOptions, StatsArgs>((ref, args) async {
      var alive = true;
      ref.onDispose(() => alive = false);
      final link = ref.keepAlive();
      final timer = Timer(const Duration(minutes: 2), link.close);
      ref.onDispose(timer.cancel);
      final response = await ref
          .read(statsApiServiceProvider)
          .getDetailedStats(
            null,
            null,
            null,
            !args.matchOrPlayer,
            null,
            null,
            args.api,
            advancedFilter: StatisticsFilter(
              seasonIds: args.seasonIds,
              fineIds: args.fineIds,
            ),
          );
      final players = <int, PlayerApiModel>{};
      final opponents = <String>{};
      for (final row in response.modelList()) {
        final (player, match) = switch (row) {
          BeerDetailedModel r => (r.player, r.match),
          GoalDetailedModel r => (r.player, r.match),
          ReceivedFineDetailedModel r => (r.player, r.match),
          AttendanceDetailedModel r => (r.player, r.match),
          _ => (null, null),
        };
        if (player?.id != null) players[player!.id!] = player;
        if (match != null) opponents.add(match.name);
      }
      if (alive)
        ref.read(statisticsPlayerLabelsProvider.notifier).state = {
          ...ref.read(statisticsPlayerLabelsProvider),
          for (final p in players.values) p.id!: p.name,
        };
      return StatisticsFilterOptions(
        seasons: const [],
        fines: const [],
        players: players.values.toList()
          ..sort((a, b) => a.name.compareTo(b.name)),
        opponents: opponents.toList()..sort(),
      );
    });
