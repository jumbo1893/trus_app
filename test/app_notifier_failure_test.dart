import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/common/repository/exception/model/login_expired_exception.dart';
import 'package:trus_app/common/repository/exception/server_exception.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import 'package:trus_app/features/general/repository/api_result.dart';
import 'package:trus_app/features/main/ui/ui_feedback_notifier.dart';

class _Notifier extends AppNotifier<int> {
  _Notifier(Ref ref) : super(ref, 0);
}

final _provider = StateNotifierProvider<_Notifier, int>(
  (ref) => _Notifier(ref),
);

void main() {
  test('background refresh can keep cached data without error effects', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(_provider.notifier);
    final result = await notifier.runUi<int>(
      () async => throw ServerException('offline'),
      showLoading: false,
      showErrors: false,
    );
    expect(result, isA<ApiError<int>>());
    expect(container.read(uiFeedbackProvider).effects, isEmpty);
    expect(container.read(uiFeedbackProvider).isLoading, isFalse);
  });
  test('expired login returns a handled result and releases loading', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final result = await container
        .read(_provider.notifier)
        .runUi<int>(() async => throw LoginExpiredException());
    expect(result, isA<LoginExpired<int>>());
    expect(container.read(uiFeedbackProvider).isLoading, isFalse);
    expect(container.read(uiFeedbackProvider).effects, hasLength(1));
  });
  test(
    'request completing after disposal does not use a disposed ref or display errors',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(_provider.notifier);
      final pending = Completer<int>();
      final request = notifier.runUi(() => pending.future);
      container.invalidate(_provider);
      pending.completeError(ServerException('offline'));
      expect(await request, isA<ApiError<int>>());
      expect(container.read(uiFeedbackProvider).effects, isEmpty);
      expect(container.read(uiFeedbackProvider).isLoading, isFalse);
    },
  );
}
