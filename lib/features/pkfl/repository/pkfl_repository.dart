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
      showSnackBar(context: context, content: ("url pro tabulku úspěšně upravena"));
      return true;
    } on FirebaseException catch (e) {
      showSnackBar(context: context, content: e.message!, );
    }
    return false;
  }

}
