class Membership {
  final String effectiveTier;
  final String unlimitedTier;
  final String timedTier;
  final int? effectiveDailyLimit;
  final int ultraMillisRemaining;
  final int premiumMillisRemaining;
  final DateTime? ultraUntil;
  final DateTime? premiumUntil;
  final int countedDrinks;
  final DateTime drinkCountingStartedAt;
  final int drinksTowardNextPremium;
  final int drinksToNextPremium;
  final int drinksPerPremiumWeek;
  final int daysPerRewardWeek;

  const Membership({
    required this.effectiveTier,
    required this.unlimitedTier,
    required this.timedTier,
    required this.effectiveDailyLimit,
    required this.ultraMillisRemaining,
    required this.premiumMillisRemaining,
    required this.ultraUntil,
    required this.premiumUntil,
    required this.countedDrinks,
    required this.drinkCountingStartedAt,
    required this.drinksTowardNextPremium,
    required this.drinksToNextPremium,
    required this.drinksPerPremiumWeek,
    required this.daysPerRewardWeek,
  });

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
    effectiveTier: json['effectiveTier'] as String? ?? 'STANDARD',
    unlimitedTier: json['unlimitedTier'] as String? ?? 'STANDARD',
    timedTier: json['timedTier'] as String? ?? 'STANDARD',
    effectiveDailyLimit: (json['effectiveDailyLimit'] as num?)?.toInt(),
    ultraMillisRemaining: (json['ultraMillisRemaining'] as num?)?.toInt() ?? 0,
    premiumMillisRemaining:
        (json['premiumMillisRemaining'] as num?)?.toInt() ?? 0,
    ultraUntil: DateTime.tryParse(json['ultraUntil'] as String? ?? ''),
    premiumUntil: DateTime.tryParse(json['premiumUntil'] as String? ?? ''),
    countedDrinks: (json['countedDrinks'] as num?)?.toInt() ?? 0,
    drinkCountingStartedAt:
        DateTime.tryParse(json['drinkCountingStartedAt'] as String? ?? '') ??
        DateTime.now(),
    drinksTowardNextPremium:
        (json['drinksTowardNextPremium'] as num?)?.toInt() ?? 0,
    drinksToNextPremium: (json['drinksToNextPremium'] as num?)?.toInt() ?? 10,
    drinksPerPremiumWeek: (json['drinksPerPremiumWeek'] as num?)?.toInt() ?? 10,
    daysPerRewardWeek: (json['daysPerRewardWeek'] as num?)?.toInt() ?? 7,
  );

  String get effectiveTierLabel => switch (effectiveTier) {
    'PREMIUM' => 'Premium',
    'ULTRA' => 'Ultra',
    _ => 'Standard',
  };

  double get drinkProgress {
    if (drinksPerPremiumWeek <= 0) return 0;
    return (drinksTowardNextPremium / drinksPerPremiumWeek).clamp(0, 1);
  }
}
