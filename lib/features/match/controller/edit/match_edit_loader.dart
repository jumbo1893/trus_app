// lib/features/match/controller/match_edit_loader.dart
import 'package:trus_app/features/football/repository/football_repository.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/models/api/football/detail/football_match_detail.dart';
import 'package:trus_app/models/api/match/match_setup.dart';

class MatchEditLoader {
  final MatchRepository matchRepository;
  final FootballRepository footballRepository;

  MatchEditLoader({
    required this.matchRepository,
    required this.footballRepository,
  });

  MatchSetup? cachedSetup(int? matchId) =>
      matchRepository.getCachedMatchSetup(matchId);

  FootballMatchDetail? cachedFootballDetail(int footballMatchId) =>
      footballRepository.getCachedFootballMatchDetail(footballMatchId);

  Future<MatchSetup> fetchSetup(int? matchId) =>
      matchRepository.fetchMatchSetup(matchId);

  Future<FootballMatchDetail> fetchFootballDetail(int footballMatchId) =>
      footballRepository.fetchFootballMatchDetail(footballMatchId);
}
