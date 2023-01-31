import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../common/utils/utils.dart';
import '../../../config.dart';

final seasonRepositoryProvider = Provider(
    (ref) => SeasonRepository(
        firestore: FirebaseFirestore.instance),
);

class SeasonRepository {
  final FirebaseFirestore firestore;

  SeasonRepository({
    required this.firestore
  });

  Stream<List<SeasonModel>> getSeasons() {
    return firestore.collection(seasonTable).snapshots().map((event) {
      List<SeasonModel> seasons = [];
      for (var document in event.docs) {
        var season = SeasonModel.fromJson(document.data());
        seasons.add(season);
      }
      return seasons;
    });
  }

  Future<bool> addSeason(BuildContext context, String name, DateTime fromDate, DateTime toDate) async {
    try {
      final document = firestore.collection(seasonTable).doc();
      SeasonModel season = SeasonModel(name: name, id: document.id, fromDate: fromDate, toDate: toDate);
      await document.set(season.toJson());
      showSnackBar(context: context, content: ("Sezona $name úspěšně přidána"));
      return true;
    } on FirebaseException catch (e) {
      showSnackBar(context: context, content: e.message!, );
    }
    return false;
  }

  Future<bool> editSeason(BuildContext context, String name, DateTime fromDate, DateTime toDate, SeasonModel seasonModel) async {
    try {
      final document = firestore.collection(seasonTable).doc(seasonModel.id);
      SeasonModel season = SeasonModel(name: name, id: seasonModel.id, fromDate: fromDate, toDate: toDate);
      await document.set(season.toJson());
      showSnackBar(context: context, content: ("Sezona $name úspěšně upravena"));
      return true;
    } on FirebaseException catch (e) {
      showSnackBar(context: context, content: e.message!, );
    }
    return false;
  }

  Future<void> deleteSeason(BuildContext context, SeasonModel seasonModel) async {
    String name = seasonModel.name;
    await  firestore.collection(seasonTable).doc(seasonModel.id).delete().then((
        value) =>
        showSnackBar(context: context, content: ("Sezona $name úspěšně smazána")),
        onError: (e) => showSnackBar(context: context, content: e.message!,),);
  }
}