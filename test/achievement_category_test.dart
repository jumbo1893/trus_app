import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/models/api/achievement/achievement_api_model.dart';
import 'package:trus_app/models/api/achievement/achievement_category.dart';

void main() {
  test('parses achievement category from backend', () {
    final achievement = AchievementApiModel.fromJson({
      'id': 1,
      'name': 'Chodec',
      'code': 'CHODEC',
      'description': 'description',
      'onlyForPlayers': false,
      'manually': false,
      'category': 'STEPS',
    });

    expect(achievement.category, AchievementCategory.steps);
    expect(achievement.toJson()['category'], 'STEPS');
  });

  test('uses general category for an older response without category', () {
    final achievement = AchievementApiModel.fromJson({
      'id': 1,
      'name': 'Achievement',
      'code': 'ACHIEVEMENT',
      'description': 'description',
      'onlyForPlayers': false,
      'manually': false,
    });

    expect(achievement.category, AchievementCategory.general);
  });
}
