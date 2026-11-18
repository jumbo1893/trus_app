import 'package:flutter/material.dart';
import 'package:trus_app/features/user/widgets/user_avatar.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class PlayerSelectionGrid extends StatelessWidget {
  final List<PlayerApiModel> players;
  final ValueChanged<PlayerApiModel> onTap;
  final bool Function(PlayerApiModel)? isSelected;
  final ScrollController? controller;
  final bool shrinkWrap;

  const PlayerSelectionGrid({
    super.key,
    required this.players,
    required this.onTap,
    this.isSelected,
    this.controller,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) => GridView.builder(
    controller: controller,
    shrinkWrap: shrinkWrap,
    physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
    padding: const EdgeInsets.symmetric(vertical: 8),
    itemCount: players.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisExtent: 64,
    ),
    itemBuilder: (context, index) {
      final player = players[index];
      final selected = isSelected?.call(player) ?? false;
      final initial = player.name.isEmpty ? '?' : player.name[0].toUpperCase();
      return InkWell(
        onTap: () => onTap(player),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              if (isSelected != null)
                Checkbox(value: selected, onChanged: (_) => onTap(player)),
              player.avatarUserId == null
                  ? CircleAvatar(child: Text(initial))
                  : UserAvatar(
                      userId: player.avatarUserId!,
                      fallback: Text(initial),
                    ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  player.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
