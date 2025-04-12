import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';

import '../../../common/utils/field_validator.dart';
import '../../../models/api/fine_api_model.dart';
import '../../general/crud_operations.dart';
import '../../general/read_operations.dart';
import '../repository/fine_api_service.dart';



final fineControllerProvider = Provider((ref) {
  final fineApiService = ref.watch(fineApiServiceProvider);
  return FineController(fineApiService: fineApiService, ref: ref);
});

class FineController with StringControllerMixin, BooleanControllerMixin implements CrudOperations, ReadOperations {
  final FineApiService fineApiService;
  final Ref ref;
  final loadingController = StreamController<bool>.broadcast();
  String originalFineName = "";

  String nameKey = "name";
  String amountKey = "amount";
  String inactiveKey = "inactive";

  FineController({
    required this.fineApiService,
    required this.ref,
  });

  void loadFine(FineApiModel fine) {
    initStringFields(fine.name, nameKey);
    initStringFields(fine.amount.toString(), amountKey);
    initBooleanFields(fine.inactive, inactiveKey);
    originalFineName = fine.name;
  }

  void loadNewFine() {
    initStringFields("", nameKey);
    initStringFields("0", amountKey);
  }

  Future<void> fine(FineApiModel fine) async {
    Future.delayed(
        Duration.zero,
            () => loadFine(fine));
  }

  Future<void> newFine() async {
    Future.delayed(
        Duration.zero,
            () => loadNewFine());
  }

  Stream<bool> loading() {
    return loadingController.stream;
  }

  bool validateFields() {
    String errorText = validateEmptyField(stringValues[nameKey]!.trim());
    String amountErrorText = validateAmountField(stringValues[amountKey]!.trim());
    stringErrorTextControllers[nameKey]!.add(errorText);
    stringErrorTextControllers[amountKey]!.add(amountErrorText);
    return (errorText.isEmpty && amountErrorText.isEmpty);
  }

  @override
  Future<FineApiModel?> addModel() async {
    loadingController.add(true);
    if(validateFields()) {
      return await fineApiService.addFine(
          FineApiModel(name: stringValues[nameKey]!, amount: int.parse(stringValues[amountKey]!.trim()), inactive: false));
    }
    return null;
  }

  @override
  Future<String> deleteModel(int id) async {
    await fineApiService.deleteFine(id);
    return "Pokuta $originalFineName úspěšně smazána";
  }

  @override
  Future<String?> editModel(int id) async {
    if(validateFields()) {
      FineApiModel response = await fineApiService.editFine(FineApiModel(id: id,
          name: stringValues[nameKey]!, amount: int.parse(stringValues[amountKey]!.trim()), inactive: boolValues[inactiveKey]!), id);

      return response.toStringForEdit(originalFineName);
    }
    return null;
  }

  @override
  Future<List<FineApiModel>> getModels() async {
    return await fineApiService.getFines();
  }

}
