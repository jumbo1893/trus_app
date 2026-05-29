import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/controller/football_fixtures_notifier.dart';
import 'package:trus_app/features/football/widget/football_fixture_list_tile.dart';
import 'package:trus_app/features/general/notifier/global_variables_notifier.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';

import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';

class FootballFixturesScreen extends CustomConsumerWidget {
  static const String id = "football-fixtures-screen";

  const FootballFixturesScreen({
    super.key,
  }) : super(title: "Program zápasů", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTeamId = ref.watch(
      globalVariablesProvider.select(
            (state) => state.appTeam?.team.id,
      ),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ModelToStringListview(
          state: ref.watch(footballFixturesNotifier),
          notifier: ref.read(footballFixturesNotifier.notifier),
          itemBuilder: (context, item, onTap, _, __) {
            return FootballFixtureListTile(
              match: item as FootballMatchApiModel,
              userTeamId: userTeamId,
              onTap: onTap,
            );
          },
        ),
      ),
    );
  }
}