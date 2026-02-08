import 'package:trus_app/features/player/player_mode.dart';

class PlayerNotifierArgs {
  final PlayerMode playerMode;
  final int? playerId;

  const PlayerNotifierArgs.new()
      : playerMode = PlayerMode.create,
        playerId = null;

  const PlayerNotifierArgs.view(this.playerId)
      : playerMode = PlayerMode.view;

  const PlayerNotifierArgs.edit(this.playerId)
      : playerMode = PlayerMode.edit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PlayerNotifierArgs &&
              runtimeType == other.runtimeType &&
              playerMode == other.playerMode &&
              playerId == other.playerId;

  @override
  int get hashCode =>
      Object.hash(
        playerMode,
        playerId,
      );
}
