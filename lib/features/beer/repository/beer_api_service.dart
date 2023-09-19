import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:trus_app/config.dart';

import '../../../models/api/beer/beer_api_model.dart';

import '../../../models/api/beer/beer_detailed_response.dart';
import '../../../models/api/beer/beer_list.dart';
import '../../../models/api/beer/beer_multi_add_response.dart';
import '../../../models/api/beer/beer_setup_response.dart';
import '../../general/repository/crud_api_service.dart';

final beerApiServiceProvider =
    Provider<BeerApiService>((ref) => BeerApiService());

class BeerApiService extends CrudApiService {
  Future<List<BeerApiModel>> getBeers() async {
    try {
      final response = await http.get(Uri.parse("$serverUrl/beer/get-all"));
      return (json.decode(response.body) as List)
          .map((e) => BeerApiModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<BeerSetupResponse> setupBeers(int? matchId, int? seasonId) async {
    final queryParameters = {
      'seasonId': intToString(seasonId),
      'matchId': intToString(matchId),
    };
    const String url = "$serverUrl/$beerApi/setup";
    final BeerSetupResponse beerSetupResponse = await executeGetRequest(
        Uri.parse(url),
        (dynamic json) => BeerSetupResponse.fromJson(json),
        queryParameters);
    return beerSetupResponse;
  }

  Future<BeerMultiAddResponse> addBeers(BeerList beerList) async {
    final Map<String, dynamic> requestPayload = beerList.toJson();
    const String url = "$serverUrl/$beerApi/multiple-add";
    final BeerMultiAddResponse response = await executePostRequest(
        Uri.parse(url),
        (dynamic json) => BeerMultiAddResponse.fromJson(json),
        jsonEncode(requestPayload));
    return response;
  }

  Future<BeerDetailedResponse> getDetailedBeer(int? matchId, int? seasonId,
      int? playerId, bool? matchStatsOrPlayerStats, String? filter) async {
    final queryParameters = {
      'seasonId': intToString(seasonId),
      'matchId': intToString(matchId),
      'playerId': intToString(playerId),
      'matchStatsOrPlayerStats': boolToString(matchStatsOrPlayerStats),
      'stringFilter': filter,
    };
    const String url = "$serverUrl/$beerApi/get-all-detailed";
    final BeerDetailedResponse beerDetailedResponse = await executeGetRequest(
        Uri.parse(url),
        (dynamic json) => BeerDetailedResponse.fromJson(json),
        queryParameters);
    return beerDetailedResponse;
  }
}
