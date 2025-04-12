import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';

import '../../../models/api/home/home_setup.dart';
import '../../general/repository/crud_api_service.dart';

final homeApiServiceProvider =
    Provider<HomeApiService>((ref) => HomeApiService(ref));

class HomeApiService extends CrudApiService {
  HomeApiService(super.ref);


  Future<HomeSetup> setupHome() async {
    const String url = "$serverUrl/$homeApi/setup";
    final HomeSetup homeSetup = await executeGetRequest(
        Uri.parse(url),
            (dynamic json) => HomeSetup.fromJson(json), null);
    return homeSetup;
  }
}
