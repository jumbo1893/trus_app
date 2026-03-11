import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/notification/push/enabled_push_notification.dart';


class EnabledNotificationsState {
  final AsyncValue<List<EnabledPushNotification>> enabledNotifications;

  EnabledNotificationsState({
    required this.enabledNotifications,
  });

  factory EnabledNotificationsState.initial() => EnabledNotificationsState(
        enabledNotifications: const AsyncValue.loading(),
      );

  EnabledNotificationsState copyWith({
    AsyncValue<List<EnabledPushNotification>>? enabledNotifications,
  }) {
    return EnabledNotificationsState(
      enabledNotifications: enabledNotifications ?? this.enabledNotifications,
    );
  }
}
