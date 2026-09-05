import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/achievement/filter/achievement_filter.dart';
import 'package:trus_app/models/api/achievement/achievement_api_model.dart';
import 'package:trus_app/models/api/achievement/achievement_category.dart';

void main() {
  test(
    'fulltext searches name, description and secondary condition without accents',
    () {
      final achievement = model(
        name: 'Týmový hráč',
        description: 'Připiš si alespoň pět asistencí',
        secondaryCondition: 'Vynechej maximálně jeden zápas',
      );

      expect(
        const AchievementFilter(query: 'tymovy').matches(achievement),
        isTrue,
      );
      expect(
        const AchievementFilter(query: 'asistenci').matches(achievement),
        isTrue,
      );
      expect(
        const AchievementFilter(query: 'jeden zapas').matches(achievement),
        isTrue,
      );
      expect(
        const AchievementFilter(query: 'pokuta').matches(achievement),
        isFalse,
      );
    },
  );

  test('multiple categories use OR and combine with the success range', () {
    final fineAchievement = model(
      category: AchievementCategory.fine,
      teamSuccessRate: 0.35,
    );
    final matchAchievement = model(
      category: AchievementCategory.match,
      teamSuccessRate: 0.35,
    );
    final beerAchievement = model(
      category: AchievementCategory.beer,
      teamSuccessRate: 0.35,
    );
    const filter = AchievementFilter(
      categories: {AchievementCategory.fine, AchievementCategory.match},
      minimumSuccessRate: 0.3,
      maximumSuccessRate: 0.4,
    );

    expect(filter.matches(fineAchievement), isTrue);
    expect(filter.matches(matchAchievement), isTrue);
    expect(filter.matches(beerAchievement), isFalse);
  });

  test('success range can use the rate displayed by the current screen', () {
    final achievement = model(teamSuccessRate: 0.9);
    const filter = AchievementFilter(
      minimumSuccessRate: 0.2,
      maximumSuccessRate: 0.4,
    );

    expect(filter.matches(achievement, successRate: 0.3), isTrue);
    expect(filter.matches(achievement), isFalse);
  });

  test('multiple player filters use OR over accomplished player ids', () {
    final achievement = model();

    expect(
      const AchievementFilter(
        accomplishedPlayerIds: {7, 8},
      ).matches(achievement, accomplishedPlayerIds: const {8, 9}),
      isTrue,
    );
    expect(
      const AchievementFilter(
        accomplishedPlayerIds: {6, 7},
      ).matches(achievement, accomplishedPlayerIds: const {8, 9}),
      isFalse,
    );
  });

  test('active filter count includes every selected value', () {
    const filter = AchievementFilter(
      categories: {AchievementCategory.match, AchievementCategory.fine},
      accomplishedPlayerIds: {7, 8},
      minimumSuccessRate: 0.2,
    );

    expect(filter.activeAdvancedFilterCount, 5);
  });
}

AchievementApiModel model({
  String name = 'Achievement',
  String description = 'Popis',
  String? secondaryCondition,
  AchievementCategory category = AchievementCategory.general,
  double teamSuccessRate = 0.5,
}) {
  return AchievementApiModel(
    id: 1,
    name: name,
    code: 'TEST',
    description: description,
    secondaryCondition: secondaryCondition,
    onlyForPlayers: false,
    manually: false,
    category: category,
    teamSuccessRate: teamSuccessRate,
  );
}
