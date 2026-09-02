enum AchievementCategory {
  steps,
  visitedCountries,
  beer,
  fan,
  match,
  fine,
  footbar,
  general,
}

extension AchievementCategoryExtension on AchievementCategory {
  static AchievementCategory fromJson(dynamic value) {
    switch (value?.toString().toUpperCase()) {
      case 'STEPS':
        return AchievementCategory.steps;
      case 'VISITED_COUNTRIES':
        return AchievementCategory.visitedCountries;
      case 'BEER':
        return AchievementCategory.beer;
      case 'FAN':
        return AchievementCategory.fan;
      case 'MATCH':
        return AchievementCategory.match;
      case 'FINE':
        return AchievementCategory.fine;
      case 'FOOTBAR':
        return AchievementCategory.footbar;
      case 'GENERAL':
      default:
        return AchievementCategory.general;
    }
  }

  String toJson() {
    switch (this) {
      case AchievementCategory.steps:
        return 'STEPS';
      case AchievementCategory.visitedCountries:
        return 'VISITED_COUNTRIES';
      case AchievementCategory.beer:
        return 'BEER';
      case AchievementCategory.fan:
        return 'FAN';
      case AchievementCategory.match:
        return 'MATCH';
      case AchievementCategory.fine:
        return 'FINE';
      case AchievementCategory.footbar:
        return 'FOOTBAR';
      case AchievementCategory.general:
        return 'GENERAL';
    }
  }

  String get title {
    switch (this) {
      case AchievementCategory.steps:
        return 'Kroky';
      case AchievementCategory.visitedCountries:
        return 'Navštívené země';
      case AchievementCategory.beer:
        return 'Pivní';
      case AchievementCategory.fan:
        return 'Fanouškovské';
      case AchievementCategory.match:
        return 'Zápasové';
      case AchievementCategory.fine:
        return 'Pokutové';
      case AchievementCategory.footbar:
        return 'Footbar';
      case AchievementCategory.general:
        return 'Obecné';
    }
  }
}
