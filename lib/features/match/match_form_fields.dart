import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

import '../../common/widgets/dropdown/app_multi_select.dart';
import '../../common/widgets/dropdown/custom_dropdown_sheet.dart';
import '../../common/widgets/rows/app_date_field.dart';
import '../../common/widgets/rows/app_switch_field.dart';
import '../../common/widgets/rows/app_text_input_field.dart';
import '../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../models/api/player/player_api_model.dart';

List<Widget> matchFields(
    BuildContext context,
    dynamic state,
    dynamic notifier,
    ) {
  final homeTeamName = state.home ? "Liščí Trus" : state.name;
  final awayTeamName = state.home ? state.name : "Liščí Trus";

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
      label: "Výsledek",
      error: state.errors["homeGoalNumber"] ??
          state.errors["awayGoalNumber"],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homeTeamName.isEmpty ? "Domácí" : homeTeamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                AppTextInputField(
                  value: state.homeGoalNumber?.toString() ?? "",
                  keyboardType: TextInputType.number,
                  hintText: "0",
                  onChanged: notifier.setHomeGoalNumber,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 24, 12, 0),
            child: Text(
              ":",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  awayTeamName.isEmpty ? "Hosté" : awayTeamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                AppTextInputField(
                  value: state.awayGoalNumber?.toString() ?? "",
                  keyboardType: TextInputType.number,
                  hintText: "0",
                  onChanged: notifier.setAwayGoalNumber,
                ),
              ],
            ),
          ),
        ],
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