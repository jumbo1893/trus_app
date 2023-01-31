import '../../models/player_model.dart';

List<PlayerModel> sortPlayersByName(List<PlayerModel> players) {
  players.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return players;
}