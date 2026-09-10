import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/home/screens/rotating_stats_widget.dart';
import 'package:trus_app/models/api/helper/redirect/redirect_api_model.dart';
import 'package:trus_app/models/api/home/stats_board_data.dart';
import 'package:trus_app/models/api/home/stats_board_row.dart';
import 'package:trus_app/theme/app_theme.dart';

RedirectApiModel earned() => RedirectApiModel.fromJson({
  'redirect': 'ACHIEVEMENTS',
  'playerAchievement': {
    'id': 123,
    'achievement': {'id': 8, 'name': 'Střelec'},
    'player': {'id': 42, 'name': 'Jan', 'birthday': '1990-01-01'},
    'accomplished': true,
  },
});
void main() {
  test('fine information opens fines with the original match', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(screenNotifierProvider.notifier)
        .redirect(
          RedirectApiModel.fromJson({
            'redirect': 'PLAYER_FINE_STATS',
            'match': {
              'id': 55,
              'name': 'Soupeř',
              'date': '2026-09-10',
              'seasonId': 3,
              'home': true,
              'playerIdList': <int>[],
            },
          }),
        );
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(screenNotifierProvider).currentScreenId,
      'fine-match-screen',
    );
    expect(container.read(screenVariablesNotifierProvider).matchId, 55);
  });
  test(
    'achievement opens the earned record and back returns to dashboard',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final navigation = container.read(screenNotifierProvider.notifier);
      final home = container.read(screenNotifierProvider).currentScreenId;
      navigation.redirect(earned());
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(screenNotifierProvider).currentScreenId,
        'view-player-achievement-detail-screen',
      );
      expect(
        container.read(screenVariablesNotifierProvider).playerAchievement.id,
        123,
      );
      expect(
        container
            .read(screenVariablesNotifierProvider)
            .playerAchievement
            .player
            .id,
        42,
      );
      await navigation.onBackButtonTap();
      expect(container.read(screenNotifierProvider).currentScreenId, home);
    },
  );
  test(
    'legacy achievement link opens list and unsupported links are inactive',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(screenNotifierProvider.notifier)
          .redirect(RedirectApiModel.fromJson({'redirect': 'ACHIEVEMENTS'}));
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(screenNotifierProvider).currentScreenId,
        'achievement-screen',
      );
      expect(
        RedirectApiModel.fromJson({'redirect': 'FUTURE_ROUTE'}).canNavigate,
        isFalse,
      );
    },
  );
  testWidgets('rotating achievement row forwards the exact earned record', (
    tester,
  ) async {
    RedirectApiModel? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: RotatingStatsWidget(
            statsBoards: [
              StatsBoardData(
                title: 'Poslední achievementy',
                headers: ['Jméno', 'Achievement', 'Datum'],
                rows: [
                  StatsBoardRow(
                    columns: ['Jan', 'Střelec', '10.09.2026'],
                    redirect: earned(),
                  ),
                ],
              ),
            ],
            onRedirect: (redirect) => selected = redirect,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Střelec'));
    expect(selected?.playerAchievement?.id, 123);
    expect(tester.takeException(), isNull);
  });
}
