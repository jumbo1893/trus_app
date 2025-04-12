import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/table/controller/football_table_team_controller.dart';

import '../../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../../common/widgets/screen/custom_consumer_widget.dart';


class TableTeamDetailMatchesScreen extends CustomConsumerWidget {
  static const String id = "table-team-match-detail-screen";

  const TableTeamDetailMatchesScreen({
    Key? key,
  }) : super(key: key, title: "Zápasy", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      return Scaffold(
          body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ModelsErrorFutureBuilder(
          key: const ValueKey('football_fixtures'),
          future: ref.watch(footballTableTeamControllerProvider).getMatchList(),
          onPressed: (footballMatch) => {

          },
          context: context,
        ),
      ));
  }
}
