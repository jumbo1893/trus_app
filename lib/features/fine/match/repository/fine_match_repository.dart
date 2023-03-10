import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/helper/fine_match_helper_model.dart';
import 'package:trus_app/models/fine_model.dart';

import '../../../../common/utils/firebase_exception.dart';
import '../../../../common/utils/utils.dart';
import '../../../../config.dart';
import '../../../../models/fine_match_model.dart';

final fineMatchRepositoryProvider = Provider(
  (ref) => FineMatchRepository(firestore: FirebaseFirestore.instance),
);

class FineMatchRepository extends CustomFirebaseException {
  final FirebaseFirestore firestore;

  FineMatchRepository({required this.firestore});

  Stream<List<FineMatchModel>> getFinesInMatches() {
    return firestore.collection(fineMatchTable).snapshots().map((event) {
      List<FineMatchModel> finesInMatches = [];
      for (var document in event.docs) {
        var fine = FineMatchModel.fromJson(document.data());
        finesInMatches.add(fine);
      }
      return finesInMatches;
    });
  }

  Stream<List<FineModel>> getFines() {
    return firestore
        .collection(fineTable)
        .orderBy("name")
        .snapshots()
        .map((event) {
      List<FineModel> fines = [];
      for (var document in event.docs) {
        var fine = FineModel.fromJson(document.data());
        fines.add(fine);
      }
      return fines;
    });
  }

  Stream<List<FineMatchHelperModel>> getFinesInMatchForPlayer(
      String playerId, String matchId) async* {
    final List<FineMatchModel> finesInMatches =
        await _getFinesInMatchForPlayer(playerId, matchId);
    yield* firestore
        .collection(fineTable)
        .orderBy("name")
        .snapshots()
        .asyncMap((event) async {
      List<FineModel> fines = [];
      for (var document in event.docs) {
        var fine = FineModel.fromJson(document.data());
        fines.add(fine);
      }
      final List<FineMatchHelperModel> finesWithPlayersInMatches = [];
      FineMatchModel findFine(String id) =>
          finesInMatches.firstWhere((e) => e.fineId == id,
              orElse: () => FineMatchModel.dummy());
      for (FineModel fineModel in fines) {
        FineMatchModel foundFine = findFine(fineModel.id);
        finesWithPlayersInMatches.add(FineMatchHelperModel(
            id: foundFine.id, fine: fineModel, number: foundFine.number));
      }
      return finesWithPlayersInMatches;
    });
  }

  Future<List<FineMatchModel>> _getFinesInMatchForPlayer(
      String playerId, String matchId) async {
    final docRef = firestore
        .collection(fineMatchTable)
        .where("matchId", isEqualTo: matchId)
        .where("playerId", isEqualTo: playerId);
    List<FineMatchModel> finesInMatches = [];
    await docRef.get().then((res) {
      for (var doc in res.docs) {
        var fine = FineMatchModel.fromJson(doc.data());
        finesInMatches.add(fine);
      }
    });
    return finesInMatches;
  }

  Future<bool> addFineInMatch(BuildContext context, String id, String matchId,
      String fineId, String playerId, int number) async {
    try {
      DocumentReference<Map<String, dynamic>> document;
      FineMatchModel fine;
      if (id == FineMatchModel.dummy().id) {
        document = firestore.collection(fineMatchTable).doc();
        fine = FineMatchModel(
            id: document.id,
            matchId: matchId,
            fineId: fineId,
            playerId: playerId,
            number: number);
      } else {
        document = firestore.collection(fineMatchTable).doc(id);
        fine = FineMatchModel(
            id: id,
            matchId: matchId,
            fineId: fineId,
            playerId: playerId,
            number: number);
      }
      await document.set(fine.toJson());
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

  Future<bool> addMultipleFinesInMatch(BuildContext context, String matchId,
      String fineId, String playerId, int number, bool rewrite) async {
    try {
      await firestore
          .collection(fineMatchTable)
          .where("matchId", isEqualTo: matchId)
          .where("fineId", isEqualTo: fineId)
          .where("playerId", isEqualTo: playerId)
          .get()
          .then((value) async {
        if (value.size > 1) {
          showSnackBar(
            context: context,
            content:
                "existuje víc než jeden záznam v tabulce!!!! kontaktuj správce",
          );
        } else if (value.size == 1) {
          await _addFineNumberInMatch(context, number,
              FineMatchModel.fromJson(value.docs[0].data()), rewrite);
        } else {
          await addFineInMatch(context, FineMatchModel.dummy().id, matchId,
              fineId, playerId, number);
        }
      });
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

  Future<bool> _addFineNumberInMatch(BuildContext context, int number,
      FineMatchModel fineMatchModel, bool rewrite) async {
    try {
      final document =
          firestore.collection(fineMatchTable).doc(fineMatchModel.id);
      FineMatchModel fine = FineMatchModel(
          id: fineMatchModel.id,
          matchId: fineMatchModel.matchId,
          fineId: fineMatchModel.fineId,
          playerId: fineMatchModel.playerId,
          number: rewrite ? number : fineMatchModel.number + number);
      await document.set(fine.toJson());
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

  Future<void> deleteFineInMatch(
      BuildContext context, FineMatchModel fineMatchModel) async {
    await firestore
        .collection(fineMatchTable)
        .doc(fineMatchModel.id)
        .delete()
        .then((value) => {},
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
}
