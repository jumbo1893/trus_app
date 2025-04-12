import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';

import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/api/notification_api_model.dart';
import '../../general/repository/crud_api_service.dart';

final notificationApiServiceProvider =
    Provider<NotificationApiService>((ref) => NotificationApiService(ref));

class NotificationApiService extends CrudApiService {
  NotificationApiService(super.ref);


  Future<List<NotificationApiModel>> getNotifications(int? page) async {
    final queryParameters = {
      'page': intToString(page),
    };
    final decodedBody = await getModels<JsonAndHttpConverter>(notificationApi, queryParameters);
    return decodedBody.map((model) => model as NotificationApiModel).toList();
  }
}
