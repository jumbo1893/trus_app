
import 'package:trus_app/models/api/player_api_model.dart';

import '../interfaces/model_to_string.dart';

class PlayerStats implements ModelToString {
  final PlayerApiModel player;
  final String text;

  PlayerStats({
    required this.player,
    required this.text,
  });


  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      player: PlayerApiModel.fromJson(json["player"]),
      text: json["text"] ?? "",
    );
  }

  @override
  int getId() {
    return 0;
  }

  @override
  String listViewTitle() {
    return player.name;
  }

  @override
  String toStringForAdd() {
    return "";
  }

  @override
  String toStringForConfirmationDelete() {
    return "";
  }

  @override
  String toStringForEdit(String originName) {
    return "";
  }

  @override
  String toStringForListView() {
    return text;
  }
}
