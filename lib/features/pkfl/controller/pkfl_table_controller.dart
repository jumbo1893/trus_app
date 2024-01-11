import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/api/pkfl/pkfl_table_team.dart';
import '../../general/read_operations.dart';
import '../repository/pkfl_api_service.dart';

final pkflTableControllerProvider = Provider((ref) {
  final pkflApiService = ref.watch(pkflApiServiceProvider);
  return PkflTableController(ref: ref, pkflApiService: pkflApiService);
});

class PkflTableController implements ReadOperations{
  final PkflApiService pkflApiService;
  final ProviderRef ref;
  final snackBarController = StreamController<String>.broadcast();
  PkflTableController({
    required this.pkflApiService,
    required this.ref,
  });

  Stream<String> snackBar() {
    return snackBarController.stream;
  }

  @override
  Future<List<PkflTableTeam>> getModels() async {
    return await pkflApiService.getPkflTable();
  }
}
