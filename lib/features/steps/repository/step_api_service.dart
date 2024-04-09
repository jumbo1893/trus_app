import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/api/step/step_api_model.dart';
import '../../general/repository/crud_api_service.dart';

final stepApiServiceProvider =
    Provider<StepApiService>((ref) => StepApiService());

class StepApiService extends CrudApiService {
  /*Future<List<MatchApiModel>> getMatches() async {
    final decodedBody = await getModels<JsonAndHttpConverter>(matchApi, null);
    return decodedBody.map((model) => model as MatchApiModel).toList();
  }*/


  Future<StepApiModel> addStep(StepApiModel step) async {
    final decodedBody = await addModel<JsonAndHttpConverter>(step);
    return decodedBody as StepApiModel;
  }

}
