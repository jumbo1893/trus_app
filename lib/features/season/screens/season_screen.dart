import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/season/screens/add_season_screen.dart';
import 'package:trus_app/features/season/screens/edit_season_screen.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../main/screen_controller.dart';
import '../controller/season_controller.dart';

class SeasonScreen extends CustomConsumerWidget {
  static const String id = "season-screen";

  const SeasonScreen({
    Key? key,
  }) : super(key: key, title: "Sezony", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(SeasonScreen.id)) {
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ModelsErrorFutureBuilder(
              key: const ValueKey('season_list'),
              future: ref.watch(seasonControllerProvider).getModels(),
              onPressed: (season) => {
                ref
                    .read(screenControllerProvider)
                    .setSeason(season as SeasonApiModel),
                ref
                    .read(screenControllerProvider)
                    .changeFragment(EditSeasonScreen.id)
              },
              context: context,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            key: const ValueKey('add_season_floating_button'),
            onPressed: () => ref
                .read(screenControllerProvider)
                .changeFragment(AddSeasonScreen.id),
            elevation: 4.0,
            child: const Icon(Icons.add),
          ));
    } else {
      return Container();
    }
  }
}
