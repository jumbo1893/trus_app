
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/achievement/achievement_api_model.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';

import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../general/repository/crud_api_service.dart';

final achievementApiServiceProvider =
    Provider<AchievementApiService>((ref) => AchievementApiService(ref));

class AchievementApiService extends CrudApiService {
  AchievementApiService(super.ref);


  Future<List<AchievementApiModel>> getAchievements() async {
    final decodedBody = await getModels<JsonAndHttpConverter>(playerApi, null);
    return decodedBody.map((model) => model as AchievementApiModel).toList();
  }

  Future<List<AchievementDetail>> getAllDetailed() async {
    final decodedBody =
    await getModelsWithVariableEndpoint<JsonAndHttpConverter>(
        achievementApi, null, "get-all-detailed");
    return decodedBody.map((model) => model as AchievementDetail).toList();
  }

  Future<AchievementDetail> getAchievementDetail(int id) async {
    final String url = "$serverUrl/$achievementApi/get-detail?playerAchievementId=$id";
    final AchievementDetail achievementDetail = await executeGetRequest(
        Uri.parse(url), (dynamic json) => AchievementDetail.fromJson(json), null);
    return achievementDetail;
  }

  Future<PlayerAchievementApiModel> editPlayerAchievement(PlayerAchievementApiModel playerAchievement, int id) async {
    final decodedBody = await editModel<JsonAndHttpConverter>(playerAchievement, id);
    return decodedBody as PlayerAchievementApiModel;
  }
}
