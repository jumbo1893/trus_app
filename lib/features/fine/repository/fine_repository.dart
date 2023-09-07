import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/firebase_exception.dart';
import '../../../common/utils/utils.dart';
import '../../../config.dart';
import '../../../models/fine_model.dart';

final fineRepositoryProvider = Provider(
  (ref) => FineRepository(firestore: FirebaseFirestore.instance),
);

class FineRepository extends CustomFirebaseException {
  final FirebaseFirestore firestore;

  FineRepository({required this.firestore});

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

  Future<bool> addFine(BuildContext context, String name, int amount) async {
    try {
      final document = firestore.collection(fineTable).doc();
      FineModel fine = FineModel(name: name, id: document.id, amount: amount, toDelete: true);
      await document.set(fine.toJson());
      showSnackBarWithPostFrame(context: context, content: ("Pokuta $name úspěšně přidána"));
      return true;
    } on FirebaseException catch (e) {
      if (!showSnackBarOnException(e.code, context)) {
        showSnackBarWithPostFrame(
          context: context,
          content: e.message!,
        );
      }
    }
    return false;
  }

  Future<bool> editFine(BuildContext context, String name, int amount,
      FineModel fineModel) async {
    try {
      final document = firestore.collection(fineTable).doc(fineModel.id);
      FineModel fine = FineModel(name: name, id: fineModel.id, amount: amount, toDelete: true);
      await document.set(fine.toJson());
      showSnackBarWithPostFrame(
          context: context, content: ("Pokuta $name úspěšně upravena"));
      return true;
    } on FirebaseException catch (e) {
      if (!showSnackBarOnException(e.code, context)) {
        showSnackBarWithPostFrame(
          context: context,
          content: e.message!,
        );
      }
    }
    return false;
  }

  Future<void> deleteFine(BuildContext context, FineModel fineModel) async {
    String name = fineModel.name;
    if (fineModel.toDelete) {
      await firestore.collection(fineTable).doc(fineModel.id).delete().then(
              (value) =>
              showSnackBarWithPostFrame(
                  context: context, content: ("Pokuta $name úspěšně smazána")),
          onError: (e) =>
          {
            if (!showSnackBarOnException(e.code, context))
              {
                showSnackBarWithPostFrame(
                  context: context,
                  content: e.message!,
                )
              }
          });
    }
    else {
      showSnackBarWithPostFrame(
          context: context,
          content: "Tuto pokutu nelze smazat",);
    }
  }
}
