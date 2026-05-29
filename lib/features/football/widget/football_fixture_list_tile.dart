import 'package:flutter/material.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

class FootballFixtureListTile extends StatelessWidget {
  final FootballMatchApiModel match;
  final int? userTeamId;
  final VoidCallback? onTap;

  const FootballFixtureListTile({
    super.key,
    required this.match,
    required this.userTeamId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opponentName = _opponentName();
    final isHome = userTeamId == null
        ? null
        : match.isHomeMatch(userTeamId!);

    final score = match.simpleResultToString();

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
              _OpponentBadge(
                initials: _initials(opponentName),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opponentName,
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
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: context.appColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          formatDateForFrontend(match.date),
                          style: TextStyle(
                            color: context.appColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (isHome != null)
                          _FixtureChip(
                            label: isHome ? 'DOMA' : 'VENKU',
                            foreground: context.appColors.accent,
                            background: context.appColors.accentSoft,
                          ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Text(
                          '${match.round}. kolo',
                          style: TextStyle(
                            color: context.appColors.textMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (match.stadiumToSimpleString().isNotEmpty) ...[
                          Text(
                            '  •  ',
                            style: TextStyle(
                              color: context.appColors.textMuted,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              match.stadiumToSimpleString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.appColors.textMuted,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (score.isNotEmpty) ...[
                const SizedBox(width: 10),
                _ScoreChip(score: score),
              ],
              if (onTap != null) ...[
                const SizedBox(width: 6),
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

  String _opponentName() {
    if (userTeamId != null) {
      final opponent = match.getOpponentName(userTeamId!);

      if (opponent.isNotEmpty) {
        return opponent;
      }
    }

    return match.awayTeam?.name ??
        match.homeTeam?.name ??
        'Neznámý soupeř';
  }

  String _initials(String name) {
    final ignoredWords = {
      'fc',
      'fk',
      'sk',
      'tj',
      'afk',
      'sc',
    };

    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .where((word) => !ignoredWords.contains(word.toLowerCase()))
        .toList();

    if (words.isEmpty) {
      return '?';
    }

    if (words.length == 1) {
      final word = words.first;
      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

class _OpponentBadge extends StatelessWidget {
  final String initials;

  const _OpponentBadge({
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 64,
      decoration: BoxDecoration(
        color: context.appColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: context.appColors.textSecondary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String score;

  const _ScoreChip({
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: context.appColors.accentSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        score,
        style: TextStyle(
          color: context.appColors.accent,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FixtureChip extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;

  const _FixtureChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.35,
        ),
      ),
    );
  }
}