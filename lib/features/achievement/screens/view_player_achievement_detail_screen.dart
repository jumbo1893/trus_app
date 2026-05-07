import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/button/change_achievement_button.dart';
import 'package:trus_app/common/widgets/rows/app_read_only_field.dart';
import 'package:trus_app/common/widgets/rows/form/form_field_wrapper.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';

import '../../../common/widgets/screen/base_form_screen.dart';
import '../../../models/enum/crud.dart';
import '../achievement_view_args.dart';
import '../controller/achievement_edit_notifier.dart';

class ViewPlayerAchievementDetailScreen extends CustomConsumerStatefulWidget {
  static const String id = "view-player-achievement-detail-screen";

  const ViewPlayerAchievementDetailScreen({
    Key? key,
  }) : super(key: key, title: "Zobrazení achievementu", name: id);

  @override
  ConsumerState<ViewPlayerAchievementDetailScreen> createState() =>
      _ViewPlayerAchievementDetailScreenState();
}

class _ViewPlayerAchievementDetailScreenState
    extends ConsumerState<ViewPlayerAchievementDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final PlayerAchievementApiModel playerAchievementApiModel =
        ref.read(screenVariablesNotifierProvider).playerAchievement;

    final args = AchievementViewArgs.player(playerAchievementApiModel);
    final state = ref.watch(achievementViewProvider(args));
    final notifier = ref.read(achievementViewProvider(args).notifier);

    return BaseFormScreen(
      headerTitle: state.name,
      headerText: state.accomplished == true
          ? "Achievement je splněný"
          : "Achievement zatím není splněný",
      fields: [
        if ((state.playerName ?? "").trim().isNotEmpty)
          FormFieldWrapper(
            label: "Hráč",
            child: AppReadOnlyField(
              value: state.playerName ?? "",
              allowWrap: true,
            ),
          ),
        FormFieldWrapper(
          label: "Název",
          child: AppReadOnlyField(
            value: state.name,
            allowWrap: true,
          ),
        ),
        FormFieldWrapper(
          label: "Popis",
          child: AppReadOnlyField(
            value: state.description,
            allowWrap: true,
          ),
        ),
        if (state.secondaryCondition.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Podmínky",
            child: AppReadOnlyField(
              value: state.secondaryCondition,
              allowWrap: true,
            ),
          ),
        if ((state.playerAchievementAccomplished ?? "").trim().isNotEmpty)
          FormFieldWrapper(
            label: "Splněno",
            child: AppReadOnlyField(
              value: state.playerAchievementAccomplished ?? "",
              allowWrap: true,
            ),
          ),
        if ((state.playerAchievementMatch ?? "").trim().isNotEmpty)
          FormFieldWrapper(
            label: "Splněno v zápase",
            child: AppReadOnlyField(
              value: state.playerAchievementMatch ?? "",
              allowWrap: true,
            ),
          ),
        if ((state.playerAchievementDetail ?? "").trim().isNotEmpty)
          FormFieldWrapper(
            label: "Detail",
            child: AppReadOnlyField(
              value: state.playerAchievementDetail ?? "",
              allowWrap: true,
            ),
          ),
        FormFieldWrapper(
          label: "Úspěšnost",
          child: AppReadOnlyField(
            value: state.successRate,
            allowWrap: true,
          ),
        ),
        if (state.accomplishedPlayers.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Splnili",
            error: state.errors["accomplishedPlayers"],
            child: AppReadOnlyField(
              value: state.accomplishedPlayers,
              allowWrap: true,
            ),
          ),
      ],
      actions: const [],
      floatingActionButton: ChangeAchievementButton(
        onPressed: () async => notifier.submitCrud(Crud.update),
        confirmationText: state.accomplished ?? false
            ? "Chcete změnit achievement na nesplněno?"
            : "Chcete změnit achievement na splněno?",
        manually: state.manually ?? false,
        accomplished: state.accomplished ?? false,
      ),
    );
  }
}