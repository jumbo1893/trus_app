import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/crud_operations.dart';

import '../../../models/api/player_api_model.dart';
import '../../../models/api/step/step_api_model.dart';
import '../../general/read_operations.dart';
import '../repository/step_api_service.dart';

final stepControllerProvider = Provider((ref) {
  final stepApiService = ref.watch(stepApiServiceProvider);
  return StepController(stepApiService: stepApiService, ref: ref);
});

class StepController implements CrudOperations, ReadOperations {
  final StepApiService stepApiService;
  final ProviderRef ref;
  final stepController = StreamController<int>.broadcast();
  int stepNumber = 0;

  StepController({
    required this.stepApiService,
    required this.ref,
  });

  Stream<int> step() {
    return stepController.stream;
  }

  void setStepNumber(int stepNumber) {
    stepController.add(stepNumber);
    this.stepNumber = stepNumber;
  }

  @override
  Future<StepApiModel?> addModel() async {

      return await stepApiService.addStep(StepApiModel(
        stepNumber: stepNumber,
          ));
  }

  @override
  Future<String> deleteModel(int id) async {
    return "";
  }

  @override
  Future<String?> editModel(int id) async {
    return null;
  }

  @override
  Future<List<PlayerApiModel>> getModels() async {
    return [];
  }
}
