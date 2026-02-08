import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../colors.dart';
import '../../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../main/screen_controller.dart';
import '../controller/football_table_team_detail_notifier.dart';

class TableTeamMutualMatchesScreen extends ConsumerStatefulWidget {

  const TableTeamMutualMatchesScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<TableTeamMutualMatchesScreen> createState() =>
      _TableTeamMutualMatchesScreenState();
}

class _TableTeamMutualMatchesScreenState
    extends ConsumerState<TableTeamMutualMatchesScreen> {
  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(screenControllerProvider).tableTeamApiModel.id!;
    final state = ref.watch(footballTableTeamDetailNotifierProvider(teamId));
    final notifier = ref.read(footballTableTeamDetailNotifierProvider(teamId).notifier);
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
            child: Text(state.aggregateMatches  == ""
                ? "Žádné vzájemné zápasy"
                :
              "Bilance zápasů V/R/P: ${state.aggregateMatches}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          subtitle: Text(
            state.aggregateScore == ""
                ? ""
                : "Celkové skóre: ${state.aggregateScore}",
            style: const TextStyle(
              color: listviewSubtitleColor,
            ),
          ),
        ),
      ),
    ),
          Expanded(
            child: ModelToStringListview(
                state: state,
                notifier: notifier),
          ),
        ],
      ),
    );
  }
}
