import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/receivedfine/stats/received_fine_stats_detail_models.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_widget_values.dart';

class FineMatchListview extends StatelessWidget {
  final ScrollController? scrollController;
  final List<PlayerApiModel> players;
  final Set<int> playersInMatchIds;
  final Map<int, PlayerWithFinesModel> playerFineSummaryByPlayerId;
  final bool multiselect;
  final List<PlayerApiModel> checkedPlayers;
  final ValueChanged<PlayerApiModel> onPlayerSelected;
  final ValueChanged<PlayerApiModel> onPlayerChecked;

  const FineMatchListview({
    super.key,
    this.scrollController,
    required this.players,
    required this.playersInMatchIds,
    required this.playerFineSummaryByPlayerId,
    required this.multiselect,
    required this.onPlayerSelected,
    required this.onPlayerChecked,
    required this.checkedPlayers,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = multiselect ? 150.0 : 24.0;

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.only(bottom: bottomPadding),
      itemCount: players.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final player = players[index];
        final playerId = player.id;
        final checked = checkedPlayers.contains(player);
        final isPlayerInMatch =
            playerId != null && playersInMatchIds.contains(playerId);
        final fineSummary = playerId == null
            ? null
            : playerFineSummaryByPlayerId[playerId];

        return _FinePlayerTile(
          player: player,
          fineSummary: fineSummary,
          isPlayerInMatch: isPlayerInMatch,
          multiselect: multiselect,
          checked: checked,
          onTap: () {
            if (multiselect) {
              onPlayerChecked(player);
            } else {
              onPlayerSelected(player);
            }
          },
        );
      },
    );
  }
}

class _FinePlayerTile extends StatelessWidget {
  final PlayerApiModel player;
  final PlayerWithFinesModel? fineSummary;
  final bool isPlayerInMatch;
  final bool multiselect;
  final bool checked;
  final VoidCallback onTap;

  const _FinePlayerTile({
    required this.player,
    required this.fineSummary,
    required this.isPlayerInMatch,
    required this.multiselect,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fines = fineSummary?.fines ?? const <FineCountModel>[];
    final totalAmount = fineSummary?.totalAmount ?? 0;

    return Material(
      color: context.appColors.cardBackground,
      borderRadius: AppWidgetValues.borderRadiusXl,
      child: InkWell(
        borderRadius: AppWidgetValues.borderRadiusXl,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: AppWidgetValues.borderRadiusXl,
            boxShadow: AppWidgetValues.cardShadow,
            border: multiselect && checked
                ? Border.all(
              color: context.appColors.accent,
              width: 1.4,
            )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (multiselect) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 17),
                  child: _SelectionIndicator(checked: checked),
                ),
                SizedBox(width: 10),
              ],
              _AmountBadge(
                amount: totalAmount,
              ),
              SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            player.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.25,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        _MatchPresenceChip(
                          isPlayerInMatch: isPlayerInMatch,
                        ),
                      ],
                    ),
                    SizedBox(height: 11),
                    if (fines.isEmpty)
                      Text(
                        'Bez pokut v tomto zápase',
                        style: TextStyle(
                          color: context.appColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: fines
                            .map(
                              (fine) => _FineChip(
                            fine: fine,
                          ),
                        )
                            .toList(),
                      ),
                  ],
                ),
              ),
              if (!multiselect) ...[
                SizedBox(width: 7),
                Padding(
                  padding: const EdgeInsets.only(top: 17),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: context.appColors.textMuted,
                    size: 22,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountBadge extends StatelessWidget {
  final int amount;

  const _AmountBadge({
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final hasFine = amount > 0;

    return Container(
      width: 67,
      height: 62,
      decoration: BoxDecoration(
        color: hasFine
            ? context.appColors.warningBackground
            : context.appColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$amount',
                maxLines: 1,
                style: TextStyle(
                  color: hasFine
                      ? context.appColors.warningForeground
                      : context.appColors.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Text(
            'Kč',
            style: TextStyle(
              color: hasFine
                  ? context.appColors.warningForeground
                  : context.appColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchPresenceChip extends StatelessWidget {
  final bool isPlayerInMatch;

  const _MatchPresenceChip({
    required this.isPlayerInMatch,
  });

  @override
  Widget build(BuildContext context) {
    final background = isPlayerInMatch
        ? context.appColors.successBackground
        : context.appColors.backgroundSecondary;

    final foreground = isPlayerInMatch
        ? context.appColors.successForeground
        : context.appColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isPlayerInMatch ? 'V ZÁPASE' : 'OSTATNÍ',
        style: TextStyle(
          color: foreground,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _FineChip extends StatelessWidget {
  final FineCountModel fine;

  const _FineChip({
    required this.fine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: context.appColors.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${fine.count}× ${fine.fine.name}',
        style: TextStyle(
          color: context.appColors.accent,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool checked;

  const _SelectionIndicator({
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        color: checked
            ? context.appColors.accent
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: checked
              ? context.appColors.accent
              : context.appColors.disabled,
          width: 2,
        ),
      ),
      child: checked
          ? Icon(
        Icons.check_rounded,
        size: 18,
        color: context.appColors.cardBackground,
      )
          : null,
    );
  }
}