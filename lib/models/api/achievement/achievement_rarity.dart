// lib/models/api/achievement/achievement_rarity.dart

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

extension AchievementRarityExtension on AchievementRarity {
  static AchievementRarity fromJson(dynamic value) {
    final normalized = value?.toString().toUpperCase();

    switch (normalized) {
      case "RARE":
        return AchievementRarity.rare;
      case "EPIC":
        return AchievementRarity.epic;
      case "LEGENDARY":
        return AchievementRarity.legendary;
      case "COMMON":
      default:
        return AchievementRarity.common;
    }
  }

  String toJson() {
    switch (this) {
      case AchievementRarity.common:
        return "COMMON";
      case AchievementRarity.rare:
        return "RARE";
      case AchievementRarity.epic:
        return "EPIC";
      case AchievementRarity.legendary:
        return "LEGENDARY";
    }
  }

  String get title {
    switch (this) {
      case AchievementRarity.common:
        return "Běžné";
      case AchievementRarity.rare:
        return "Vzácné";
      case AchievementRarity.epic:
        return "Epické";
      case AchievementRarity.legendary:
        return "Legendární";
    }
  }
}