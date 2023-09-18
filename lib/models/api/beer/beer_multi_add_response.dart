import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../interfaces/confirm_to_string.dart';
import 'beer_no_match_with_player.dart';

class BeerMultiAddResponse implements ConfirmToString {
  final int editedPlayersCount;
  final int addedPlayersCount;
  final int totalBeersAdded;
  final int totalLiquorsAdded;
  final String match;

  BeerMultiAddResponse({
    required this.editedPlayersCount,
    required this.addedPlayersCount,
    required this.totalBeersAdded,
    required this.totalLiquorsAdded,
    required this.match,
  });


  factory BeerMultiAddResponse.fromJson(Map<String, dynamic> json) {
    return BeerMultiAddResponse(
      editedPlayersCount: json['editedPlayersCount'] ?? 0,
      addedPlayersCount: json["addedPlayersCount"] ?? 0,
      totalBeersAdded: json["totalBeersAdded"] ?? 0,
      totalLiquorsAdded: json["totalLiquorsAdded"] ?? 0,
      match: json["match"] ?? "",
    );
  }


  @override
  String toString() {
    return 'V zápase proti $match byla přidáno $totalBeersAdded piv a $totalLiquorsAdded panáků. První čárka to bylo pro $addedPlayersCount hráčů, zatímco $editedPlayersCount hráčů již má rozpito';
  }

  @override
  String toStringForSnackBar() {
    return toString();
  }
}
