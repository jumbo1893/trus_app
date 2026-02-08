import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/notifier/loader/loading_overlay.dart';
import '../../../common/widgets/rows/row_text_view_field.dart';
import '../../main/screen_controller.dart';
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
    final notifier = ref.read(matchEditNotifierProvider(arg).notifier);
    final state = ref.watch(matchEditNotifierProvider(arg));
    final footballState = state.footballMatchDetailState;
    return LoadingOverlay(
        state: state,
        onClearError: notifier.clearErrorMessage,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                RowTextViewField(
                  textFieldText: "Hvězda zápasu:",
                  value: footballState.homeBestPlayer,
                allowWrap: true,),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Střelci:",
                  value: footballState.homeGoalScorers,
                  allowWrap: true,
                showIfEmptyText: false,),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Vlastňáky:",
                  value: footballState.homeOwnGoals,
                  allowWrap: true,
                  showIfEmptyText: false,),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Žluté:",
                  value: footballState.homeYellowCards,
                  allowWrap: true,
                  showIfEmptyText: false,),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Červené:",
                  value: footballState.homeRedCards,
                  allowWrap: true,
                  showIfEmptyText: false,),
              ],
            ),
          ),
        ));
  }
}
