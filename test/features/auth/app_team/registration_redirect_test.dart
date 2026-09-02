import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/team_administration/screens/team_administration_screen.dart';

void main() {
  test('registration reset does not inherit the previous user screen', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(screenNotifierProvider.notifier);

    notifier.changeByFragmentId(TeamAdministrationScreen.id);
    expect(
      container.read(screenNotifierProvider).currentScreenId,
      TeamAdministrationScreen.id,
    );

    notifier.resetTo(HomeScreen.id);

    final state = container.read(screenNotifierProvider);
    expect(state.currentScreenId, HomeScreen.id);
    expect(state.currentPageIndex, 0);
    expect(state.backButtonFragmentList, isEmpty);
  });

  test(
    'new team registration opens administration with home as back target',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(screenNotifierProvider.notifier);

      notifier.resetTo(TeamAdministrationScreen.id);

      expect(
        container.read(screenNotifierProvider).currentScreenId,
        TeamAdministrationScreen.id,
      );
      notifier.changeByBackButton();
      expect(
        container.read(screenNotifierProvider).currentScreenId,
        HomeScreen.id,
      );
    },
  );
}
