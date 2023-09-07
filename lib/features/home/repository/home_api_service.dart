import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:trus_app/common/repository/exception/bad_format_exception.dart';
import 'package:trus_app/common/repository/exception/server_exception.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/goal/goal_list_multi_add.dart';
import 'package:trus_app/models/api/goal/goal_setup.dart';
import 'package:trus_app/models/api/match/match_setup.dart';

import '../../../common/repository/exception/json_decode_exception.dart';
import '../../../models/api/fine_api_model.dart';
import '../../../models/api/goal/goal_api_model.dart';
import '../../../models/api/goal/goal_detailed_response.dart';
import '../../../models/api/goal/goal_multi_add_response.dart';
import '../../../models/api/home_setup.dart';
import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../general/repository/crud_api_service.dart';
import '../../general/repository/request_executor.dart';

final homeApiServiceProvider =
    Provider<HomeApiService>((ref) => HomeApiService());

class HomeApiService extends CrudApiService {

  Future<HomeSetup> setupHome() async {
    const String url = "$serverUrl/$homeApi/setup";
    final HomeSetup homeSetup = await executeGetRequest(
        Uri.parse(url),
            (dynamic json) => HomeSetup.fromJson(json),
        null);
    return homeSetup;
  }
}
