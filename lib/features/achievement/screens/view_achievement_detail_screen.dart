import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/controller/achievement_notifier.dart';

import '../../../common/widgets/notifier/loader/loading_overlay.dart';
import '../../../common/widgets/rows/row_text_view_field.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../achievement_view_args.dart';
import '../controller/achievement_edit_notifier.dart';

class ViewAchievementDetailScreen extends CustomConsumerStatefulWidget {
  static const String id = "view-achievement-detail-screen";

  const ViewAchievementDetailScreen({
    Key? key,
  }) : super(key: key, title: "Detail achievementu", name: id);

  @override
  ConsumerState<ViewAchievementDetailScreen> createState() => _ViewAchievementDetailScreenState();
}

class _ViewAchievementDetailScreenState extends ConsumerState<ViewAchievementDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final achievement = ref
        .watch(achievementNotifierProvider)
        .selectedAchievement!;
    AchievementViewArgs arg = AchievementViewArgs.detail(achievement);
    final state = ref.watch(achievementViewProvider(arg));
    final notifier = ref.read(achievementViewProvider(arg).notifier);
    return LoadingOverlay(
        state: state,
        onClearError: notifier.clearErrorMessage,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
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
        ));
  }
}
