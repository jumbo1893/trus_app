import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/fine_match_model.dart';
import 'package:trus_app/models/helper/beer_stats_helper_model.dart';
import 'package:trus_app/models/helper/fine_match_helper_model.dart';
import 'package:trus_app/models/fine_model.dart';
import 'package:trus_app/models/player_model.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../../common/utils/utils.dart';
import '../../../../config.dart';
import '../../../../models/beer_model.dart';
import '../../../models/helper/beer_helper_model.dart';
import '../../../models/helper/fine_match_stats_helper_model.dart';
import '../../../models/helper/fine_stats_helper_model.dart';
import '../../../models/match_model.dart';

final statsRepositoryProvider = Provider(
  (ref) => StatsRepository(firestore: FirebaseFirestore.instance),
);

class StatsRepository {
  final FirebaseFirestore firestore;

  StatsRepository({required this.firestore});

  List<String> _getListOfIdsFromMatches(List<MatchModel> matches) {
    List<String> matchIds = [];
    for(MatchModel matchModel in matches) {
      matchIds.add(matchModel.id);
    }
    return matchIds;
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

  Future<List<PlayerModel>> _getPlayersWithoutFans() async {
    final docRef = firestore.collection(playerTable).where("fan", isEqualTo: false);
    List<PlayerModel> players = [];
    await docRef.get().then((res) {
      for (var doc in res.docs) {
        var player = PlayerModel.fromJson(doc.data());

        players.add(player);
      }
    });
    return players;
  }

  Future<List<MatchModel>> _getMatches() async {
    final docRef = firestore.collection(matchTable);
    List<MatchModel> matches = [];
    await docRef.get().then((res) {
      for (var doc in res.docs) {
        var match = MatchModel.fromJson(doc.data());

        matches.add(match);
      }
    });
    return matches;
  }

  Future<List<String>> _getMatchIdsBySeason(String seasonId) async {
    List<String> matchIds = [];
    var docRef = firestore.collection(matchTable).where(
        "seasonId", isEqualTo: seasonId);
    if(seasonId == SeasonModel.allSeason().id) {
      docRef = firestore.collection(matchTable);
    }
    await docRef.get().then((res) {
      for (var doc in res.docs) {
        matchIds.add(doc.id);
      }
    });
    return matchIds;
  }

  Future<List<MatchModel>> _getMatchesBySeason(String seasonId) async {
    List<MatchModel> matches = [];
    var docRef = firestore.collection(matchTable).where(
        "seasonId", isEqualTo: seasonId);
    if(seasonId == SeasonModel.allSeason().id) {
      docRef = firestore.collection(matchTable);
    }
    await docRef.get().then((res) {
      for (var doc in res.docs) {
        var match = MatchModel.fromJson(doc.data());
        matches.add(match);
      }
    });
    return matches;
  }

  Future<List<PlayerModel>> _getPlayersById(List<String> playerListId) async {
    List<PlayerModel> players = [];
    for (String playerId in playerListId) {
      final docRef = firestore.collection(playerTable).doc(playerId);
      await docRef.get().then(
        (DocumentSnapshot doc) {
          final player =
              PlayerModel.fromJson(doc.data() as Map<String, dynamic>);
          players.add(player);
        },
        onError: (e) => print("Error getting document: $e"),
      );
    }
    return players;
  }

  Future<List<MatchModel>> getMatchesById(List<String> matchListId) async {
    List<MatchModel> matches = [];
    for (String matchId in matchListId) {
      final docRef = firestore.collection(matchTable).doc(matchId);
      await docRef.get().then(
            (DocumentSnapshot doc) {
          final match =
          MatchModel.fromJson(doc.data() as Map<String, dynamic>);
          matches.add(match);
        },
        onError: (e) => print("Error getting document: $e"),
      );
    }
    return matches;
  }

  Future<List<PlayerModel>> getPlayersById(List<String> playerListId) async {
    List<PlayerModel> players = [];
    for (String playerId in playerListId) {
      final docRef = firestore.collection(playerTable).doc(playerId);
      await docRef.get().then(
            (DocumentSnapshot doc) {
          final player =
          PlayerModel.fromJson(doc.data() as Map<String, dynamic>);
          players.add(player);
        },
        onError: (e) => print("Error getting document: $e"),
      );
    }
    return players;
  }

  Stream<List<BeerStatsHelperModel>> getBeersForPlayersInSeason(String seasonId) async* {
    final List<PlayerModel> players =
    await _getPlayers();
    List<String> matchIds = [];
    matchIds =
    await _getMatchIdsBySeason(seasonId);

    yield*
    firestore
        .collection(beerTable)
        .where("matchId", whereIn: matchIds)
        .snapshots()
        .asyncMap((event) async {
      List<BeerModel> beers = [];
      for (var document in event.docs) {
        var beer = BeerModel.fromJson(document.data());
        beers.add(beer);
      }
      final List<BeerStatsHelperModel> beersWithPlayers = [];
      for (PlayerModel player in players) {
        List<BeerModel> listOfBeers = beers.where((element) => (element.playerId == player.id && (element.beerNumber > 0 || element.liquorNumber > 0))).toList();
        if (listOfBeers.isNotEmpty) {
          beersWithPlayers.add(BeerStatsHelperModel(
              listOfBeers, player));
        }
      }
      return beersWithPlayers;
    });
  }

  Stream<List<BeerStatsHelperModel>> getBeersForMatchesInSeason(String seasonId) async* {
    List<MatchModel> matches = [];
    matches =
    await _getMatchesBySeason(seasonId);

    yield*
    firestore
        .collection(beerTable)
        .where("matchId", whereIn: _getListOfIdsFromMatches(matches))
        .snapshots()
        .asyncMap((event) async {
      List<BeerModel> beers = [];
      for (var document in event.docs) {
        var beer = BeerModel.fromJson(document.data());
        beers.add(beer);
      }
      final List<BeerStatsHelperModel> beersInMatches = [];
      for (MatchModel match in matches) {
        List<BeerModel> listOfBeers = beers.where((element) => (element.matchId == match.id && (element.beerNumber > 0 || element.liquorNumber > 0))).toList();
        if (listOfBeers.isNotEmpty) {
          beersInMatches.add(BeerStatsHelperModel(
              listOfBeers, null, match));
        }
      }
      return beersInMatches;
    });
  }

  Stream<List<FineStatsHelperModel>> getFinesForPlayersInSeason(String seasonId) async* {
    final List<PlayerModel> players =
    await _getPlayersWithoutFans();
    List<String> matchIds = [];
    matchIds =
    await _getMatchIdsBySeason(seasonId);

    yield*
    firestore
        .collection(fineMatchTable)
        .where("matchId", whereIn: matchIds)
        .snapshots()
        .asyncMap((event) async {
      List<FineMatchModel> finesMatch = [];
      List<String> finesIds = [];
      List<FineModel> fines = [];
      FineModel findFine(String id) =>
          fines.firstWhere((e) => e.id == id,
              orElse: () => FineModel.dummy());
      for (var document in event.docs) {
        var fine = FineMatchModel.fromJson(document.data());
        finesMatch.add(fine);
        finesIds.add(fine.fineId);
      }
      fines = await getFinesById(finesIds);
      final List<FineStatsHelperModel> finesWithPlayers = [];
      for (PlayerModel player in players) {
        List<FineMatchModel> listOfFinesMatches = finesMatch.where((element) => (element.playerId == player.id && element.number > 0)).toList();
        List<FineMatchStatsHelperModel> listOfFines = [];
        for(FineMatchModel fineMatchModel in listOfFinesMatches) {
          FineMatchStatsHelperModel fineMatchStatsHelperModel = FineMatchStatsHelperModel(id: fineMatchModel.id, fine: findFine(fineMatchModel.fineId), playerId: fineMatchModel.playerId, matchId: fineMatchModel.matchId, number: fineMatchModel.number);
          if(fineMatchStatsHelperModel.fine != FineModel.dummy()) {
            listOfFines.add(fineMatchStatsHelperModel);
          }
        }
        if (listOfFines.isNotEmpty) {
          finesWithPlayers.add(FineStatsHelperModel(listOfFines, player));
        }
      }
      return finesWithPlayers;
    });
  }

  Stream<List<FineStatsHelperModel>> getFinesForMatchesInSeason(String seasonId) async* {
    List<MatchModel> matches = [];
    matches =
    await _getMatchesBySeason(seasonId);

    yield*
    firestore
        .collection(fineMatchTable)
        .where("matchId", whereIn: _getListOfIdsFromMatches(matches))
        .snapshots()
        .asyncMap((event) async {
      List<FineMatchModel> finesMatch = [];
      List<String> finesIds = [];
      List<FineModel> fines = [];
      FineModel findFine(String id) =>
          fines.firstWhere((e) => e.id == id,
              orElse: () => FineModel.dummy());
      for (var document in event.docs) {
        var fine = FineMatchModel.fromJson(document.data());
        finesMatch.add(fine);
        finesIds.add(fine.fineId);
      }
      fines = await getFinesById(finesIds);
      final List<FineStatsHelperModel> finesWithPlayers = [];
      for (MatchModel match in matches) {
        List<FineMatchModel> listOfFinesMatches = finesMatch.where((element) => (element.matchId == match.id && element.number > 0)).toList();
        List<FineMatchStatsHelperModel> listOfFines = [];
        for(FineMatchModel fineMatchModel in listOfFinesMatches) {
          FineMatchStatsHelperModel fineMatchStatsHelperModel = FineMatchStatsHelperModel(id: fineMatchModel.id, fine: findFine(fineMatchModel.fineId), playerId: fineMatchModel.playerId, matchId: fineMatchModel.matchId, number: fineMatchModel.number);
          if(fineMatchStatsHelperModel.fine != FineModel.dummy()) {
            listOfFines.add(fineMatchStatsHelperModel);
          }
        }
        if (listOfFines.isNotEmpty) {
          finesWithPlayers.add(FineStatsHelperModel(listOfFines, null, match));
        }
      }
      return finesWithPlayers;
    });
  }

  Future<List<FineModel>> getFinesById(List<String> finesListId) async {
    List<FineModel> fines = [];
    for (String finesId in finesListId) {
      final docRef = firestore.collection(fineTable).doc(finesId);
      await docRef.get().then(
            (DocumentSnapshot doc) {
          final fine =
          FineModel.fromJson(doc.data() as Map<String, dynamic>);
          fines.add(fine);
        },
        onError: (e) => print("Error getting document: $e"),
      );
    }
    return fines;
  }

}
