import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/common/utils/season_util.dart';
import 'package:trus_app/models/api/season_api_model.dart';

void main() {
  test('the whole final calendar day belongs to the current season', () {
    final season = SeasonApiModel(
      id: 42,
      name: 'Aktuální sezona',
      fromDate: DateTime(2026, 3, 1, 12),
      toDate: DateTime(2026, 6, 30, 12),
    );

    expect(isSeasonActiveOn(season, DateTime(2026, 6, 30, 23, 59)), isTrue);
    expect(isSeasonActiveOn(season, DateTime(2026, 7, 1)), isFalse);
  });
}
