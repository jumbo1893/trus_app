import 'package:flutter/material.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

class MatchListTile extends StatelessWidget {
  final MatchApiModel match;
  final VoidCallback? onTap;

  const MatchListTile({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final footballMatch = match.footballMatch;

    final hasResult = footballMatch?.homeGoalNumber != null &&
        footballMatch?.awayGoalNumber != null;

    final score = hasResult
        ? '${footballMatch!.homeGoalNumber}:${footballMatch.awayGoalNumber}'
        : '–';

    final homeTeamName = match.home ? 'Liščí Trus' : match.name;
    final awayTeamName = match.home ? match.name : 'Liščí Trus';

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
              _ScoreBadge(
                score: score,
                hasResult: hasResult,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TeamRow(
                      name: homeTeamName,
                      isUserTeam: match.home,
                    ),
                    const SizedBox(height: 5),
                    _TeamRow(
                      name: awayTeamName,
                      isUserTeam: !match.home,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: context.appColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          dateTimeToString(match.date),
                          style: TextStyle(
                            color: context.appColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _MetaChip(
                          label: match.home ? 'DOMA' : 'VENKU',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.appColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String score;
  final bool hasResult;

  const _ScoreBadge({
    required this.score,
    required this.hasResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 66,
      decoration: BoxDecoration(
        color: hasResult
            ? context.appColors.accentSoft
            : context.appColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        score,
        style: TextStyle(
          color: hasResult
              ? context.appColors.accent
              : context.appColors.textMuted,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final String name;
  final bool isUserTeam;

  const _TeamRow({
    required this.name,
    required this.isUserTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: context.appColors.textPrimary,
        fontSize: 15,
        fontWeight: isUserTeam ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: context.appColors.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.appColors.accent,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}