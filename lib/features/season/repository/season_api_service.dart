import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/crud_api_service.dart';

import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/api/season_api_model.dart';

final seasonApiServiceProvider =
    Provider<SeasonApiService>((ref) => SeasonApiService());

class SeasonApiService extends CrudApiService {

  Future<List<SeasonApiModel>> getSeasons(bool automaticSeason, bool otherSeason, bool allSeason) async {
    final queryParameters = {
      'allSeason': allSeason.toString(),
      'otherSeason': otherSeason.toString(),
      'automaticSeason': automaticSeason.toString(),
    };
    final decodedBody = await getModels<JsonAndHttpConverter>(seasonApi, queryParameters);
    return decodedBody.map((model) => model as SeasonApiModel).toList();
  }

  Future<SeasonApiModel> addSeason(SeasonApiModel season) async {
    final decodedBody = await addModel<JsonAndHttpConverter>(season);
    return decodedBody as SeasonApiModel;
  }

  Future<SeasonApiModel> editSeason(SeasonApiModel season, int id) async {
    final decodedBody = await editModel<JsonAndHttpConverter>(season, id);
    return decodedBody as SeasonApiModel;
  }

  Future<bool> deleteSeason(int id) async {
    return await deleteModel(id, seasonApi);
  }
}
