import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/request_executor.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

enum OnboardingStep { profile, intro, notifications, steps, footbar }

class OnboardingProgress {
  final bool available;
  final bool autoShow;
  final Set<OnboardingStep> completed;
  const OnboardingProgress({
    required this.available,
    required this.autoShow,
    required this.completed,
  });
  bool get finished => completed.length == OnboardingStep.values.length;
  int get nextIndex =>
      OnboardingStep.values.indexWhere((s) => !completed.contains(s));
  factory OnboardingProgress.fromJson(Map<String, dynamic> json) =>
      OnboardingProgress(
        available: json['available'] == true,
        autoShow: json['autoShow'] == true,
        completed: OnboardingStep.values
            .where(
              (s) => (json['completed'] as List? ?? []).contains(
                s.name.toUpperCase(),
              ),
            )
            .toSet(),
      );
}

class ProfileCandidate {
  final PlayerApiModel player;
  final bool occupied;
  final int score;
  ProfileCandidate(Map<String, dynamic> json)
    : player = PlayerApiModel.fromJson(json['player']),
      occupied = json['occupied'] == true,
      score = json['score'] as int? ?? 0;
}

class OnboardingProfiles {
  final List<OnboardingFootballPlayer> footballPlayers;
  final String name;
  final PlayerApiModel? currentPlayer;
  final List<ProfileCandidate> candidates;
  OnboardingProfiles(Map<String, dynamic> json)
    : footballPlayers = (json['footballPlayers'] as List? ?? [])
          .map((p) => OnboardingFootballPlayer(p))
          .toList(),
      name = json['name'] as String? ?? '',
      currentPlayer = json['currentPlayer'] == null
          ? null
          : PlayerApiModel.fromJson(json['currentPlayer']),
      candidates = (json['candidates'] as List)
          .map((c) => ProfileCandidate(c))
          .toList();
}

class OnboardingFootballPlayer {
  final int id;
  final String name;
  final int? linkedPlayerId;
  OnboardingFootballPlayer(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      linkedPlayerId = json['linkedPlayerId'];
}

final onboardingRepositoryProvider = Provider(
  (ref) => OnboardingRepository(ref),
);
// Keyed by authenticated account AND team, never reuse another login's progress.
final onboardingProgressProvider = FutureProvider.autoDispose
    .family<OnboardingProgress, String>(
      (ref, key) => ref.read(onboardingRepositoryProvider).load(),
    );

class OnboardingRepository extends RequestExecutor {
  OnboardingRepository(super.ref);
  Uri get _url => Uri.parse('$serverUrl/$authApi/onboarding');
  Future<OnboardingProgress> start() => executePostRequest(
    Uri.parse('$_url/start'),
    (j) => OnboardingProgress.fromJson(j),
    jsonEncode({}),
    queueOnFailure: false,
  );
  Future<OnboardingProgress> load() =>
      executeGetRequest(_url, (j) => OnboardingProgress.fromJson(j), null);
  Future<OnboardingProgress> advance([OnboardingStep? step]) =>
      executePutRequest(
        _url,
        (j) => OnboardingProgress.fromJson(j),
        jsonEncode({'completedStep': step?.name.toUpperCase()}),
        queueOnFailure: false,
      );
  Future<OnboardingProfiles> profiles() => executeGetRequest(
    Uri.parse('$_url/profiles'),
    (j) => OnboardingProfiles(j),
    null,
  );
  Future<PlayerApiModel> pair({
    int? footballPlayerId,
    int? playerId,
    String? name,
    DateTime? birthday,
    bool fan = false,
  }) => executePostRequest(
    Uri.parse('$_url/profile'),
    (j) => PlayerApiModel.fromJson(j),
    jsonEncode({
      'playerId': playerId,
      'name': name,
      'birthday': birthday?.toIso8601String().split('T').first,
      'fan': fan,
      'footballPlayerId': footballPlayerId,
    }),
    // Retrying a self-profile action is explicit; do not replay it later
    // after the user skips the step, changes account or switches teams.
    queueOnFailure: false,
  );
}
