import 'package:flutter/material.dart';
import 'package:trus_app/models/api/achievement/achievement_rarity.dart';

class AchievementRarityStyle {
  final Color color;

  const AchievementRarityStyle({
    required this.color,
  });

  factory AchievementRarityStyle.fromRarity(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return const AchievementRarityStyle(
          color: Color(0xFFF59E0B), // orange
        );
      case AchievementRarity.rare:
        return const AchievementRarityStyle(
          color: Color(0xFFEAB308), // gold/yellow
        );
      case AchievementRarity.epic:
        return const AchievementRarityStyle(
          color: Color(0xFF3B82F6), // blue
        );
      case AchievementRarity.legendary:
        return const AchievementRarityStyle(
          color: Color(0xFFA855F7), // purple
        );
    }
  }

  factory AchievementRarityStyle.forListTile({
    required AchievementRarity rarity,
    required int successPercentage,
  }) {
    if (successPercentage == 0) {
      return const AchievementRarityStyle(
        color: Color(0xFFEF4444), // red
      );
    }

    return AchievementRarityStyle.fromRarity(rarity);
  }
}