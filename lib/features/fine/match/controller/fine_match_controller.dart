import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/fine_match_model.dart';
import 'package:trus_app/models/fine_model.dart';

import '../../../../models/helper/fine_match_helper_model.dart';
import '../repository/fine_match_repository.dart';

final fineMatchControllerProvider = Provider((ref) {
  final fineMatchRepository = ref.watch(fineMatchRepositoryProvider);
  return FineMatchController(
      fineMatchRepository: fineMatchRepository, ref: ref);
});

class FineMatchController {
  final FineMatchRepository fineMatchRepository;
  final ProviderRef ref;

  FineMatchController({
    required this.fineMatchRepository,
    required this.ref,
  });

  Stream<List<FineMatchModel>> finesInMatches() {
    return fineMatchRepository.getFinesInMatches();
  }

  Stream<List<FineModel>> fines() {
    return fineMatchRepository.getFines();
  }

  Stream<List<FineMatchHelperModel>> finesInMatchesByMatchAndPlayer(
      String playerId, String matchId) {
    return fineMatchRepository.getFinesInMatchForPlayer(playerId, matchId);
  }

  Future<bool> addFineInMatch(
    BuildContext context,
    String id,
    String matchId,
    String playerId,
    String fineId,
    int number,
  ) async {
    bool result = await fineMatchRepository.addFineInMatch(
        context, id, matchId, fineId, playerId, number);
    return result;
  }

  Future<bool> addMultipleFinesInMatch(
      BuildContext context,
      String matchId,
      String playerId,
      String fineId,
      int number,
      ) async {
    bool result = await fineMatchRepository.addMultipleFinesInMatch(
        context, matchId, fineId, playerId, number, false);
    return result;
  }

  Future<void> deleteFineInMatch(
    BuildContext context,
    FineMatchModel fineMatchModel,
  ) async {
    await fineMatchRepository.deleteFineInMatch(context, fineMatchModel);
  }
}
