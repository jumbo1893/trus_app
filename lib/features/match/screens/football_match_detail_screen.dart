import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/rows/row_text_view_field_without_label.dart';

import '../../../common/widgets/notifier/loader/loading_overlay.dart';
import '../../../common/widgets/rows/row_text_view_field.dart';
import '../../main/screen_controller.dart';
import '../controller/edit/match_edit_notifier.dart';
import '../match_notifier_args.dart';

class FootballMatchDetailScreen extends ConsumerStatefulWidget {
  const FootballMatchDetailScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<FootballMatchDetailScreen> createState() =>
      _FootballMatchDetailScreenState();
}

class _FootballMatchDetailScreenState
    extends ConsumerState<FootballMatchDetailScreen> {
  @override
  Widget build(BuildContext context) {
    MatchNotifierArgs arg = ref.read(screenControllerProvider).matchNotifierArgs;
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
                  textFieldText: "Zápas:",
                  value: footballState.nameAndResult,
                  allowWrap: true,),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Kolo:",
                  value: footballState.dateAndLeague,
                  allowWrap: true,),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Stadion:",
                  value: footballState.stadium,
                  allowWrap: true,),
                const SizedBox(height: 10),
                RowTextViewField(
                  textFieldText: "Rozhodčí:",
                  value: footballState.referee,
                  allowWrap: true,),
                const SizedBox(height: 10),
                RowTextViewFieldWithoutLabel(
                  value: footballState.refereeComment,
                  allowWrap: true,
                  showIfEmptyText: false,),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ));
  }
}
