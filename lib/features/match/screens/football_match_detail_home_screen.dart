import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/rows/app_read_only_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../main/controller/screen_variables_notifier.dart';
import '../controller/edit/match_edit_notifier.dart';

class FootballMatchDetailHomeScreen extends ConsumerStatefulWidget {
  const FootballMatchDetailHomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<FootballMatchDetailHomeScreen> createState() =>
      _FootballMatchDetailHomeScreenState();
}

class _FootballMatchDetailHomeScreenState
    extends ConsumerState<FootballMatchDetailHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final arg = ref.watch(matchNotifierArgsProvider);
    final state = ref.watch(matchEditNotifierProvider(arg));
    final footballState = state.footballMatchDetailState;
    return BaseFormScreen(
      headerTitle: "Statistiky hráčů",
      headerText: "Domácích",
      fields: [
        FormFieldWrapper(
          label: "Hvězda zápasu",
          child: AppReadOnlyField(
            value: footballState.homeBestPlayer,
            allowWrap: true,
          ),
        ),
        FormFieldWrapper(
          label: "Střelci",
          child: AppReadOnlyField(
            value: footballState.homeGoalScorers,
            allowWrap: true,
          ),
        ),
        if (footballState.homeOwnGoals.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Vlastňáky",
            child: AppReadOnlyField(
              value: footballState.homeOwnGoals,
              allowWrap: true,
            ),
          ),
        if (footballState.homeYellowCards.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Žluté",
            child: AppReadOnlyField(
              value: footballState.homeYellowCards,
              allowWrap: true,
            ),
          ),
        if (footballState.homeRedCards.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Červené",
            child: AppReadOnlyField(
              value: footballState.homeRedCards,
              allowWrap: true,
            ),
          ),
      ],
      actions: const [],
      padding: const EdgeInsets.only(bottom: 24),
    );
  }
}
