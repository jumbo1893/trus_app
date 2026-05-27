import 'package:flutter/material.dart';

import '../../common/widgets/dropdown/app_multi_select.dart';
import '../../common/widgets/dropdown/custom_dropdown_sheet.dart';
import '../../common/widgets/rows/app_date_field.dart';
import '../../common/widgets/rows/app_switch_field.dart';
import '../../common/widgets/rows/app_text_input_field.dart';
import '../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../models/api/player/player_api_model.dart';

List<Widget> matchFields(
    dynamic state,
    dynamic notifier,
    ) {
  return [
    FormFieldWrapper(
      label: "Jméno soupeře",
      error: state.errors["name"],
      child: AppTextInputField(
        value: state.name,
        onChanged: notifier.setName,
      ),
    ),
    FormFieldWrapper(
      label: "Datum zápasu",
      error: state.errors["fromDate"],
      child: AppDateField(
        label: "Datum zápasu",
        value: state.date,
        onChanged: notifier.setDate,
      ),
    ),
    FormFieldWrapper(
      label: "Domácí zápas",
      child: AppSwitchField(
        text: "domácí?",
        value: state.home,
        onChanged: notifier.setHome,
      ),
    ),
    FormFieldWrapper(
      label: "Sezona",
      child: CustomDropdownSheet(
        state: state,
        notifier: notifier,
        hint: "Vyber sezonu",
      ),
    ),
    FormFieldWrapper(
      label: "Hráči",
      child: AppMultiSelectField<PlayerApiModel>(
        label: "Hráči",
        title: "Vyber hráče",
        models: state.allPlayers,
        selectedModels: state.selectedPlayers,
        onChanged: (players) => notifier.setSelectedPlayers(players, false),
        isInitiallyHidden: (player) => !player.active,
        hiddenItemsButtonText: "Zobrazit neaktivní hráče",

      ),
    ),
    FormFieldWrapper(
      label: "Fanoušci",
      child: AppMultiSelectField<PlayerApiModel>(
        label: "Fanoušci",
        title: "Vyber fanoušky",
        models: state.allFans,
        selectedModels: state.selectedFans,
        onChanged: (fans) => notifier.setSelectedPlayers(fans, true),
        isInitiallyHidden: (player) => !player.active,
        hiddenItemsButtonText: "Zobrazit neaktivní fanoušky",
      ),
    ),
  ];
}