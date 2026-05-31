import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/notification/repository/notification_api_service.dart';

import '../../../../models/api/notification/push/enabled_push_notification.dart';
import '../../../../services/push/notifications_service.dart';
import '../../../general/notifier/safe_state_notifier.dart';
import '../../../main/controller/screen_notifier.dart';
import '../state/enabled_notifications_state.dart';

final enabledNotificationsNotifierProvider = StateNotifierProvider<
    EnabledNotificationsNotifier, EnabledNotificationsState>((ref) {
  return EnabledNotificationsNotifier(
    ref: ref,
    repository: ref.read(notificationApiServiceProvider),
    screenController: ref.read(screenNotifierProvider.notifier),
  );
});

class EnabledNotificationsNotifier
    extends SafeStateNotifier<EnabledNotificationsState> {
  final NotificationApiService repository;
  final ScreenNotifier screenController;

  EnabledNotificationsNotifier({
    required Ref ref,
    required this.repository,
    required this.screenController,
  }) : super(ref, EnabledNotificationsState.initial()) {
    Future.microtask(() async {
      await load();
    });
  }

  Future<void> load() async {
    await Future.wait([
      loadEnabledNotifications(),
      refreshPushPermissionInfo(),
    ]);
  }

  Future<void> loadEnabledNotifications() async {
    state = state.copyWith(
      enabledNotifications: const AsyncValue.loading(),
    );

    try {
      final notifications = await repository.getEnabledNotifications();

      state = state.copyWith(
        enabledNotifications: AsyncValue.data(notifications),
      );
    } catch (e, st) {
      state = state.copyWith(
        enabledNotifications: AsyncValue.error(e, st),
      );
    }
  }

  Future<void> refreshPushPermissionInfo() async {
    state = state.copyWith(
      refreshingPushStatus: true,
    );

    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();

      String? token;
      bool backendSynced = false;

      final notificationsAllowed =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      if (notificationsAllowed) {
        token = await NotificationsService.syncCurrentTokenWithBackend(ref);
        backendSynced = token != null && token.isNotEmpty;
      } else {
        token = null;
      }

      state = state.copyWith(
        pushPermissionInfo: AsyncValue.data(
          PushPermissionInfo(
            authorizationStatus: settings.authorizationStatus,
            token: token,
            backendSynced: backendSynced,
          ),
        ),
      );
    } catch (e, st) {
      state = state.copyWith(
        pushPermissionInfo: AsyncValue.error(e, st),
      );
    } finally {
      state = state.copyWith(
        refreshingPushStatus: false,
      );
    }
  }

  Future<void> requestPermissionAndRefresh() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      await refreshPushPermissionInfo();
    } catch (e, st) {
      state = state.copyWith(
        pushPermissionInfo: AsyncValue.error(e, st),
      );
    }
  }

  Future<void> sendTestPushToThisDevice() async {
    state = state.copyWith(
      sendingTestPush: true,
    );

    try {
      await runUiWithResult<void>(
            () => NotificationsService.sendTestPushToThisDevice(ref),
        showLoading: false,
        successSnack: "Testovací pushka odeslána",
      );

      await refreshPushPermissionInfo();
    } finally {
      state = state.copyWith(
        sendingTestPush: false,
      );
    }
  }

  void changeEnabledNotification(
      EnabledPushNotification notification,
      bool value,
      ) {
    final currentValue = state.enabledNotifications.valueOrNull;

    if (currentValue == null) {
      return;
    }

    final updatedList = currentValue.map((item) {
      if (item.id == notification.id) {
        return item.copyWith(enabled: value);
      }

      return item;
    }).toList();

    state = state.copyWith(
      enabledNotifications: AsyncValue.data(updatedList),
    );
  }

  Future<void> commit() async {
    final currentValue = state.enabledNotifications.valueOrNull;

    if (currentValue == null) {
      return;
    }

    await runUiWithResult<void>(
          () async {
        await repository.editNotificationsPermit(currentValue);
      },
      successSnack: "Nastavení oznámení uloženo",
    );

    await loadEnabledNotifications();
  }

  Future<void> reload() async {
    await load();
  }
}