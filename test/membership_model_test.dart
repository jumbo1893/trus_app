import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/models/api/membership/membership.dart';

void main() {
  test('membership parses stacked Ultra and Premium rewards', () {
    final membership = Membership.fromJson({
      'effectiveTier': 'ULTRA',
      'unlimitedTier': 'STANDARD',
      'timedTier': 'ULTRA',
      'effectiveDailyLimit': null,
      'ultraMillisRemaining': 1209600000,
      'premiumMillisRemaining': 604800000,
      'ultraUntil': '2026-09-08T12:00:00Z',
      'premiumUntil': '2026-09-15T12:00:00Z',
      'countedDrinks': 17,
      'drinkCountingStartedAt': '2026-08-25T08:00:00Z',
      'drinksTowardNextPremium': 7,
      'drinksToNextPremium': 3,
      'drinksPerPremiumWeek': 10,
      'daysPerRewardWeek': 7,
    });

    expect(membership.effectiveTierLabel, 'Ultra');
    expect(membership.timedTier, 'ULTRA');
    expect(membership.unlimitedTier, 'STANDARD');
    expect(membership.effectiveDailyLimit, isNull);
    expect(membership.drinkProgress, .7);
    expect(membership.drinksToNextPremium, 3);
    expect(membership.premiumUntil!.isAfter(membership.ultraUntil!), isTrue);
  });

  test('membership parses unlimited premium account', () {
    final membership = Membership.fromJson({
      'effectiveTier': 'PREMIUM',
      'unlimitedTier': 'PREMIUM',
      'timedTier': 'STANDARD',
      'effectiveDailyLimit': 20,
      'drinkCountingStartedAt': '2026-08-25T08:00:00Z',
    });

    expect(membership.effectiveTierLabel, 'Premium');
    expect(membership.unlimitedTier, 'PREMIUM');
    expect(membership.ultraUntil, isNull);
    expect(membership.premiumUntil, isNull);
  });
}
