
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/notification/push/enabled_push_notification.dart';

class PushPermissionInfo {
  final AuthorizationStatus authorizationStatus;
  final String? token;
  final bool backendSynced;

  const PushPermissionInfo({
    required this.authorizationStatus,
    required this.token,
    required this.backendSynced,
  });

  bool get allowed =>
      authorizationStatus == AuthorizationStatus.authorized ||
          authorizationStatus == AuthorizationStatus.provisional;

  bool get denied => authorizationStatus == AuthorizationStatus.denied;

  bool get notDetermined =>
      authorizationStatus == AuthorizationStatus.notDetermined;

  bool get hasToken => token != null && token!.isNotEmpty;

  bool get ready => allowed && hasToken && backendSynced;

  String get authorizationLabel {
    switch (authorizationStatus) {
      case AuthorizationStatus.authorized:
        return "Povoleno";
      case AuthorizationStatus.provisional:
        return "Povoleno částečně";
      case AuthorizationStatus.denied:
        return "Zakázáno";
      case AuthorizationStatus.notDetermined:
        return "Zatím nerozhodnuto";
    }
  }
}

class EnabledNotificationsState {
  final AsyncValue<List<EnabledPushNotification>> enabledNotifications;
  final AsyncValue<PushPermissionInfo> pushPermissionInfo;
  final bool sendingTestPush;
  final bool refreshingPushStatus;

  EnabledNotificationsState({
    required this.enabledNotifications,
    required this.pushPermissionInfo,
    required this.sendingTestPush,
    required this.refreshingPushStatus,
  });

  factory EnabledNotificationsState.initial() => EnabledNotificationsState(
    enabledNotifications: const AsyncValue.loading(),
    pushPermissionInfo: const AsyncValue.loading(),
    sendingTestPush: false,
    refreshingPushStatus: false,
  );

  EnabledNotificationsState copyWith({
    AsyncValue<List<EnabledPushNotification>>? enabledNotifications,
    AsyncValue<PushPermissionInfo>? pushPermissionInfo,
    bool? sendingTestPush,
    bool? refreshingPushStatus,
  }) {
    return EnabledNotificationsState(
      enabledNotifications: enabledNotifications ?? this.enabledNotifications,
      pushPermissionInfo: pushPermissionInfo ?? this.pushPermissionInfo,
      sendingTestPush: sendingTestPush ?? this.sendingTestPush,
      refreshingPushStatus: refreshingPushStatus ?? this.refreshingPushStatus,
    );
  }
}