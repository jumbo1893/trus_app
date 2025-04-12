import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/crud_operations.dart';
import 'package:trus_app/features/mixin/date_controller_mixin.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';

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

class SeasonController
    with StringControllerMixin, DateControllerMixin
    implements CrudOperations, ReadOperations {
  final SeasonApiService seasonApiService;
  final Ref ref;
  String originalSeasonName = "";

  String nameKey = "name";
  String fromKey = "from";
  String toKey = "to";

  SeasonController({
    required this.seasonApiService,
    required this.ref,
  });

  void loadSeason(SeasonApiModel season) {
    initStringFields(season.name, nameKey);
    initDateFields(season.toDate, toKey);
    initDateFields(season.fromDate, fromKey);
    originalSeasonName = season.name;
  }

  void loadNewSeason() {
    initStringFields("", nameKey);
    setDatesToNewSeason();
  }

  void setDatesToNewSeason() {
    int year = DateTime.now().year;
    int month = DateTime.now().month;
    DateTime fromDate;
    DateTime toDate;
    if (month <= 6) {
      fromDate = DateTime.utc(year, 1, 1);
      toDate = DateTime.utc(year, 7, 1);
    } else {
      fromDate = DateTime.utc(year, 9, 1);
      toDate = DateTime.utc(year, 12, 31);
    }
    initDateFields(toDate, toKey);
    initDateFields(fromDate, fromKey);
  }

  Future<void> season(SeasonApiModel season) async {
    Future.delayed(Duration.zero, () => loadSeason(season));
  }

  Future<void> newSeason() async {
    Future.delayed(Duration.zero, () => loadNewSeason());
  }

  bool validateFields() {
    String errorText = validateEmptyField((stringValues[nameKey]!.trim()));
    stringErrorTextControllers[nameKey]!.add(errorText);
    return validateNameField() && validateCalendarField();
  }

  bool validateNameField() {
    String errorText = validateEmptyField(stringValues[nameKey]!.trim());
    stringErrorTextControllers[nameKey]!.add(errorText);
    return errorText.isEmpty;
  }

  bool validateCalendarField() {
    String errorText =
        validateSeasonDate(dateValues[fromKey]!, dateValues[toKey]!);
    dateErrorTextControllers[toKey]!.add(errorText);
    return errorText.isEmpty;
  }

  @override
  Future<SeasonApiModel?> addModel() async {
    if (validateFields()) {
      try {
        return await seasonApiService.addSeason(SeasonApiModel(
            name: stringValues[nameKey]!,
            fromDate: dateValues[fromKey]!,
            toDate: dateValues[toKey]!));
      } on FieldValidationException catch (e) {
        if (e.fields != null) {
          for (FieldModel fieldModel in e.fields!) {
            if (fieldModel.field! == "toDate") {
              dateErrorTextControllers[toKey]!.add(fieldModel.message!);
            } else if (fieldModel.field! == "fromDate") {
              dateErrorTextControllers[fromKey]!.add(fieldModel.message!);
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
            SeasonApiModel(
                id: id,
                name: stringValues[nameKey]!,
                toDate: dateValues[toKey]!,
                fromDate: dateValues[fromKey]!),
            id);

        return response.toStringForEdit(originalSeasonName);
      } on FieldValidationException catch (e) {
        if (e.fields != null) {
          for (FieldModel fieldModel in e.fields!) {
            if (fieldModel.field! == "toDate") {
              dateErrorTextControllers[toKey]!.add(fieldModel.message!);
            } else if (fieldModel.field! == "fromDate") {
              dateErrorTextControllers[fromKey]!.add(fieldModel.message!);
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
