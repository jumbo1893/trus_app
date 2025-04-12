import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../../models/api/football/football_match_api_model.dart';
import '../../../models/enum/match_detail_options.dart';
import '../../main/screen_controller.dart';
import '../controller/football_controller.dart';
import 'match_detail_screen.dart';

class FootballFixturesScreen extends CustomConsumerWidget {
  static const String id = "football-fixtures-screen";

  const FootballFixturesScreen({
    Key? key,
  }) : super(key: key, title: "Program zápasů", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(screenControllerProvider).isScreenFocused(id)) {
      return Scaffold(
          body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ModelsErrorFutureBuilder(
          key: const ValueKey('football_fixtures'),
          future: ref.watch(footballControllerProvider).getModels(),
          onPressed: (footballMatch) => {
            ref
                .read(screenControllerProvider)
                .setPreferredScreen(MatchDetailOptions.footballMatchDetail),
            ref
                .read(screenControllerProvider)
                .setFootballMatch(footballMatch as FootballMatchApiModel),
            ref
                .read(screenControllerProvider)
                .changeFragment(MatchDetailScreen.id)
          },
          context: context,
        ),
      ));
    } else {
      return Container();
    }
  }
}
