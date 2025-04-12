import 'package:trus_app/models/api/player/player_api_model.dart';

abstract class IChartPickedPlayerCallback {
  Future<void> onPlayerPicked(PlayerApiModel player);
  Future<List<PlayerApiModel>> getPlayers();
}