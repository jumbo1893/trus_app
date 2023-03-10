import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/season_model.dart';

import '../repository/season_repository.dart';

final seasonControllerProvider = Provider((ref) {
  final seasonRepository = ref.watch(seasonRepositoryProvider);
  return SeasonController(seasonRepository: seasonRepository, ref: ref);
});

class SeasonController {
  final SeasonRepository seasonRepository;
  final ProviderRef ref;

  SeasonController({
    required this.seasonRepository,
    required this.ref,
  });

  Stream<List<SeasonModel>> seasons() {
    return seasonRepository.getSeasons();
  }

  Future<bool> addSeason(
    BuildContext context,
    String name,
    DateTime fromDate,
    DateTime toDate,
  ) async {
    bool result =
        await seasonRepository.addSeason(context, name, fromDate, toDate);
    return result;
  }

  Future<bool> editSeason(
    BuildContext context,
    String name,
    DateTime fromDate,
    DateTime toDate,
    SeasonModel seasonModel,
  ) async {
    bool result = await seasonRepository.editSeason(
        context, name, fromDate, toDate, seasonModel);
    return result;
  }

  Future<void> deleteSeason(
    BuildContext context,
    SeasonModel seasonModel,
  ) async {
    await seasonRepository.deleteSeason(context, seasonModel);
  }
}
