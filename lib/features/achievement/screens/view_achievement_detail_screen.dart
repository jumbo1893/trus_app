import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/controller/achievement_notifier.dart';

import '../../../common/widgets/rows/app_read_only_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../achievement_view_args.dart';
import '../controller/achievement_edit_notifier.dart';

class ViewAchievementDetailScreen extends CustomConsumerStatefulWidget {
  static const String id = "view-achievement-detail-screen";

  const ViewAchievementDetailScreen({
    Key? key,
  }) : super(key: key, title: "Detail achievementu", name: id);

  @override
  ConsumerState<ViewAchievementDetailScreen> createState() =>
      _ViewAchievementDetailScreenState();
}

class _ViewAchievementDetailScreenState
    extends ConsumerState<ViewAchievementDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final achievement =
    ref.watch(achievementNotifierProvider).selectedAchievement!;

    final arg = AchievementViewArgs.detail(achievement);
    final state = ref.watch(achievementViewProvider(arg));

    return BaseFormScreen(
      headerTitle: state.name,
      headerText: "Úspěšnost: ${state.successRate}",
      fields: [
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
    );
  }
}