import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/notification/repository/notification_api_service.dart';
import 'package:trus_app/features/notification/state/notification_list_state.dart';
import 'package:trus_app/models/api/notification/notification_api_model.dart';


final notificationsNotifierProvider = StateNotifierProvider.autoDispose<
    NotificationsNotifier, NotificationListState>((ref) {
  return NotificationsNotifier(
    ref,
    ref.read(notificationApiServiceProvider),
    ref.read(screenVariablesNotifierProvider.notifier),
  );
});

class NotificationsNotifier extends SafeStateNotifier<NotificationListState> {
  final NotificationApiService repository;
  final ScreenVariablesNotifier screenController;

  NotificationsNotifier(
    Ref ref,
    this.repository,
    this.screenController,
  ) : super(ref, NotificationListState.initial()) {
    Future.microtask(_loadNotifications);
  }

  Future<void> _loadNotifications() async {
    await guardSet<List<NotificationApiModel>>(
      action: () => runUiWithResult<List<NotificationApiModel>>(
        () => repository.getNotifications(state.pageNumber),
        showLoading: false,
        successSnack: null,
      ),
      reduce: (result) => state.copyWith(
          notifications: result,
          showPreviousButton: state.pageNumber != 0,
          showNextButton: result.value != null && result.value!.length == 20),
    );
  }

  Future<void> nextPage() async {
    state = state.copyWith(pageNumber: state.pageNumber + 1);
    await _loadNotifications();
  }

  Future<void> previousPage() async {
    state = state.copyWith(pageNumber: state.pageNumber - 1);
    await _loadNotifications();
  }
}
