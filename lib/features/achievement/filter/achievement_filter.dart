import 'package:trus_app/common/utils/search_text.dart';
import 'package:trus_app/models/api/achievement/achievement_api_model.dart';
import 'package:trus_app/models/api/achievement/achievement_category.dart';

class AchievementFilter {
  final String query;
  final Set<AchievementCategory> categories;
  final Set<int> accomplishedPlayerIds;
  final double minimumSuccessRate;
  final double maximumSuccessRate;

  const AchievementFilter({
    this.query = '',
    this.categories = const {},
    this.accomplishedPlayerIds = const {},
    this.minimumSuccessRate = 0,
    this.maximumSuccessRate = 1,
  });

  int get activeAdvancedFilterCount {
    var count = categories.length + accomplishedPlayerIds.length;
    if (minimumSuccessRate > 0 || maximumSuccessRate < 1) count++;
    return count;
  }

  bool get isActive => query.trim().isNotEmpty || activeAdvancedFilterCount > 0;

  bool matches(
    AchievementApiModel achievement, {
    Set<int> accomplishedPlayerIds = const {},
    double? successRate,
  }) {
    final normalizedQuery = normalizeSearchText(query);
    if (normalizedQuery.isNotEmpty) {
      final searchableText = normalizeSearchText(
        [
          achievement.name,
          achievement.description,
          achievement.secondaryCondition ?? '',
        ].join(' '),
      );
      if (!searchableText.contains(normalizedQuery)) return false;
    }

    if (categories.isNotEmpty && !categories.contains(achievement.category)) {
      return false;
    }

    final effectiveSuccessRate = (successRate ?? achievement.teamSuccessRate)
        .clamp(0.0, 1.0);
    if (effectiveSuccessRate < minimumSuccessRate ||
        effectiveSuccessRate > maximumSuccessRate) {
      return false;
    }

    if (this.accomplishedPlayerIds.isNotEmpty) {
      final accomplishedBySelectedPlayer = this.accomplishedPlayerIds.any(
        accomplishedPlayerIds.contains,
      );
      if (!accomplishedBySelectedPlayer) return false;
    }

    return true;
  }

  AchievementFilter copyWith({
    String? query,
    Set<AchievementCategory>? categories,
    Set<int>? accomplishedPlayerIds,
    double? minimumSuccessRate,
    double? maximumSuccessRate,
  }) {
    return AchievementFilter(
      query: query ?? this.query,
      categories: categories ?? this.categories,
      accomplishedPlayerIds:
          accomplishedPlayerIds ?? this.accomplishedPlayerIds,
      minimumSuccessRate: minimumSuccessRate ?? this.minimumSuccessRate,
      maximumSuccessRate: maximumSuccessRate ?? this.maximumSuccessRate,
    );
  }
}
