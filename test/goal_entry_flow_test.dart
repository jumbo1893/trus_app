import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trus_app/features/goal/controller/goal_notifier.dart';
import 'package:trus_app/features/goal/repository/goal_api_service.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/models/api/goal/goal_list_multi_add.dart';
import 'package:trus_app/models/api/goal/goal_multi_add_response.dart';
import 'package:trus_app/models/api/goal/goal_setup.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class _Api implements GoalApiService {
  _Api({this.players = 1});
  final int players;
  bool fail = false;
  int saves = 0;
  @override
  Future<List<GoalSetup>> setupGoal(int id) async => [
    for (var i = 0; i < players; i++)
      GoalSetup(
        goalNumber: 0,
        assistNumber: 0,
        player: PlayerApiModel(
          id: i + 1,
          name: 'Hráč $i',
          birthday: DateTime(2000),
          fan: false,
          active: true,
        ),
      ),
  ];
  @override
  Future<GoalMultiAddResponse> addMultipleGoals(
    GoalListMultiAdd payload,
  ) async {
    saves++;
    if (fail) throw StateError('offline');
    return GoalMultiAddResponse(
      totalGoalsAdded: 1,
      totalAssistAdded: 1,
      match: 'Soupeř',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final fail in [false, true]) {
    test(
      'goals and assists save automatically and preserve draft on failure=$fail',
      () async {
        SharedPreferences.setMockInitialValues({
          'userEmail': 'test@example.test',
        });
        final api = _Api()..fail = fail;
        final container = ProviderContainer(
          overrides: [goalApiServiceProvider.overrideWithValue(api)],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(goalNotifierProvider, (_, __) {});
        addTearDown(subscription.close);
        final notifier = container.read(goalNotifierProvider.notifier);
        await notifier.setupMatch(5);
        expect(notifier.hasChanges, isFalse);
        notifier.addNumber(0, true);
        notifier.addNumber(0, false);
        expect(api.saves, greaterThan(0));
        final route = container.read(screenNotifierProvider).currentScreenId;
        if (fail) {
          await expectLater(
            notifier.changeGoals(navigate: false),
            throwsA(isA<Exception>()),
          );
          expect(notifier.hasChanges, isTrue);
        } else {
          await notifier.changeGoals(navigate: false);
          expect(notifier.hasChanges, isFalse);
        }
        expect(container.read(screenNotifierProvider).currentScreenId, route);
        expect(
          container.read(goalNotifierProvider).setups.single.assistNumber,
          1,
        );
      },
    );
  }

  test(
    'removing a goalkeeper clears his minutes and redistributes 60',
    () async {
      SharedPreferences.setMockInitialValues({
        'userEmail': 'test@example.test',
      });
      final container = ProviderContainer(
        overrides: [goalApiServiceProvider.overrideWithValue(_Api(players: 3))],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(goalNotifierProvider, (_, __) {});
      addTearDown(subscription.close);
      final notifier = container.read(goalNotifierProvider.notifier);
      await notifier.setupMatch(5);
      notifier.toggleGoalkeeper(0);
      notifier.toggleGoalkeeper(1);
      notifier.toggleGoalkeeper(2);
      expect(
        container
            .read(goalNotifierProvider)
            .setups
            .map((p) => p.goalkeepingMinutes),
        [20, 20, 20],
      );
      notifier.toggleGoalkeeper(1);
      expect(
        container
            .read(goalNotifierProvider)
            .setups
            .map((p) => p.goalkeepingMinutes),
        [30, 0, 30],
      );
    },
  );
}
