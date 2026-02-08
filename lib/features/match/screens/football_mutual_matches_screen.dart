import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../colors.dart';
import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/notifier/loader/loading_overlay.dart';
import '../../main/screen_controller.dart';
import '../controller/edit/match_edit_notifier.dart';

class FootballMutualMatchesScreen extends ConsumerStatefulWidget {

  const FootballMutualMatchesScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<FootballMutualMatchesScreen> createState() =>
      _FootballMutualMatchesScreenState();
}

class _FootballMutualMatchesScreenState
    extends ConsumerState<FootballMutualMatchesScreen> {
  @override
  Widget build(BuildContext context) {
    final arg = ref.watch(matchNotifierArgsProvider);
    final notifier = ref.read(matchEditNotifierProvider(arg).notifier);
    final state = ref.watch(matchEditNotifierProvider(arg));
    final footballState = state.footballMatchDetailState;
    return LoadingOverlay(
        state: state,
        onClearError: notifier.clearErrorMessage,
        child: Column(
          children: [
        Padding(
        padding: const EdgeInsets.only(
          bottom: 8,
          left: 8,
          right: 8,
        ),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey),
            ),
          ),
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(footballState.aggregateMatches == null
                  ? "Žádné vzájemné zápasy"
                  :
                "Bilance zápasů V/R/P: ${footballState.aggregateMatches}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            subtitle: Text(
              footballState.aggregateScore == null
                  ? ""
                  : "Celkové skóre: ${footballState.aggregateScore}",
              style: const TextStyle(
                color: listviewSubtitleColor,
              ),
            ),
          ),
        ),
                ),
            Expanded(
              child: ModelToStringListview(
                  state: footballState,
                  notifier: notifier),
            ),
          ],
        ));
  }
}
