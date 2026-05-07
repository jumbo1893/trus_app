import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/rows/app_read_only_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../main/controller/screen_variables_notifier.dart';
import '../controller/edit/match_edit_notifier.dart';

class FootballMatchDetailAwayScreen extends ConsumerStatefulWidget {
  const FootballMatchDetailAwayScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<FootballMatchDetailAwayScreen> createState() =>
      _FootballMatchDetailAwayScreenState();
}

class _FootballMatchDetailAwayScreenState
    extends ConsumerState<FootballMatchDetailAwayScreen> {
  @override
  Widget build(BuildContext context) {
    final arg = ref.watch(matchNotifierArgsProvider);
    final state = ref.watch(matchEditNotifierProvider(arg));
    final footballState = state.footballMatchDetailState;
    return BaseFormScreen(
      headerTitle: "Statistiky hráčů",
      headerText: "Hostů",
      fields: [
        FormFieldWrapper(
          label: "Hvězda zápasu",
          child: AppReadOnlyField(
            value: footballState.awayBestPlayer,
            allowWrap: true,
          ),
        ),
        FormFieldWrapper(
          label: "Střelci",
          child: AppReadOnlyField(
            value: footballState.awayGoalScorers,
            allowWrap: true,
          ),
        ),
        if (footballState.awayOwnGoals.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Vlastňáky",
            child: AppReadOnlyField(
              value: footballState.awayOwnGoals,
              allowWrap: true,
            ),
          ),
        if (footballState.awayYellowCards.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Žluté",
            child: AppReadOnlyField(
              value: footballState.awayYellowCards,
              allowWrap: true,
            ),
          ),
        if (footballState.awayRedCards.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Červené",
            child: AppReadOnlyField(
              value: footballState.awayRedCards,
              allowWrap: true,
            ),
          ),
      ],
      actions: const [],
      padding: const EdgeInsets.only(bottom: 24),
    );
  }
}
