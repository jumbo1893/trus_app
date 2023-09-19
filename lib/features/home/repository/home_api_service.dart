import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import '../../../models/api/home/home_setup.dart';
import '../../general/repository/crud_api_service.dart';

final homeApiServiceProvider =
    Provider<HomeApiService>((ref) => HomeApiService());

class HomeApiService extends CrudApiService {

  Future<HomeSetup> setupHome(int? playerId) async {
    final queryParameters = {
      'playerId': intToString(playerId),
    };
    const String url = "$serverUrl/$homeApi/setup";
    final HomeSetup homeSetup = await executeGetRequest(
        Uri.parse(url),
            (dynamic json) => HomeSetup.fromJson(json),
        queryParameters);
    return homeSetup;
  }
}
