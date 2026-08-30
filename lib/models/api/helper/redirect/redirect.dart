enum Redirect {
  playerBeerStats,
  matchWithPlayerBottomsheet,
  matchParticipation,
  playerFineStats,
  viewPlayer,
}

extension RedirectExtension on Redirect {
  static Redirect? fromJson(String? value) {
    switch (value) {
      case "PLAYER_BEER_STATS":
        return Redirect.playerBeerStats;
      case "MATCH_WITH_PLAYER_BOTTOMSHEET":
        return Redirect.matchWithPlayerBottomsheet;
      case "MATCH_PARTICIPATION":
        return Redirect.matchParticipation;
      case "PLAYER_FINE_STATS":
        return Redirect.playerFineStats;
      case "VIEW_PLAYER":
        return Redirect.viewPlayer;
      default:
        return null;
    }
  }

  String toJson() {
    switch (this) {
      case Redirect.playerBeerStats:
        return "PLAYER_BEER_STATS";
      case Redirect.matchWithPlayerBottomsheet:
        return "MATCH_WITH_PLAYER_BOTTOMSHEET";
      case Redirect.matchParticipation:
        return "MATCH_PARTICIPATION";
      case Redirect.playerFineStats:
        return "PLAYER_FINE_STATS";
      case Redirect.viewPlayer:
        return "VIEW_PLAYER";
    }
  }
}
