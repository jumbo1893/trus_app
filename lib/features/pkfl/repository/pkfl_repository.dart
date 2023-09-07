import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/utils/utils.dart';
import '../../../../config.dart';

final pkflRepositoryProvider = Provider(
  (ref) => PkflRepository(firestore: FirebaseFirestore.instance),
);

class PkflRepository {
  final FirebaseFirestore firestore;

  PkflRepository({required this.firestore});

  Future<String> getPkflTeamUrl() async {
    String url ="";
      final docRef = firestore.collection(pkflTable).doc("url");
      await docRef.get().then(
            (DocumentSnapshot doc) {
          Map data = doc.data() as Map;
          url = data['team_url'];
        },
        onError: (e) => print("Error getting document: $e"),
      );
    return url;
  }

  Future<String> getPkflTableUrl() async {
    String url ="";
    final docRef = firestore.collection(pkflTable).doc("url");
    await docRef.get().then(
          (DocumentSnapshot doc) {
        Map data = doc.data() as Map;
        url = data['table_url'];
      },
      onError: (e) => print("Error getting document: $e"),
    );
    return url;
  }

  Future<bool> editPlayer(BuildContext context, String tableUrl) async {
    try {
      final document = firestore.collection(pkflTable).doc("url");
      await document.update({"table_url": tableUrl});
      showSnackBarWithPostFrame(context: context, content: ("url pro tabulku úspěšně upravena"));
      return true;
    } on FirebaseException catch (e) {
      showSnackBarWithPostFrame(context: context, content: e.message!, );
    }
    return false;
  }

}
