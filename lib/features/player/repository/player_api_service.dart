import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:trus_app/common/repository/exception/bad_format_exception.dart';
import 'package:trus_app/common/repository/exception/server_exception.dart';
import 'package:trus_app/config.dart';

import '../../../common/repository/exception/json_decode_exception.dart';
import '../../../models/api/beer/beer_api_model.dart';
import 'package:sse_channel/sse_channel.dart';

import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/api/player_api_model.dart';
import '../../general/repository/crud_api_service.dart';

final playerApiServiceProvider =
    Provider<PlayerApiService>((ref) => PlayerApiService());

class PlayerApiService extends CrudApiService {

  Future<List<PlayerApiModel>> getPlayers() async {
    final decodedBody = await getModels<JsonAndHttpConverter>(playerApi, null);
    return decodedBody.map((model) => model as PlayerApiModel).toList();
  }

  Future<PlayerApiModel> addPlayer(PlayerApiModel player) async {
    final decodedBody = await addModel<JsonAndHttpConverter>(player);
    return decodedBody as PlayerApiModel;
  }

  Future<PlayerApiModel> editPlayer(PlayerApiModel player, int id) async {
    final decodedBody = await editModel<JsonAndHttpConverter>(player, id);
    return decodedBody as PlayerApiModel;
  }

  Future<bool> deletePlayer(int id) async {
    return await deleteModel(id, playerApi);
  }
}
