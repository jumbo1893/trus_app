import 'package:flutter/material.dart';
import 'package:trus_app/models/api/football/table_team_api_model.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

class FootballTableTeamListTile extends StatelessWidget {
  final TableTeamApiModel team;
  final int teamsCount;
  final VoidCallback? onTap;

  const FootballTableTeamListTile({
    super.key,
    required this.team,
    required this.teamsCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zone = team.tableZone ?? _fallbackZone();
    final style = _TableZoneStyle.fromZone(context, zone);
    final hasPenalty = team.penalty.trim().isNotEmpty &&
        team.penalty.trim() != '0';

    return Material(
      color: context.appColors.cardBackground,
      borderRadius: AppWidgetValues.borderRadiusXl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppWidgetValues.borderRadiusXl,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: AppWidgetValues.borderRadiusXl,
            boxShadow: AppWidgetValues.cardShadow,
          ),
          child: Row(
            children: [
              _RankBadge(
                rank: team.rank,
                style: style,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.teamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        _ValueItem(
                          label: 'B',
                          value: '${team.points}',
                          highlighted: true,
                        ),
                        const SizedBox(width: 14),
                        _ValueItem(
                          label: 'Z',
                          value: '${team.matches}',
                        ),
                        const SizedBox(width: 14),
                        _ValueItem(
                          label: 'V-R-P',
                          value: '${team.wins}-${team.draws}-${team.losses}',
                        ),
                        const SizedBox(width: 14),
                        _ValueItem(
                          label: 'SKÓRE',
                          value: '${team.goalsScored}:${team.goalsReceived}',
                        ),
                      ],
                    ),
                    if (hasPenalty) ...[
                      const SizedBox(height: 9),
                      _PenaltyChip(
                        penalty: team.penalty,
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: context.appColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  FootballTableZone _fallbackZone() {
    if (team.rank <= 3) {
      return FootballTableZone.promotion;
    }

    if (teamsCount >= 2 && team.rank > teamsCount - 2) {
      return FootballTableZone.relegation;
    }

    return FootballTableZone.neutral;
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final _TableZoneStyle style;

  const _RankBadge({
    required this.rank,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 58,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank.',
        style: TextStyle(
          color: style.foreground,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ValueItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;

  const _ValueItem({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.appColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.35,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: highlighted
                ? context.appColors.accent
                : context.appColors.textSecondary,
            fontSize: 13,
            fontWeight: highlighted
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PenaltyChip extends StatelessWidget {
  final String penalty;

  const _PenaltyChip({
    required this.penalty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: context.appColors.warningBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Trest: $penalty',
        style: TextStyle(
          color: context.appColors.warningForeground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TableZoneStyle {
  final Color background;
  final Color foreground;

  const _TableZoneStyle({
    required this.background,
    required this.foreground,
  });

  factory _TableZoneStyle.fromZone(
      BuildContext context,
      FootballTableZone zone,
      ) {
    switch (zone) {
      case FootballTableZone.promotion:
        return _TableZoneStyle(
          background: context.appColors.infoBackground,
          foreground: context.appColors.infoForeground,
        );
      case FootballTableZone.promotionPlayoff:
        return _TableZoneStyle(
          background: context.appColors.successBackground,
          foreground: context.appColors.successForeground,
        );
      case FootballTableZone.relegationPlayoff:
        return _TableZoneStyle(
          background: context.appColors.warningBackground,
          foreground: context.appColors.warningForeground,
        );
      case FootballTableZone.relegation:
        return _TableZoneStyle(
          background: context.appColors.errorBackground,
          foreground: context.appColors.errorForeground,
        );
      case FootballTableZone.neutral:
        return _TableZoneStyle(
          background: context.appColors.backgroundSecondary,
          foreground: context.appColors.textSecondary,
        );
    }
  }
}