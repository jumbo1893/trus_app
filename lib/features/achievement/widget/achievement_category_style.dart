import 'package:flutter/material.dart';
import 'package:trus_app/models/api/achievement/achievement_category.dart';

class AchievementCategoryStyle {
  final Color color;
  final IconData icon;

  const AchievementCategoryStyle({required this.color, required this.icon});

  factory AchievementCategoryStyle.fromCategory(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.steps:
        return const AchievementCategoryStyle(
          color: Color(0xFF16A34A),
          icon: Icons.directions_walk_rounded,
        );
      case AchievementCategory.visitedCountries:
        return const AchievementCategoryStyle(
          color: Color(0xFF0EA5E9),
          icon: Icons.public_rounded,
        );
      case AchievementCategory.beer:
        return const AchievementCategoryStyle(
          color: Color(0xFFF59E0B),
          icon: Icons.sports_bar_rounded,
        );
      case AchievementCategory.fan:
        return const AchievementCategoryStyle(
          color: Color(0xFFEC4899),
          icon: Icons.groups_rounded,
        );
      case AchievementCategory.match:
        return const AchievementCategoryStyle(
          color: Color(0xFF2563EB),
          icon: Icons.sports_soccer_rounded,
        );
      case AchievementCategory.fine:
        return const AchievementCategoryStyle(
          color: Color(0xFFDC2626),
          icon: Icons.receipt_long_rounded,
        );
      case AchievementCategory.footbar:
        return const AchievementCategoryStyle(
          color: Color(0xFF7C3AED),
          icon: Icons.speed_rounded,
        );
      case AchievementCategory.general:
        return const AchievementCategoryStyle(
          color: Color(0xFF64748B),
          icon: Icons.emoji_events_outlined,
        );
    }
  }
}
