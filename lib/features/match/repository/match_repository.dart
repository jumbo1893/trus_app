import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/match_model.dart';

import '../../../common/utils/utils.dart';
import '../../../config.dart';

final matchRepositoryProvider = Provider(
    (ref) => MatchRepository(
        firestore: FirebaseFirestore.instance),
);

class MatchRepository {
  final FirebaseFirestore firestore;

  MatchRepository({
    required this.firestore
  });

  Stream<List<MatchModel>> getMatches() {
    return firestore.collection(matchTable).snapshots().map((event) {
      print("1");
      List<MatchModel> matches = [];
      print(event.docs.length);
      for (var document in event.docs) {
        var match = MatchModel.fromJson(document.data());
        matches.add(match);
      }
      return matches;
    });
  }

  Stream<List<MatchModel>> getMatchesBySeason(String seasonId) {
    return firestore.collection(matchTable).where("seasonId", isEqualTo: seasonId).snapshots().map((event) {
      List<MatchModel> matches = [];
      for (var document in event.docs) {
        var match = MatchModel.fromJson(document.data());
        matches.add(match);
      }
      return matches;
    });
  }

  Future<bool> addMatch(BuildContext context, String name, DateTime date, bool home, List<String> playerIdList, String seasonId) async {
    try {
      final document = firestore.collection(matchTable).doc();
      MatchModel match = MatchModel(name: name, id: document.id, date: date, home: home, playerIdList: playerIdList, seasonId: seasonId);
      await document.set(match.toJson());
      showSnackBar(context: context, content: ("Zápas $name úspěšně přidán"));
      return true;
    } on FirebaseException catch (e) {
      showSnackBar(context: context, content: e.message!, );
    }
    return false;
  }

  Future<bool> editMatch(BuildContext context, String name, DateTime date, bool home, List<String> playerIdList, String seasonId, MatchModel matchModel) async {
    try {
      final document = firestore.collection(matchTable).doc(matchModel.id);
      MatchModel match = MatchModel(name: name, id: matchModel.id, date: date, home: home, playerIdList: playerIdList, seasonId: seasonId);
      await document.set(match.toJson());
      showSnackBar(context: context, content: ("Zápas $name úspěšně upraven"));
      return true;
    } on FirebaseException catch (e) {
      showSnackBar(context: context, content: e.message!, );
    }
    return false;
  }

  Future<void> deleteMatch(BuildContext context, MatchModel matchModel) async {
    String name = matchModel.name;
    await  firestore.collection(matchTable).doc(matchModel.id).delete().then((
        value) =>
        showSnackBar(context: context, content: ("Zápas $name úspěšně smazán")),
        onError: (e) => showSnackBar(context: context, content: e.message!,),);
  }
}