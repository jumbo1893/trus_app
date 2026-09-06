import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/repository/football_api_service.dart';
import 'package:trus_app/features/football/repository/football_repository.dart';
import 'package:trus_app/features/general/cache/memory_cache.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/main/ui/ui_feedback_notifier.dart';
import 'package:trus_app/features/match/screens/match_detail_screen.dart';
import 'package:trus_app/models/api/football/detail/football_match_detail.dart';
import 'package:trus_app/models/api/notification/push/push_payload.dart';
import 'package:trus_app/services/push/push_navigation_handler.dart';
import 'package:trus_app/features/achievement/achievement_view_args.dart';
import 'package:trus_app/features/achievement/controller/achievement_edit_notifier.dart';
import 'package:trus_app/features/achievement/repository/achievement_repository.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';

class _FootballApi implements FootballApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingAchievements implements AchievementRepository {
  @override
  AchievementDetail? getCachedDetail(int id) => null;
  @override
  Future<AchievementDetail> fetchDetail(int id) async =>
      throw StateError('offline');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('football push clears only its detail and opens the target', (
    tester,
  ) async {
    final cache = MemoryCache();
    final repository = FootballRepository(_FootballApi(), cache);
    cache.set('football_detail-42', FootballMatchDetail.dummy());
    final other = FootballMatchDetail.dummy();
    cache.set('football_detail-43', other);
    final container = ProviderContainer(
      overrides: [footballRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    PushNavigationHandler.navigate(
      PushNavigationRef(read: container.read, invalidate: container.invalidate),
      PushPayload.fromData({
        'screenId': MatchDetailScreen.id,
        'footballMatchId': '42',
      }),
    );
    expect(repository.getCachedFootballMatchDetail(42), isNull);
    expect(repository.getCachedFootballMatchDetail(43), same(other));
    expect(container.read(screenVariablesNotifierProvider).footballMatchId, 42);
    expect(
      container.read(screenNotifierProvider).currentScreenId,
      MatchDetailScreen.id,
    );
    tester.binding.scheduleFrame();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(container.read(uiFeedbackProvider).isLoading, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'failed achievement initialization reports UI error without uncaught exception',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          achievementRepositoryProvider.overrideWithValue(
            _FailingAchievements(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final provider = achievementViewProvider(
        AchievementViewArgs.player(PlayerAchievementApiModel.dummy()),
      );
      final subscription = container.listen(provider, (_, __) {});
      addTearDown(subscription.close);
      await tester.pump();
      expect(container.read(uiFeedbackProvider).isLoading, isFalse);
      expect(container.read(uiFeedbackProvider).effects, hasLength(1));
      expect(container.read(provider).model, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
