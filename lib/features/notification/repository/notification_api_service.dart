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
import '../../../models/api/notification_api_model.dart';
import '../../../models/api/player_api_model.dart';
import '../../general/repository/crud_api_service.dart';

final notificationApiServiceProvider =
    Provider<NotificationApiService>((ref) => NotificationApiService());

class NotificationApiService extends CrudApiService {

  Future<List<NotificationApiModel>> getNotifications(int? page) async {
    final queryParameters = {
      'page': intToString(page),
    };
    final decodedBody = await getModels<JsonAndHttpConverter>(notificationApi, queryParameters);
    return decodedBody.map((model) => model as NotificationApiModel).toList();
  }
}
