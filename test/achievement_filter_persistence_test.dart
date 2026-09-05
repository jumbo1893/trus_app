import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/achievement/controller/achievement_filter_notifier.dart';
import 'package:trus_app/features/achievement/filter/achievement_filter.dart';
import 'package:trus_app/features/achievement/screens/achievement_screen.dart';
import 'package:trus_app/features/achievement/screens/view_achievement_detail_screen.dart';
import 'package:trus_app/features/achievement/screens/view_player_achievement_detail_screen.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/player/screens/edit_player_screen.dart';
import 'package:trus_app/features/player/screens/view_player_screen.dart';
import 'package:trus_app/models/api/achievement/achievement_category.dart';

void main() {
  test(
    'list filter survives achievement detail and resets after leaving flow',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final screenNotifier = container.read(screenNotifierProvider.notifier);
      final filterNotifier = container.read(
        achievementFilterNotifierProvider.notifier,
      );

      screenNotifier.changeByFragmentId(AchievementScreen.id);
      filterNotifier.setListFilter(
        const AchievementFilter(
          query: 'gól',
          categories: {AchievementCategory.match},
        ),
      );

      screenNotifier.changeByFragmentId(ViewAchievementDetailScreen.id);
      expect(
        container.read(achievementFilterNotifierProvider).listFilter.query,
        'gól',
      );

      screenNotifier.changeByBackButton();
      expect(
        container.read(achievementFilterNotifierProvider).listFilter.query,
        'gól',
      );

      screenNotifier.changeByFragmentId(EditPlayerScreen.id);
      expect(
        container.read(achievementFilterNotifierProvider).listFilter.isActive,
        isFalse,
      );
    },
  );

  test(
    'player filter survives detail and resets after leaving player screen',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final screenNotifier = container.read(screenNotifierProvider.notifier);
      final filterNotifier = container.read(
        achievementFilterNotifierProvider.notifier,
      );

      screenNotifier.changeByFragmentId(ViewPlayerScreen.id);
      filterNotifier.setPlayerFilter(
        7,
        const AchievementFilter(categories: {AchievementCategory.match}),
      );

      screenNotifier.changeByFragmentId(ViewPlayerAchievementDetailScreen.id);
      expect(
        container
            .read(achievementFilterNotifierProvider)
            .filterForPlayer(7)
            .categories,
        {AchievementCategory.match},
      );

      screenNotifier.changeByBackButton();
      expect(
        container
            .read(achievementFilterNotifierProvider)
            .filterForPlayer(7)
            .categories,
        {AchievementCategory.match},
      );

      screenNotifier.changeByFragmentId(EditPlayerScreen.id);
      expect(
        container
            .read(achievementFilterNotifierProvider)
            .filterForPlayer(7)
            .isActive,
        isFalse,
      );
    },
  );

  test('player filter does not leak to a different player', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final filterNotifier = container.read(
      achievementFilterNotifierProvider.notifier,
    );

    filterNotifier.setPlayerFilter(
      7,
      const AchievementFilter(query: 'střelec'),
    );

    expect(
      container
          .read(achievementFilterNotifierProvider)
          .filterForPlayer(8)
          .isActive,
      isFalse,
    );
  });
}
