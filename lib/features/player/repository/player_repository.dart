import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../common/utils/firebase_exception.dart';
import '../../../common/utils/utils.dart';
import '../../../config.dart';

final playerRepositoryProvider = Provider(
    (ref) => PlayerRepository(
        firestore: FirebaseFirestore.instance),
);

class PlayerRepository extends CustomFirebaseException {
  final FirebaseFirestore firestore;

  PlayerRepository({
    required this.firestore
  });

  Stream<List<PlayerModel>> getPlayers() {
    return firestore.collection(playerTable).orderBy("name", descending: false).snapshots().map((event) {
      List<PlayerModel> players = [];
      for (var document in event.docs) {
        var player = PlayerModel.fromJson(document.data());
        players.add(player);
      }
      return players;
    });
  }

  Stream<List<PlayerModel>> getFilteredPlayersOrPlayers(bool fan) {
    return firestore.collection(playerTable).where('fan', isEqualTo: fan).snapshots().map((event) {
      List<PlayerModel> players = [];
      for (var document in event.docs) {
        var player = PlayerModel.fromJson(document.data());
        players.add(player);

      }
      return players;
    });
  }

  Future<bool> addPlayer(BuildContext context, String name, DateTime birthday, bool fan, bool active) async {
    try {
      final document = firestore.collection(playerTable).doc();
      PlayerModel player = PlayerModel(name: name, id: document.id, birthday: birthday, fan: fan, isActive: active);
      await document.set(player.toJson());
      showSnackBar(context: context, content: ("${fan ? "Fanoušek " : "Hráč "}$name úspěšně přidán"));
      return true;
    } on FirebaseException catch (e) {
      if (!showSnackBarOnException(e.code, context)) {
        showSnackBar(
          context: context,
          content: e.message!,
        );
      }
    }
    return false;
  }

  Future<bool> editPlayer(BuildContext context, String name, DateTime birthday, bool fan, bool active, PlayerModel playerModel) async {
    try {
      final document = firestore.collection(playerTable).doc(playerModel.id);
      PlayerModel player = PlayerModel(name: name, id: playerModel.id, birthday: birthday, fan: fan, isActive: active);
      await document.set(player.toJson());
      showSnackBar(context: context, content: ("${fan ? "Fanoušek " : "Hráč "}$name úspěšně upraven"));
      return true;
    } on FirebaseException catch (e) {
      if (!showSnackBarOnException(e.code, context)) {
        showSnackBar(
          context: context,
          content: e.message!,
        );
      }
    }
    return false;
  }

  Future<void> deletePlayer(BuildContext context, PlayerModel playerModel) async {
    bool fan = playerModel.fan;
    String name = playerModel.name;
    await  firestore.collection(playerTable).doc(playerModel.id).delete().then((
        value) =>
        showSnackBar(context: context,
            content: ("${fan
                ? "Fanoušek "
                : "Hráč "}$name úspěšně smazán")),
        onError: (e) => {
          if (!showSnackBarOnException(e.code, context))
            {
              showSnackBar(
                context: context,
                content: e.message!,
              )
            }
        });
  }

  Future<void> _deletePlayerFromStatsTables(BuildContext context, String id, String table) async {
    await firestore.collection(table).doc(id).delete().then(
          (value) => {},
      onError: (e) => {
        if (!showSnackBarOnException(e.code, context))
          {
            showSnackBar(
              context: context,
              content: e.message!,
            )
          }
      });
  }

  Future<void> deleteStatsFromTablesByPlayer(
      BuildContext context, String playerId) async {
    await firestore
        .collection(playerStatsTable)
        .where("playerId", isEqualTo: playerId)
        .get()
        .then((value) async {
      for (var document in value.docs) {
        await _deletePlayerFromStatsTables(context, document.id, playerStatsTable);
      }
    });
    await firestore
        .collection(fineMatchTable)
        .where("playerId", isEqualTo: playerId)
        .get()
        .then((value) async {
      for (var document in value.docs) {
        await _deletePlayerFromStatsTables(context, document.id, fineMatchTable);
      }
    });
    await firestore
        .collection(beerTable)
        .where("playerId", isEqualTo: playerId)
        .get()
        .then((value) async {
      for (var document in value.docs) {
        await _deletePlayerFromStatsTables(context, document.id, beerTable);
      }
    });
  }
}