import 'package:flutter/material.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

class PlayerListTile extends StatelessWidget {
  final PlayerApiModel player;
  final VoidCallback? onTap;

  const PlayerListTile({
    super.key,
    required this.player,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final officialName = player.footballPlayer?.name.trim();

    final showOfficialName = officialName != null &&
        officialName.isNotEmpty &&
        officialName != player.name;

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
              _PlayerAvatar(
                initials: _getInitials(player.name),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    if (showOfficialName) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 13,
                            color: context.appColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              officialName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.appColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        _PlayerTypeChip(
                          label: player.fan ? 'FANOUŠEK' : 'HRÁČ',
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${player.calculateAge()} let',
                          style: TextStyle(
                            color: context.appColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.cake_outlined,
                          size: 14,
                          color: context.appColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          dateTimeToString(player.birthday),
                          style: TextStyle(
                            color: context.appColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.appColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _PlayerAvatar extends StatelessWidget {
  final String initials;

  const _PlayerAvatar({
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: context.appColors.accentSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: context.appColors.accent,
          fontWeight: FontWeight.w800,
          fontSize: 17,
        ),
      ),
    );
  }
}

class _PlayerTypeChip extends StatelessWidget {
  final String label;

  const _PlayerTypeChip({
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