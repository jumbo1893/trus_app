import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/main/screen_controller.dart';

import '../../../../common/widgets/rows/row_text_view_field.dart';
import '../controller/football_table_team_detail_notifier.dart';

class TableTeamDetailScreen extends CustomConsumerStatefulWidget {
  static const String id = "table-team-detail-screen";

  const TableTeamDetailScreen({Key? key})
      : super(key: key, title: "Detail týmu", name: id);

  @override
  ConsumerState<TableTeamDetailScreen> createState() => _TableTeamDetailScreenState();
}

class _TableTeamDetailScreenState extends ConsumerState<TableTeamDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final teamId = ref
        .watch(screenControllerProvider)
        .tableTeamApiModel
        .id!;
    final state = ref.watch(footballTableTeamDetailNotifierProvider(teamId));

    return SingleChildScrollView(
      child: Column(
        children: [
          RowTextViewField(
            textFieldText: "Tým:",
            value: state.teamName,),
          const SizedBox(height: 10),
          RowTextViewField(
            textFieldText: "Pořadí:",
            value: state.leagueRanking,
            showIfEmptyText: false,
          ),
          const SizedBox(height: 10),
          RowTextViewField(
            textFieldText: "Průměrný rok narození týmu:",
            value: state.averageBirthYear),
          const SizedBox(height: 10),
          RowTextViewField(
              textFieldText: "Nejlepší střelec:",
              value: state.bestScorer),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
