import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/helper/beer_stats_helper_model.dart';
import 'package:trus_app/models/helper/fine_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../models/season_model.dart';
import '../repository/pkfl_repository.dart';

final pkflControllerProvider = Provider((ref) {
  final pkflRepository = ref.watch(pkflRepositoryProvider);
  return PkflController(pkflRepository: pkflRepository, ref: ref);
});

class PkflController {
  final PkflRepository pkflRepository;
  final ProviderRef ref;

  PkflController({
    required this.pkflRepository,
    required this.ref,
  });


  Future<String> url() async {
    return pkflRepository.getPkflUrl();
  }


}
