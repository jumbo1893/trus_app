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
  bool fail = false;
  int saves = 0;
  @override
  Future<List<GoalSetup>> setupGoal(int id) async => [
    GoalSetup(goalNumber: 0, assistNumber: 0, player: PlayerApiModel.dummy()),
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
      'goals save only on confirmation and preserve draft on failure=$fail',
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
        notifier.navigateToAssistScreen();
        notifier.addNumber(0, false);
        expect(api.saves, 0);
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
}

