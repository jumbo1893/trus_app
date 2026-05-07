import 'package:flutter/material.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_widget_values.dart';

class FineMatchListview extends StatelessWidget {
  final ScrollController? scrollController;
  final List<PlayerApiModel> players;
  final bool multiselect;
  final List<PlayerApiModel> checkedPlayers;
  final Function(PlayerApiModel playerApiModel) onPlayerSelected;
  final Function(PlayerApiModel playerApiModel) onPlayerChecked;

  const FineMatchListview({
    super.key,
    this.scrollController,
    required this.players,
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
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final player = players[index];
        final checked = checkedPlayers.contains(player);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (multiselect) {
                onPlayerChecked(player);
              } else {
                onPlayerSelected(player);
              }
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                borderRadius: AppWidgetValues.borderRadiusXl,
                boxShadow: AppWidgetValues.cardShadow,

              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (multiselect) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: _SelectionIndicator(checked: checked),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            height: 1.3,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          player.toStringForListView(),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!multiselect)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.black38,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: checked ? Colors.orange : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: checked ? Colors.orange : Colors.black26,
          width: 2,
        ),
      ),
      child: checked
          ? const Icon(
        Icons.check,
        size: 18,
        color: Colors.white,
      )
          : null,
    );
  }
}