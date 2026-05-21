import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/rows/app_read_only_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../main/controller/screen_variables_notifier.dart';
import '../controller/edit/match_edit_notifier.dart';

class MatchStatsScreen extends ConsumerStatefulWidget {
  const MatchStatsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MatchStatsScreen> createState() =>
      _MatchStatsScreenState();
}

class _MatchStatsScreenState
    extends ConsumerState<MatchStatsScreen> {
  @override
  Widget build(BuildContext context) {
    final arg = ref.watch(matchNotifierArgsProvider);
    final state = ref.watch(matchEditNotifierProvider(arg));
    final matchStatsState = state.matchStatsState;
    return BaseFormScreen(
      headerTitle: "Statistiky piv/pokut/gólů",
      headerText: matchStatsState.overall,
      fields: [
        if (matchStatsState.beers.trim().isNotEmpty)
          FormFieldWrapper(
          label: "Piva/panáky:",
          child: AppReadOnlyField(
            value: matchStatsState.beers,
            allowWrap: true,
          ),
        ),
        if (matchStatsState.fines.trim().isNotEmpty)
          FormFieldWrapper(
          label: "Pokuty",
          child: AppReadOnlyField(
            value: matchStatsState.fines,
            allowWrap: true,
          ),
        ),
        if (matchStatsState.goals.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Góly",
            child: AppReadOnlyField(
              value: matchStatsState.goals,
              allowWrap: true,
            ),
          ),
        if (matchStatsState.assists.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Asistence",
            child: AppReadOnlyField(
              value: matchStatsState.assists,
              allowWrap: true,
            ),
          ),
      ],
      actions: const [],
      padding: const EdgeInsets.only(bottom: 24),
    );
  }
}
