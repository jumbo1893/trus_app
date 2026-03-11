import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/notification/push/state/enabled_notifications_state.dart';
import 'package:trus_app/features/notification/repository/notification_api_service.dart';
import 'package:trus_app/models/api/notification/push/enabled_push_notification.dart';
import 'package:trus_app/models/helper/title_and_text.dart';

import '../../../../models/api/notification/push/notification_type.dart';
import '../../../home/screens/home_screen.dart';


final enabledNotificationsNotifierProvider = StateNotifierProvider.autoDispose<
    EnabledNotificationsNotifier, EnabledNotificationsState>((ref) {
  return EnabledNotificationsNotifier(
    ref,
    ref.read(notificationApiServiceProvider),
    ref.read(screenVariablesNotifierProvider.notifier),
  );
});

class EnabledNotificationsNotifier extends SafeStateNotifier<EnabledNotificationsState> {
  final NotificationApiService repository;
  final ScreenVariablesNotifier screenController;

  EnabledNotificationsNotifier(
    Ref ref,
    this.repository,
    this.screenController,
  ) : super(ref, EnabledNotificationsState.initial()) {
    Future.microtask(_loadNotifications);
  }

  Future<void> _loadNotifications() async {
    await guardSet<List<EnabledPushNotification>>(
      action: () => runUiWithResult<List<EnabledPushNotification>>(
        () => repository.getEnabledNotifications(),
        showLoading: false,
        successSnack: null,
      ),
      reduce: (result) => state.copyWith(
          enabledNotifications: result,
    ));
  }

  void setNotification(bool boolean, NotificationType type) {
    if(type == NotificationType.global) {
      for(EnabledPushNotification enabledPushNotification in state.enabledNotifications.value ?? []) {
        if(enabledPushNotification.type != NotificationType.global) {
          _setNotification(boolean, enabledPushNotification.type);
        }
      }
    }
    else {
      if(boolean) {
        _setNotification(boolean, NotificationType.global);
      }
    }
    _setNotification(boolean, type);
  }

  void _setNotification(bool boolean, NotificationType type) {
    List<EnabledPushNotification> enabledNotifications = state
        .enabledNotifications.value ?? [];
    enabledNotifications
        .firstWhere((element) => element.type == type)
        .enabled = boolean;
    state = state.copyWith(
        enabledNotifications: AsyncValue.data(enabledNotifications));
  }

  Future<void> commit() async {
    runUiWithResult<TitleAndText>(
          () => repository.editNotificationsPermit(state.enabledNotifications.value ?? []),
      showLoading: true,
      successSnack: "Povolení na pushky úspěšně upraveny",
    );
    changeFragment(HomeScreen.id);
  }
}
