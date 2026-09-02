import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/models/api/notification/push/enabled_push_notification.dart';
import 'package:trus_app/models/api/notification/push/notification_type.dart';

void main() {
  test('achievement progress notification type round-trips to server', () {
    expect(
      notificationTypeFromServer('ACHIEVEMENT_PROGRESS'),
      NotificationType.achievementProgress,
    );
    expect(
      notificationTypeToServer(NotificationType.achievementProgress),
      'ACHIEVEMENT_PROGRESS',
    );
  });

  test('achievement progress notification has a settings label', () {
    final notification = EnabledPushNotification(
      id: 1,
      type: NotificationType.achievementProgress,
      enabled: true,
      userId: 2,
      modificationTime: DateTime(2026),
    );

    expect(
      notification.listViewTitle(),
      'Když jsem blízko splnění achievementu',
    );
  });
}
