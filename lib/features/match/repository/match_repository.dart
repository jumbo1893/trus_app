import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/beer/controller/beer_controller.dart';
import 'package:trus_app/models/helper/player_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';

import '../../../common/utils/utils.dart';
import '../../../config.dart';
import '../../../models/player_stats_model.dart';
import '../../../models/player_model.dart';

final matchRepositoryProvider = Provider(
  (ref) => MatchRepository(firestore: FirebaseFirestore.instance),
);

class MatchRepository {
  final FirebaseFirestore firestore;

  MatchRepository({required this.firestore});

  Stream<List<MatchModel>> getMatches() {
    return firestore.collection(matchTable).snapshots().map((event) {
      List<MatchModel> matches = [];
      for (var document in event.docs) {
        var match = MatchModel.fromJson(document.data());
        matches.add(match);
      }
      return matches;
    });
  }

  Stream<List<MatchModel>> getMatchesBySeason(String seasonId) {
    return firestore
        .collection(matchTable)
        .where("seasonId", isEqualTo: seasonId)
        .snapshots()
        .map((event) {
      List<MatchModel> matches = [];
      for (var document in event.docs) {
        var match = MatchModel.fromJson(document.data());
        matches.add(match);
      }
      return matches;
    });
  }

  Future<MatchModel?> addMatch(BuildContext context, String name, DateTime date,
      bool home, List<String> playerIdList, String seasonId) async {
    try {
      final document = firestore.collection(matchTable).doc();
      MatchModel match = MatchModel(
          name: name,
          id: document.id,
          date: date,
          home: home,
          playerIdList: playerIdList,
          seasonId: seasonId);
      await document.set(match.toJson());
      showSnackBar(context: context, content: ("Zápas $name úspěšně přidán"));
      return match;
    } on FirebaseException catch (e) {
      showSnackBar(
        context: context,
        content: e.message!,
      );
    }
    return null;
  }

  Future<bool> editMatch(
      BuildContext context,
      String name,
      DateTime date,
      bool home,
      List<String> playerIdList,
      String seasonId,
      MatchModel matchModel) async {
    try {
      final document = firestore.collection(matchTable).doc(matchModel.id);
      MatchModel match = MatchModel(
          name: name,
          id: matchModel.id,
          date: date,
          home: home,
          playerIdList: playerIdList,
          seasonId: seasonId);
      await document.set(match.toJson());
      showSnackBar(context: context, content: ("Zápas $name úspěšně upraven"));
      return true;
    } on FirebaseException catch (e) {
      showSnackBar(
        context: context,
        content: e.message!,
      );
    }
    return false;
  }

  Future<void> deleteMatch(BuildContext context, MatchModel matchModel) async {
    String name = matchModel.name;
    await firestore.collection(matchTable).doc(matchModel.id).delete().then(
          (value) => showSnackBar(
              context: context, content: ("Zápas $name úspěšně smazán")),
          onError: (e) => showSnackBar(
            context: context,
            content: e.message!,
          ),
        );
  }

  Future<List<PlayerModel>> _getPlayers() async {
    final docRef = firestore.collection(playerTable);
    List<PlayerModel> players = [];
    await docRef.get().then((res) {
      for (var doc in res.docs) {
        var player = PlayerModel.fromJson(doc.data());

        players.add(player);
      }
    });
    return players;
  }

  Stream<List<PlayerStatsModel>> getPlayerStats() {
    return firestore.collection(playerStatsTable).snapshots().map((event) {
      List<PlayerStatsModel> playerStatsList = [];
      for (var document in event.docs) {
        var playerStats = PlayerStatsModel.fromJson(document.data());
        playerStatsList.add(playerStats);
      }
      return playerStatsList;
    });
  }

  Stream<List<PlayerStatsHelperModel>> getPlayersStatsForMatch(
      String matchId, List<String> playerIdList) async* {
    final List<PlayerModel> players = await _getPlayers();
    PlayerModel findPlayer(String id) => players.firstWhere((e) => e.id == id,
        orElse: () => PlayerModel.dummy());

    yield* firestore
        .collection(playerStatsTable)
        .where("matchId", isEqualTo: matchId)
        .snapshots()
        .asyncMap((event) async {
      final List<PlayerStatsHelperModel> playerStatsWithAllPlayersFromMatch =
          [];
      List<String> usedPlayerList = [];
      for (var document in event.docs) {
        var playerStats = PlayerStatsModel.fromJson(document.data());
        playerStatsWithAllPlayersFromMatch.add(PlayerStatsHelperModel(
            id: playerStats.id,
            player: findPlayer(playerStats.playerId),
            goalNumber: playerStats.goalNumber,
            assistNumber: playerStats.assistNumber));
        usedPlayerList.add(playerStats.playerId);
      }
      for (String playerId in playerIdList) {
        if (!usedPlayerList.contains(playerId)) {
          playerStatsWithAllPlayersFromMatch.add(PlayerStatsHelperModel(
              id: PlayerStatsModel.dummy().id,
              player: findPlayer(playerId),
              goalNumber: 0,
              assistNumber: 0));
        }
      }
      return playerStatsWithAllPlayersFromMatch;
    });
  }

  Future<bool> addPlayerStatsInMatch(BuildContext context, String id,
      String matchId, String playerId, int goalNumber, int assistNumber) async {
    try {
      DocumentReference<Map<String, dynamic>> document;
      PlayerStatsModel playerStatsModel;
      if (id == PlayerStatsModel.dummy().id) {
        document = firestore.collection(playerStatsTable).doc();
        playerStatsModel = PlayerStatsModel(
          id: document.id,
          matchId: matchId,
          playerId: playerId,
          goalNumber: goalNumber,
          assistNumber: assistNumber,
        );
      } else {
        document = firestore.collection(playerStatsTable).doc(id);
        playerStatsModel = PlayerStatsModel(
          id: id,
          matchId: matchId,
          playerId: playerId,
          goalNumber: goalNumber,
          assistNumber: assistNumber,
        );
      }
      if (goalNumber == 0 && assistNumber == 0) {
        await _deleteMatchFromStatsTables(context, document.id, playerStatsTable);
      } else {
        await document.set(playerStatsModel.toJson());
      }
      return true;
    } on FirebaseException catch (e) {
      showSnackBar(
        context: context,
        content: e.message!,
      );
    }
    return false;
  }

  Future<void> _deleteMatchFromStatsTables(BuildContext context, String id, String table) async {
    await firestore.collection(table).doc(id).delete().then(
          (value) => {},
          onError: (e) => showSnackBar(
            context: context,
            content: e.message!,
          ),
        );
  }

  Future<void> deleteStatsFromTablesByMatch(
      BuildContext context, String matchId) async {
    await firestore
        .collection(playerStatsTable)
        .where("matchId", isEqualTo: matchId)
        .get()
        .then((value) async {
      for (var document in value.docs) {
        await _deleteMatchFromStatsTables(context, document.id, playerStatsTable);
      }
    });
    await firestore
        .collection(fineMatchTable)
        .where("matchId", isEqualTo: matchId)
        .get()
        .then((value) async {
      for (var document in value.docs) {
        await _deleteMatchFromStatsTables(context, document.id, fineMatchTable);
      }
    });
    await firestore
        .collection(beerTable)
        .where("matchId", isEqualTo: matchId)
        .get()
        .then((value) async {
      for (var document in value.docs) {
        await _deleteMatchFromStatsTables(context, document.id, beerTable);
      }
    });
  }
}
