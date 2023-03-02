import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/statistics/helper/beer_stats_helper.dart';
import 'package:trus_app/features/statistics/helper/fine_stats_helper.dart';
import 'package:trus_app/models/fine_match_model.dart';
import 'package:trus_app/models/helper/beer_stats_helper_model.dart';
import 'package:trus_app/models/helper/fine_match_helper_model.dart';
import 'package:trus_app/models/fine_model.dart';
import 'package:trus_app/models/helper/player_stats_helper_model.dart';
import 'package:trus_app/models/player_model.dart';
import 'package:trus_app/models/player_stats_model.dart';
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

  Stream<List<BeerStatsHelperModel>> getBeersForPlayersInSeason(SeasonModel? season) async* {
    final List<PlayerModel> players =
    await _getPlayers();
    List<String> matchIds = [];
    season ??= await getCurrentSeason();
    matchIds =
    await _getMatchIdsBySeason(season.id);

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
      BeerStatsHelper beerStatsHelper = BeerStatsHelper(beers);
      return beerStatsHelper.convertBeerModelToBeerStatsHelperModelForPlayers(players);
    });
  }

  Stream<List<BeerStatsHelperModel>> getBeersForMatchesInSeason(SeasonModel? season) async* {
    List<MatchModel> matches = [];
    season ??= await getCurrentSeason();
    matches =
    await _getMatchesBySeason(season.id);
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
      BeerStatsHelper beerStatsHelper = BeerStatsHelper(beers);
      return beerStatsHelper.convertBeerModelToBeerStatsHelperModelForMatches(matches);
    });
  }

  Stream<List<FineStatsHelperModel>> getFinesForPlayersInSeason(SeasonModel? season) async* {
    final List<PlayerModel> players =
    await _getPlayersWithoutFans();
    List<String> matchIds = [];
    season ??= await getCurrentSeason();
    matchIds =
    await _getMatchIdsBySeason(season.id);
    yield*
    firestore
        .collection(fineMatchTable)
        .where("matchId", whereIn: matchIds)
        .snapshots()
        .asyncMap((event) async {
      List<FineMatchModel> finesMatch = [];
      List<String> finesIds = [];
      List<FineModel> fines = [];
      for (var document in event.docs) {
        var fine = FineMatchModel.fromJson(document.data());
        finesMatch.add(fine);
        finesIds.add(fine.fineId);
      }
      fines = await getFinesById(finesIds);
      FineStatsHelper fineStatsHelper = FineStatsHelper(fines, finesMatch);
      return fineStatsHelper.convertFineModelToFineStatsHelperModelForPlayers(players);
    });
  }

  Stream<List<FineStatsHelperModel>> getFinesForMatchesInSeason(SeasonModel? season) async* {
    List<MatchModel> matches = [];
    season ??= await getCurrentSeason();
    matches =
    await _getMatchesBySeason(season.id);
    yield*
    firestore
        .collection(fineMatchTable)
        .where("matchId", whereIn: _getListOfIdsFromMatches(matches))
        .snapshots()
        .asyncMap((event) async {
      List<FineMatchModel> finesMatch = [];
      List<String> finesIds = [];
      List<FineModel> fines = [];
      for (var document in event.docs) {
        var fine = FineMatchModel.fromJson(document.data());
        finesMatch.add(fine);
        finesIds.add(fine.fineId);
      }
      fines = await getFinesById(finesIds);
      FineStatsHelper fineStatsHelper = FineStatsHelper(fines, finesMatch);
      return fineStatsHelper.convertFineModelToFineStatsHelperModelForMatches(matches);
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

  Future<SeasonModel> getCurrentSeason() async {
    List<SeasonModel> seasons = [];
    final docRef = firestore.collection(seasonTable).where("fromDate", isLessThanOrEqualTo: DateTime.now().millisecondsSinceEpoch).orderBy("fromDate");
    await docRef.get().then((res) {
      for (var doc in res.docs) {
        var season = SeasonModel.fromJson(doc.data());
        seasons.add(season);
      }
    });
      return seasons.firstWhere((element) => element.toDate.isBefore(DateTime.now()), orElse: () => SeasonModel.otherSeason());
  }

  Stream<List<PlayerStatsHelperModel>> getPlayerStatsForPlayersInSeason(SeasonModel? season) async* {
    final List<PlayerModel> players =
    await _getPlayers();
    List<String> matchIds = [];
    season ??= await getCurrentSeason();
    matchIds =
    await _getMatchIdsBySeason(season.id);

    yield*
    firestore
        .collection(playerStatsTable)
        .where("matchId", whereIn: matchIds)
        .snapshots()
        .asyncMap((event) async {
      final HashMap<String, PlayerStatsHelperModel> playerStatsHashMap = HashMap();
      PlayerModel findPlayer(String id) =>
          players.firstWhere((e) => e.id == id,
              orElse: () => PlayerModel.dummy());
      for (var document in event.docs) {
        var player = PlayerStatsModel.fromJson(document.data());
        if(playerStatsHashMap[player.playerId] == null) {
          playerStatsHashMap.addAll({player.playerId : PlayerStatsHelperModel(id: player.id,
              player: findPlayer(player.playerId),
              goalNumber: player.goalNumber,
              assistNumber: player.assistNumber)});
        }
        else {
          playerStatsHashMap[player.playerId]!.addAssistAndGoalNumber(player.assistNumber, player.goalNumber);
        }
      }
      return playerStatsHashMap.values.toList();
    });
  }

}
