import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/pkfl/pkfl_match_api_model.dart';
import 'package:trus_app/models/api/pkfl/pkfl_match_detail.dart';
import '../../../models/api/home/home_setup.dart';
import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/api/pkfl/pkfl_all_individual_stats.dart';
import '../../general/repository/crud_api_service.dart';

final pkflApiServiceProvider =
    Provider<PkflApiService>((ref) => PkflApiService());

class PkflApiService extends CrudApiService {

  Future<List<PkflMatchApiModel>> getPkflFixtures() async {
    final decodedBody =
    await getModelsWithVariableEndpoint<JsonAndHttpConverter>(
        pkflApi, null, "fixtures");
    return decodedBody.map((model) => model as PkflMatchApiModel).toList();
  }

  Future<List<PkflAllIndividualStats>> getPkflAllIndividualStats(bool currentSeason) async {
    final queryParameters = {
      'currentSeason': currentSeason.toString(),
    };
    final decodedBody =
    await getModelsWithoutGetAll<JsonAndHttpConverter>(pkflAllIndividualStatsApi, queryParameters);
    return decodedBody.map((model) => model as PkflAllIndividualStats).toList();
  }

  Future<PkflMatchDetail> getPkflMatchDetail(int pkflMatchId) async {
    final String url = "$serverUrl/$pkflApi/detail/$pkflMatchId";
    final PkflMatchDetail pkflMatchDetail = await executeGetRequest(
        Uri.parse(url),
            (dynamic json) => PkflMatchDetail.fromJson(json), null);
    return pkflMatchDetail;
  }
}
