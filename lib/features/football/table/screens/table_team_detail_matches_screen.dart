// lib/features/football/table/screens/table_team_detail_matches_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/model_to_string_listview.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_widget.dart';
import 'package:trus_app/features/main/screen_controller.dart';

import '../controller/football_table_team_detail_notifier.dart';

class TableTeamDetailMatchesScreen extends CustomConsumerWidget {
  static const String id = "table-team-match-detail-screen";

  //final FootballTeamDetailTab mode;

  const TableTeamDetailMatchesScreen({
    Key? key,
    //required this.mode,
  }) : super(key: key, title: "Zápasy", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(screenControllerProvider).tableTeamApiModel.id!;
    final state = ref.watch(footballTableTeamDetailNotifierProvider(teamId));
    final notifier = ref.read(footballTableTeamDetailNotifierProvider(teamId).notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ModelToStringListview(
        state: state,
        notifier: null,
      ),
    );
  }
}
