import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';

import '../../../models/api/fine_api_model.dart';
import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../general/repository/crud_api_service.dart';


final fineApiServiceProvider =
    Provider<FineApiService>((ref) => FineApiService(ref));

class FineApiService extends CrudApiService {
  FineApiService(super.ref);


  Future<List<FineApiModel>> getFines() async {
    final decodedBody = await getModels<JsonAndHttpConverter>(fineApi, null);
    return decodedBody.map((model) => model as FineApiModel).toList();
  }

  Future<FineApiModel> addFine(FineApiModel fine) async {
    final decodedBody = await addModel<JsonAndHttpConverter>(fine);
    return decodedBody as FineApiModel;
  }

  Future<FineApiModel> editFine(FineApiModel fine, int id) async {
    final decodedBody = await editModel<JsonAndHttpConverter>(fine, id);
    return decodedBody as FineApiModel;
  }

  Future<bool> deleteFine(int id) async {
    return await deleteModel(id, fineApi);
  }
}
