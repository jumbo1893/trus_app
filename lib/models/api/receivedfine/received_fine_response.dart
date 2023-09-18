
import '../interfaces/confirm_to_string.dart';

class ReceivedFineResponse implements ConfirmToString {
  final int editedPlayersCount;
  final String player;
  final int totalFinesAdded;
  final String match;

  ReceivedFineResponse({
    required this.editedPlayersCount,
    required this.player,
    required this.totalFinesAdded,
    required this.match,
  });

  Map<String, dynamic> toJson() {
    return {
      "editedPlayersCount": editedPlayersCount,
      "player": player,
      "totalFinesAdded": totalFinesAdded,
      "match": match,
    };
  }

  factory ReceivedFineResponse.fromJson(Map<String, dynamic> json) {
    return ReceivedFineResponse(
      editedPlayersCount: json["editedPlayersCount"] ?? 0,
      totalFinesAdded: json["totalFinesAdded"] ?? 0,
      player: json["player"] ?? "",
      match: json["match"] ?? "",
    );
  }


  @override
  String toString() {
    if(player.isEmpty) {
      return 'V zápase proti $match bylo přidáno $editedPlayersCount hráčům celkem $totalFinesAdded pokut';

    }
    return 'V zápase proti $match bylo přidáno hráči $player celkem $totalFinesAdded pokut';
  }

  @override
  String toStringForSnackBar() {
    return toString();
  }


}
