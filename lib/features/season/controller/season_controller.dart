import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/crud_operations.dart';

import '../../../common/repository/exception/field_validation_exception.dart';
import '../../../common/repository/exception/model/field_model.dart';
import '../../../common/utils/field_validator.dart';
import '../../../models/api/season_api_model.dart';
import '../../general/read_operations.dart';
import '../repository/season_api_service.dart';

final seasonControllerProvider = Provider((ref) {
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  return SeasonController(seasonApiService: seasonApiService, ref: ref);
});

class SeasonController implements CrudOperations, ReadOperations {
  final SeasonApiService seasonApiService;
  final ProviderRef ref;
  final nameController = StreamController<String>.broadcast();
  final fromDateController = StreamController<DateTime>.broadcast();
  final toDateController = StreamController<DateTime>.broadcast();
  final nameErrorTextController = StreamController<String>.broadcast();
  final fromDateErrorTextController = StreamController<String>.broadcast();
  final toDateErrorTextController = StreamController<String>.broadcast();
  String originalSeasonName = "";
  String seasonName = "";
  DateTime seasonToDate = DateTime.now();
  DateTime seasonFromDate = DateTime.now();

  SeasonController({
    required this.seasonApiService,
    required this.ref,
  });

  void loadSeason(SeasonApiModel season) {
    setEditControllers(season);
    resetErrorTextControllers();
    setFieldsToSeason(season);
    originalSeasonName = season.name;
  }

  void loadNewSeason() {
    seasonName = "";
    nameController.add("");
    setDatesToNewSeason();
    resetErrorTextControllers();
  }

  void resetErrorTextControllers() {
    nameErrorTextController.add("");
    fromDateErrorTextController.add("");
    toDateErrorTextController.add("");
  }

  void setDatesToNewSeason() {
    int year = DateTime.now().year;
    int month = DateTime.now().month;
    DateTime fromDate;
    DateTime toDate;
    if (month <= 6) {
      fromDate = DateTime.utc(year, 1, 1);
      toDate = DateTime.utc(year, 1, 1);
    } else {
      fromDate = DateTime.utc(year, 9, 1);
      toDate = DateTime.utc(year, 12, 31);
    }
    seasonFromDate = fromDate;
    seasonToDate = toDate;
    fromDateController.add(fromDate);
    toDateController.add(toDate);
  }

  void setFieldsToSeason(SeasonApiModel season) {
    seasonName = season.name;
    seasonToDate = season.toDate;
    seasonFromDate = season.fromDate;
  }

  void setEditControllers(SeasonApiModel season) {
    nameController.add(season.name);
    fromDateController.add(season.fromDate);
    toDateController.add(season.toDate);
  }

  Future<void> season(SeasonApiModel season) async {
    Future.delayed(Duration.zero, () => loadSeason(season));
  }

  Stream<String> name() {
    return nameController.stream;
  }

  Future<void> newSeason() async {
    Future.delayed(Duration.zero, () => loadNewSeason());
  }

  Stream<String> nameErrorText() {
    return nameErrorTextController.stream;
  }

  Stream<String> fromDateErrorText() {
    return fromDateErrorTextController.stream;
  }

  Stream<String> toDateErrorText() {
    return toDateErrorTextController.stream;
  }

  Stream<DateTime> toDate() {
    return toDateController.stream;
  }

  Stream<DateTime> fromDate() {
    return fromDateController.stream;
  }

  void setName(String name) {
    nameController.add(name);
    seasonName = name;
  }

  void setToDate(DateTime date) {
    toDateController.add(date);
    seasonToDate = date;
    toDateErrorTextController.add("");
    fromDateErrorTextController.add("");
  }

  void setFromDate(DateTime date) {
    fromDateController.add(date);
    seasonFromDate = date;
    toDateErrorTextController.add("");
    fromDateErrorTextController.add("");
  }

  bool validateFields() {
    String errorText = validateEmptyField(seasonName.trim());
    nameErrorTextController.add(errorText);
    return validateNameField() && validateCalendarField();
  }

  bool validateNameField() {
    String errorText = validateEmptyField(seasonName.trim());
    nameErrorTextController.add(errorText);
    return errorText.isEmpty;
  }

  bool validateCalendarField() {
    String errorText = validateSeasonDate(seasonFromDate, seasonToDate);
    toDateErrorTextController.add(errorText);
    return errorText.isEmpty;
  }

  @override
  Future<SeasonApiModel?> addModel() async {
    if (validateFields()) {
      try {
        return await seasonApiService.addSeason(SeasonApiModel(
            name: seasonName, fromDate: seasonFromDate, toDate: seasonToDate));
      } on FieldValidationException catch (e) {
        if (e.fields != null) {
          for (FieldModel fieldModel in e.fields!) {
            if (fieldModel.field! =="toDate") {
              toDateErrorTextController.add(fieldModel.message!);
            }
            else if(fieldModel.field! =="fromDate") {
              fromDateErrorTextController.add(fieldModel.message!);
            }
          }
        }
      }
    }
    return null;
  }

  @override
  Future<String> deleteModel(
    int id,
  ) async {
    await seasonApiService.deleteSeason(id);
    return "Sezona $originalSeasonName úspěšně smazána";
  }

  @override
  Future<String?> editModel(
    int id,
  ) async {
    if (validateFields()) {
      try {
      SeasonApiModel response = await seasonApiService.editSeason(
          SeasonApiModel(id: id,
              name: seasonName, toDate: seasonToDate, fromDate: seasonFromDate),
          id);

      return response.toStringForEdit(originalSeasonName);
      } on FieldValidationException catch (e) {
        if (e.fields != null) {
          for (FieldModel fieldModel in e.fields!) {
            if (fieldModel.field! =="toDate") {
              toDateErrorTextController.add(fieldModel.message!);
            }
            else if(fieldModel.field! =="fromDate") {
              fromDateErrorTextController.add(fieldModel.message!);
            }
          }
        }
      }
    }
    return null;
  }

  @override
  Future<List<SeasonApiModel>> getModels() async {
    return await seasonApiService.getSeasons(false, false, false);
  }
}
