import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/header/header_card.dart';
import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../theme/app_widget_values.dart';
import '../../main/controller/screen_variables_notifier.dart';
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

    final aggregateMatches =
        footballState.aggregateMatches ?? "Žádné vzájemné zápasy";
    final aggregateScore = footballState.aggregateScore ?? "—";

    return Column(
      children: [
        AppWidgetValues.field,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HeaderCard(
            title: 'Vzájemné zápasy',
            text: 'Bilance V/R/P $aggregateMatches, celkové skóre $aggregateScore',
          ),
        ),
        AppWidgetValues.field,
        Expanded(
          child: ModelToStringListview(
            state: footballState,
            notifier: notifier,
          ),
        ),
      ],
    );
  }
}