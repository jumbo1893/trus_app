import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';
import 'package:trus_app/models/player_model.dart';

final playerControllerProvider = Provider((ref) {
  final playerRepository = ref.watch(playerRepositoryProvider);
  return PlayerController(playerRepository: playerRepository, ref: ref);
});

class PlayerController {
  final PlayerRepository playerRepository;
  final ProviderRef ref;

  PlayerController({
    required this.playerRepository,
    required this.ref,
  });

  Stream<List<PlayerModel>> players() {
    return playerRepository.getPlayers();
  }

  Stream<List<PlayerModel>> playersOrFans(bool fan) {
    return playerRepository.getFilteredPlayersOrPlayers(fan);
  }

  Future<bool> addPlayer(
    BuildContext context,
    String name,
    DateTime birthday,
    bool fan,
    bool isActive,
  ) async {
    bool result = await playerRepository.addPlayer(
        context, name, birthday, fan, isActive);
    return result;
  }

  Future<bool> editPlayer(
    BuildContext context,
    String name,
    DateTime birthday,
    bool fan,
    bool isActive,
    PlayerModel playerModel,
  ) async {
    bool result = await playerRepository.editPlayer(
        context, name, birthday, fan, isActive, playerModel);
    return result;
  }

  Future<void> deletePlayer(
    BuildContext context,
    PlayerModel playerModel,
  ) async {
    await playerRepository.deletePlayer(context, playerModel);
  }
}
