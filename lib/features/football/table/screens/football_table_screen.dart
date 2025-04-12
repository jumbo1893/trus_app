import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/table/screens/main_table_team_screen.dart';

import '../../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../../models/api/football/table_team_api_model.dart';
import '../../../../models/enum/match_detail_options.dart';
import '../../../main/screen_controller.dart';
import '../../screens/match_detail_screen.dart';
import '../controller/football_table_team_controller.dart';

class FootballTableScreen extends CustomConsumerStatefulWidget {
  static const String id = "pkfl-table-screen";

  const FootballTableScreen({
    Key? key,
  }) : super(key: key, title: "Tabulka", name: id);

  @override
  ConsumerState<FootballTableScreen> createState() => _FootballTableScreenState();
}

class _FootballTableScreenState extends ConsumerState<FootballTableScreen> {


  void setScreenToCommonMatches(int footballTableTeam) {
    if(footballTableTeam != -1) {
      ref
          .read(screenControllerProvider)
          .setPreferredScreen(MatchDetailOptions.mutualMatches);
      ref.read(screenControllerProvider).setFootballTeamIdOnlyForCommonMatches(footballTableTeam);
      ref.read(screenControllerProvider).changeFragment(MatchDetailScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.read(screenControllerProvider).isScreenFocused(FootballTableScreen.id)) {
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ModelsErrorFutureBuilder(
              key: const ValueKey('football_table'),
              future: ref.watch(footballTableTeamControllerProvider).getModels(),
              onPressed: (footballTableTeam) => {
                ref
                    .read(screenControllerProvider)
                    .setTableTeamApiModel(footballTableTeam as TableTeamApiModel),
                ref
                    .read(screenControllerProvider)
                    .changeFragment(MainTableTeamScreen.id)
              },
              context: context,
            ),
          ));
    } else {
      return Container();
    }
  }
}
