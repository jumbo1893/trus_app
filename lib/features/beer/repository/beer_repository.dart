import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/helper/fine_match_helper_model.dart';
import 'package:trus_app/models/fine_model.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../../common/utils/utils.dart';
import '../../../../config.dart';
import '../../../../models/beer_model.dart';
import '../../../common/utils/firebase_exception.dart';
import '../../../models/helper/beer_helper_model.dart';
import '../../../models/match_model.dart';

final beerRepositoryProvider = Provider(
  (ref) => BeerRepository(firestore: FirebaseFirestore.instance),
);

class BeerRepository extends CustomFirebaseException {
  final FirebaseFirestore firestore;

  BeerRepository({required this.firestore});

  Stream<List<BeerModel>> getBeersInMatches() {
    return firestore.collection(beerTable).snapshots().map((event) {
      List<BeerModel> beersInMatches = [];
      for (var document in event.docs) {
        var beer = BeerModel.fromJson(document.data());
        beersInMatches.add(beer);
      }
      return beersInMatches;
    });
  }

  Stream<List<PlayerModel>> getPlayers() {
    return firestore
        .collection(playerTable)
        .orderBy("name")
        .snapshots()
        .map((event) {
      List<PlayerModel> players = [];
      for (var document in event.docs) {
        var player = PlayerModel.fromJson(document.data());
        players.add(player);
      }
      return players;
    });
  }

  Stream<List<BeerHelperModel>> getBeersInMatch(MatchModel matchModel) async* {
    final List<PlayerModel> players =
        await _getPlayersById(matchModel.playerIdList);
    yield* firestore
        .collection(beerTable)
        .where("matchId", isEqualTo: matchModel.id)
        .snapshots()
        .asyncMap((event) async {
      List<BeerModel> beers = [];
      for (var document in event.docs) {
        var beer = BeerModel.fromJson(document.data());
        beers.add(beer);
      }
      final List<BeerHelperModel> beersWithPlayers = [];
      BeerModel findBeer(PlayerModel playerModel) =>
          beers.firstWhere((e) => e.playerId == playerModel.id,
              orElse: () => BeerModel.dummy());
      for (PlayerModel player in players) {
        BeerModel foundBeer = findBeer(player);

        beersWithPlayers.add(BeerHelperModel(
            id: foundBeer.id,
            beerNumber: foundBeer.beerNumber,
            liquorNumber: foundBeer.liquorNumber,
            player: player));
      }
      return beersWithPlayers;
    });
  }

  Future<List<BeerModel>> _getBeerInMatchForPlayer(
      String playerId, String matchId) async {
    final docRef =
        firestore.collection(beerTable).where("matchId", isEqualTo: matchId);
    List<BeerModel> beerInMatches = [];
    await docRef.get().then((res) {
      for (var doc in res.docs) {
        var beer = BeerModel.fromJson(doc.data());
        beerInMatches.add(beer);
      }
    });
    return beerInMatches;
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

  Future<bool> addBeerInMatch(
      BuildContext context,
      String id,
      String matchId,
      String playerId,
      int beerNumber,
      int liquorNumber) async {
    try {
      DocumentReference<Map<String, dynamic>> document;
      BeerModel beer;
      if (id == BeerModel.dummy().id) {
        document = firestore.collection(beerTable).doc();
        beer = BeerModel(
          id: document.id,
          matchId: matchId,
          playerId: playerId,
          beerNumber: beerNumber,
          liquorNumber: liquorNumber,
        );
      } else {
        document = firestore.collection(beerTable).doc(id);
        beer = BeerModel(
          id: id,
          matchId: matchId,
          playerId: playerId,
          beerNumber: beerNumber,
          liquorNumber: liquorNumber,
        );
      }
      await document.set(beer.toJson());
      return true;
    } on FirebaseException catch (e) {
      if(!showSnackBarOnException(e.code, context)) {
        showSnackBar(
          context: context,
          content: e.message!,
        );
      }
    }
    return false;
  }
}
