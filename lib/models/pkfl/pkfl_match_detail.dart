
import 'dart:core';

import 'package:trus_app/models/pkfl/pkfl_match_player.dart';

class PkflMatchDetail {
  final String refereeComment;
  final List<PkflMatchPlayer> pkflPlayers;

  PkflMatchDetail(this.refereeComment, this.pkflPlayers);


  PkflMatchPlayer? getBestPlayer() {
    for (PkflMatchPlayer pkflMatchPlayer in pkflPlayers) {
      if (pkflMatchPlayer.bestPlayer) {
        return pkflMatchPlayer;
      }
    }
    return null;
  }

  List<PkflMatchPlayer> getGoalScorers() {
    List<PkflMatchPlayer> players = [];
    for (PkflMatchPlayer pkflMatchPlayer in pkflPlayers) {
      if (pkflMatchPlayer.goals > 0) {
        players.add(pkflMatchPlayer);
      }
    }
    return players;
  }

  List<PkflMatchPlayer> getOwnGoalScorers() {
    List<PkflMatchPlayer> players = [];
    for (PkflMatchPlayer pkflMatchPlayer in pkflPlayers) {
      if (pkflMatchPlayer.ownGoals > 0) {
        players.add(pkflMatchPlayer);
      }
    }
    return players;
  }

  List<PkflMatchPlayer> getYellowCardPlayers() {
    List<PkflMatchPlayer> players = [];
    for (PkflMatchPlayer pkflMatchPlayer in pkflPlayers) {
      if (pkflMatchPlayer.yellowCards > 0) {
        players.add(pkflMatchPlayer);
      }
    }
    return players;
  }

  List<PkflMatchPlayer> getRedCardPlayers() {
    List<PkflMatchPlayer> players = [];
    for (PkflMatchPlayer pkflMatchPlayer in pkflPlayers) {
      if (pkflMatchPlayer.redCards > 0) {
        players.add(pkflMatchPlayer);
      }
    }
    return players;
  }
}