import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/notification/controller/notifications_notifier.dart';
import 'package:trus_app/features/notification/repository/notification_api_service.dart';
import 'package:trus_app/features/notification/screen/notification_screen.dart';
import 'package:trus_app/models/api/notification/notification_api_model.dart';
import 'package:trus_app/theme/app_theme.dart';

NotificationApiModel row(int id) => NotificationApiModel(
  id: id,
  userName: 'Jan',
  date: DateTime(2026, 9, 9),
  title: 'Úkon $id',
  text: 'Zápis piv',
);

class HistoryApi implements NotificationApiService {
  final calls = <int>[];
  Completer<List<NotificationApiModel>>? older;
  bool empty = false;
  @override
  Future<List<NotificationApiModel>> getNotifications(int? page) async {
    calls.add(page!);
    if (page == 0) return empty ? [] : List.generate(20, (i) => row(40 - i));
    return older!.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'older history appends once, preserves rows on failure and retries same page',
    () async {
      final api = HistoryApi();
      final container = ProviderContainer(
        overrides: [notificationApiServiceProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);
      container.listen(notificationsNotifierProvider, (_, __) {});
      await Future<void>.delayed(Duration.zero);
      final notifier = container.read(notificationsNotifierProvider.notifier);
      api.older = Completer();
      final pending = notifier.nextPage();
      await notifier.nextPage();
      expect(api.calls, [0, 1]);
      expect(
        container
            .read(notificationsNotifierProvider)
            .notifications
            .requireValue
            .length,
        20,
      );
      api.older!.completeError(StateError('technical network failure'));
      await pending;
      expect(container.read(notificationsNotifierProvider).olderFailed, isTrue);
      expect(container.read(notificationsNotifierProvider).pageNumber, 0);
      api.older = Completer();
      final retry = notifier.nextPage();
      api.older!.complete([row(21), row(20)]);
      await retry;
      final state = container.read(notificationsNotifierProvider);
      expect(state.notifications.requireValue.length, 21);
      expect(state.notifications.requireValue.last.id, 20);
      expect(state.showNextButton, isFalse);
      expect(api.calls, [0, 1, 1]);
    },
  );
  test('refresh invalidates pending older request', () async {
    final api = HistoryApi();
    final container = ProviderContainer(
      overrides: [notificationApiServiceProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);
    container.listen(notificationsNotifierProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);
    final notifier = container.read(notificationsNotifierProvider.notifier);
    api.older = Completer();
    final pending = notifier.nextPage();
    await notifier.reload();
    api.older!.complete([row(1)]);
    await pending;
    expect(
      container
          .read(notificationsNotifierProvider)
          .notifications
          .requireValue
          .length,
      20,
    );
    expect(container.read(notificationsNotifierProvider).pageNumber, 0);
  });
  testWidgets('empty history explains its scope without pagination arrows', (
    tester,
  ) async {
    final api = HistoryApi()..empty = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [notificationApiServiceProvider.overrideWithValue(api)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const NotificationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Nejde o úplný přehled'), findsOneWidget);
    expect(
      find.text('Zatím tu nejsou žádné zaznamenané úkony.'),
      findsOneWidget,
    );
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
