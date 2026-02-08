import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/button/change_achievement_button.dart';
import 'package:trus_app/features/achievement/controller/achievement_notifier.dart';
import 'package:trus_app/features/player/screens/view_player_screen.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';

import '../../../common/widgets/notifier/loader/loading_overlay.dart';
import '../../../common/widgets/rows/row_text_view_field.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../../main/screen_controller.dart';
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
    PlayerAchievementApiModel playerAchievementApiModel =
        ref.read(screenControllerProvider).playerAchievementApiModel;
    final state = ref.watch(achievementViewProvider(
        AchievementViewArgs.player(playerAchievementApiModel)));
    final notifier = ref.read(achievementViewProvider(
            AchievementViewArgs.player(playerAchievementApiModel))
        .notifier);
    return Scaffold(
      body: LoadingOverlay(
          state: state,
          onClearError: notifier.clearErrorMessage,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                RowTextViewField(
                  textFieldText: "Hráč:",
                  value: state.playerName ?? "",
                  showIfEmptyText: false,
                ),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Název:",
                  value: state.name,
                ),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Popis:",
                  value: state.description,
                  allowWrap: true,
                ),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Podmínky:",
                  value: state.secondaryCondition,
                  showIfEmptyText: false,
                  allowWrap: true,
                ),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Splněno:",
                  value: state.playerAchievementAccomplished ?? "",
                  showIfEmptyText: false,
                ),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Splněno v zápase:",
                  value: state.playerAchievementMatch ?? "",
                  showIfEmptyText: false,
                  allowWrap: true,
                ),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Detail:",
                  value: state.playerAchievementDetail ?? "",
                  showIfEmptyText: false,
                ),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Úspěšnost:",
                  value: state.successRate,
                ),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Splnili:",
                  value: state.accomplishedPlayers,
                  error: state.errors["accomplishedPlayers"],
                  showIfEmptyText: false,
                ),
              ],
            ),
          )),
      floatingActionButton: ChangeAchievementButton(
        onPressed: () async => await notifier.submit(
            "Měním achievement...",
            "Achievement úspěšně změněn",
            ViewPlayerScreen.id,
            Crud.update,
            achievementNotifierProvider),
        confirmationText: state.accomplished?? false
            ? "Chcete změnit achievement na nesplněno?"
            : "Chcete změnit achievement na splněno?",
        manually: state.manually?? false,
        accomplished: state.accomplished?? false,
      ),
    );
  }
}
