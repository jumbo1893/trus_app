import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/repository/fine_repository.dart';
import 'package:trus_app/models/fine_model.dart';

import '../../../common/utils/field_validator.dart';
import '../../../models/api/fine_api_model.dart';
import '../../general/crud_operations.dart';
import '../../general/read_operations.dart';
import '../repository/fine_api_service.dart';



final fineControllerProvider = Provider((ref) {
  final fineRepository = ref.watch(fineRepositoryProvider);
  final fineApiService = ref.watch(fineApiServiceProvider);
  return FineController(fineRepository: fineRepository, fineApiService: fineApiService, ref: ref);
});

class FineController implements CrudOperations, ReadOperations {
  final FineRepository fineRepository;
  final FineApiService fineApiService;
  final ProviderRef ref;
  final nameController = StreamController<String>.broadcast();
  final amountController = StreamController<String>.broadcast();
  final nameErrorTextController = StreamController<String>.broadcast();
  final amountErrorTextController = StreamController<String>.broadcast();
  final loadingController = StreamController<bool>.broadcast();
  String originalFineName = "";
  String fineName = "";
  String fineAmount = "0";

  FineController({
    required this.fineRepository,
    required this.fineApiService,
    required this.ref,
  });

  void loadFine(FineApiModel fine) {
    setEditControllers(fine);
    resetErrorTextControllers();
    setFieldsToPlayer(fine);
    originalFineName = fine.name;
  }

  void loadNewFine() {
    nameController.add("");
    amountController.add("0");
    resetErrorTextControllers();
    fineName = "";
    fineAmount = "0";
  }

  void resetErrorTextControllers() {
    nameErrorTextController.add("");
    amountErrorTextController.add("");
  }

  void setFieldsToPlayer(FineApiModel fine) {
    fineName = fine.name;
    fineAmount = fine.amount.toString();
  }

  void setEditControllers(FineApiModel fine) {
    nameController.add(fine.name);
    amountController.add(fine.amount.toString());
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

  Stream<List<FineModel>> fines() {
    return fineRepository.getFines();
  }

  Stream<String> name() {
    return nameController.stream;
  }

  Stream<String> nameErrorText() {
    return nameErrorTextController.stream;
  }

  Stream<String> amountErrorText() {
    return amountErrorTextController.stream;
  }

  Stream<String> amount() {
    return amountController.stream;
  }

  void setName(String name) {
    nameController.add(name);
    fineName = name;
  }

  void setAmount(String amount) {
    amountController.add(amount);
    fineAmount = amount;
  }

  bool validateFields() {
    String errorText = validateEmptyField(fineName.trim());
    String amountErrorText = validateAmountField(fineAmount);
    nameErrorTextController.add(errorText);
    amountErrorTextController.add(amountErrorText);
    return (errorText.isEmpty && amountErrorText.isEmpty);
  }

  @override
  Future<FineApiModel?> addModel() async {
    loadingController.add(true);
    if(validateFields()) {
      return await fineApiService.addFine(
          FineApiModel(name: fineName, amount: int.parse(fineAmount)));
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
      FineApiModel response = await fineApiService.editFine(FineApiModel(
          name: fineName, amount: int.parse(fineAmount)), id);

      return response.toStringForEdit(originalFineName);
    }
    return null;
  }

  @override
  Future<List<FineApiModel>> getModels() async {
    return await fineApiService.getFines();
  }

}
