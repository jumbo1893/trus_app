import 'package:trus_app/models/api/player/player_api_model.dart';

class AchievementFilterOptions {
  final List<PlayerApiModel> players;

  const AchievementFilterOptions({required this.players});

  const AchievementFilterOptions.empty() : players = const [];
}
