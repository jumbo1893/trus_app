import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/table/controller/football_table_notifier.dart';
import 'package:trus_app/features/football/table/widget/football_table_team_list_tile.dart';
import 'package:trus_app/models/api/football/table_team_api_model.dart';

import '../../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';

class FootballTableScreen extends CustomConsumerStatefulWidget {
  static const String id = "pkfl-table-screen";

  const FootballTableScreen({
    super.key,
  }) : super(title: "Tabulka", name: id);

  @override
  ConsumerState<FootballTableScreen> createState() =>
      _FootballTableScreenState();
}

class _FootballTableScreenState extends ConsumerState<FootballTableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ModelToStringListview(
          state: ref.watch(footballTableNotifier),
          notifier: ref.read(footballTableNotifier.notifier),
          itemBuilder: (context, item, onTap, _, itemCount) {
            return FootballTableTeamListTile(
              team: item as TableTeamApiModel,
              teamsCount: itemCount,
              onTap: onTap,
            );
          },
        ),
      ),
    );
  }
}