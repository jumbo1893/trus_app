import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/read_operations.dart';
import 'package:trus_app/models/api/pkfl/pkfl_match_api_model.dart';
import '../repository/pkfl_api_service.dart';

final pkflControllerProvider = Provider((ref) {
  final pkflApiService = ref.watch(pkflApiServiceProvider);
  return PkflController(ref: ref, pkflApiService: pkflApiService);
});

class PkflController implements ReadOperations{
  final PkflApiService pkflApiService;
  final ProviderRef ref;
  final snackBarController = StreamController<String>.broadcast();
  PkflController({
    required this.pkflApiService,
    required this.ref,
  });

  Stream<String> snackBar() {
    return snackBarController.stream;
  }

  @override
  Future<List<PkflMatchApiModel>> getModels() async {
    return await pkflApiService.getPkflFixtures();
  }
}
