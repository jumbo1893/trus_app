import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/config.dart';

import '../../interfaces/json_and_http_converter.dart';
import '../../interfaces/model_to_string.dart';
import 'notification_type.dart';

class EnabledPushNotification implements JsonAndHttpConverter, ModelToString {
  final int id;
  final NotificationType type;
  bool enabled;
  final int userId;
  final DateTime modificationTime;

  EnabledPushNotification({
    required this.id,
    required this.type,
    required this.enabled,
    required this.userId,
    required this.modificationTime,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": notificationTypeToServer(type),
      "enabled": enabled,
      "userId": userId,
      "modificationTime": formatDateForJson(modificationTime),
    };
  }

  @override
  @override
  factory EnabledPushNotification.fromJson(Map<String, dynamic> json) {
    return EnabledPushNotification(
      id: (json['id'] as num?)?.toInt() ?? -1,
      type: notificationTypeFromServer(json['type']),
      enabled: json['enabled'] as bool? ?? true,
      userId: (json['userId'] as num?)?.toInt() ?? -1,
      modificationTime: DateTime.parse(json['modificationTime']),
    );
  }

  @override
  String httpRequestClass() {
    return pushEnabledApi;
  }

  @override
  int getId() {
    return id;
  }

  @override
  String listViewTitle() {
      switch (type) {
        case NotificationType.global:
          return 'Chci dostávat upozornění';
        case NotificationType.threeDaysBefore:
          return 'Když jsou 3 dny do zápasu';
        case NotificationType.oneDayBefore:
          return 'Když je 24 hodin do zápasu';
        case NotificationType.afterResult:
          return 'Když je známý výsledek zápasu';
        case NotificationType.refereeComment:
          return 'Když nahraje rozhodčí komentář';
        case NotificationType.beer:
          return 'Když mi připíšou pivko';
        case NotificationType.fine:
          return 'Když dostanu pokutu';
        case NotificationType.unknown:
          return 'Neznámá';
      }
  }

  @override
  String toStringForAdd() {
    // TODO: implement toStringForAdd
    throw UnimplementedError();
  }

  @override
  String toStringForConfirmationDelete() {
    // TODO: implement toStringForConfirmationDelete
    throw UnimplementedError();
  }

  @override
  String toStringForEdit(String originName) {
    // TODO: implement toStringForEdit
    throw UnimplementedError();
  }

  @override
  String toStringForListView() {
    // TODO: implement toStringForListView
    throw UnimplementedError();
  }

  @override
  String toString() {
    return 'EnabledPushNotification{id: $id, type: $type, enabled: $enabled, userId: $userId, modificationTime: $modificationTime}';
  }
}
