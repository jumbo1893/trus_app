import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';

import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/api/notification/notification_api_model.dart';
import '../../../models/api/notification/push/enabled_push_notification.dart';
import '../../../models/helper/title_and_text.dart';
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

  Future<List<EnabledPushNotification>> getEnabledNotifications() async {
    final decodedBody = await getModels<JsonAndHttpConverter>(pushEnabledApi, null);
    return decodedBody.map((model) => model as EnabledPushNotification).toList();
  }

  Future<TitleAndText> editNotificationsPermit(List<EnabledPushNotification> enabledNotifications) async {
    final url = Uri.parse("$serverUrl/$pushEnabledApi/set");
    final payload = enabledNotifications.map((e) => e.toJson()).toList();
    return executePutRequest<TitleAndText>(
      url,
          (json) => TitleAndText.fromJson(json as Map<String, dynamic>),
      jsonEncode(payload),
    );
  }
}
