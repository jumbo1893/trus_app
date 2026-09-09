import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/notification/repository/notification_api_service.dart';
import 'package:trus_app/features/notification/state/notification_list_state.dart';
import 'package:trus_app/services/crash_reporting_service.dart';

final notificationsNotifierProvider =
    StateNotifierProvider.autoDispose<
      NotificationsNotifier,
      NotificationListState
    >((ref) {
      return NotificationsNotifier(
        ref,
        ref.read(notificationApiServiceProvider),
        ref.read(screenVariablesNotifierProvider.notifier),
      );
    });

class NotificationsNotifier extends SafeStateNotifier<NotificationListState> {
  final NotificationApiService repository;
  final ScreenVariablesNotifier screenController;
  int _generation = 0;

  NotificationsNotifier(Ref ref, this.repository, this.screenController)
    : super(ref, NotificationListState.initial()) {
    Future.microtask(_loadNotifications);
  }

  Future<void> _loadNotifications() async {
    final generation = ++_generation;
    safeSetState(NotificationListState.initial());
    final result = await AsyncValue.guard(() => repository.getNotifications(0));
    if (!mounted || generation != _generation) return;
    if (result.hasError) {
      await CrashReportingService.recordError(
        result.error!,
        result.stackTrace!,
        reason: 'history.load',
      );
    }
    if (!mounted || generation != _generation) return;
    safeSetState(
      state.copyWith(
        notifications: result,
        showNextButton: result.valueOrNull?.length == 20,
      ),
    );
  }

  Future<void> reload() => _loadNotifications();

  Future<void> nextPage() async {
    if (state.loadingOlder ||
        !state.showNextButton ||
        !state.notifications.hasValue) {
      return;
    }
    final generation = _generation;
    final page = state.pageNumber + 1;
    safeSetState(state.copyWith(loadingOlder: true, olderFailed: false));
    try {
      final older = await repository.getNotifications(page);
      if (!mounted || generation != _generation) return;
      final rows = [...state.notifications.requireValue];
      final ids = rows.map((row) => row.id).toSet();
      rows.addAll(older.where((row) => ids.add(row.id)));
      safeSetState(
        state.copyWith(
          notifications: AsyncValue.data(rows),
          pageNumber: page,
          loadingOlder: false,
          showNextButton: older.length == 20,
        ),
      );
    } catch (error, stack) {
      await CrashReportingService.recordError(
        error,
        stack,
        reason: 'history.older',
      );
      if (!mounted || generation != _generation) return;
      safeSetState(state.copyWith(loadingOlder: false, olderFailed: true));
    }
  }
}
