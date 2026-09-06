import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/app_notice/repository/app_notice_repository.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/home/controller/home_notifier.dart';
import 'package:trus_app/features/home/repository/home_repository.dart';
import 'package:trus_app/features/main/ui/ui_feedback_notifier.dart';
import 'package:trus_app/features/match_participation/repository/match_participation_repository.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';
import 'package:trus_app/models/api/app_notice/app_notice.dart';
import 'package:trus_app/models/api/home/home_setup.dart';

class _Unused
    implements PlayerRepository, AuthRepository, MatchParticipationRepository {
  @override
  Never get api => throw UnimplementedError();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Notices implements AppNoticeRepository {
  @override
  Future<AppNotice?> fetchCurrent() async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Home implements HomeRepository {
  final cached = HomeSetup.fromJson({});
  Completer<HomeSetup>? pending;
  int requests = 0;
  @override
  HomeSetup? getCachedSetup() => cached;
  @override
  Future<HomeSetup> fetchSetup() async {
    requests++;
    return pending == null ? cached : await pending!.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'resume requests share a fetch and failure preserves data without UI errors',
    () async {
      final repository = _Home();
      final unused = _Unused();
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(repository),
          playerRepositoryProvider.overrideWithValue(unused),
          authRepositoryProvider.overrideWithValue(unused),
          appNoticeRepositoryProvider.overrideWithValue(_Notices()),
          matchParticipationRepositoryProvider.overrideWithValue(unused),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(homeNotifierProvider, (_, __) {});
      addTearDown(subscription.close);
      await Future<void>.delayed(Duration.zero);
      final notifier = container.read(homeNotifierProvider.notifier);
      final before = container.read(homeNotifierProvider).setup;
      final effects = container.read(uiFeedbackProvider).effects;
      final count = repository.requests;
      repository.pending = Completer<HomeSetup>();
      final first = notifier.load(background: true);
      final second = notifier.load(background: true);
      expect(identical(first, second), isTrue);
      expect(repository.requests, count + 1);
      repository.pending!.completeError(StateError('offline'));
      await Future.wait([first, second]);
      expect(container.read(homeNotifierProvider).setup, same(before));
      expect(container.read(uiFeedbackProvider).effects, effects);
      repository.pending = null;
      await notifier.load(background: true);
      expect(repository.requests, count + 2);
    },
  );
}
