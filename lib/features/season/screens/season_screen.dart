import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/season/screens/add_season_screen.dart';

import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../main/screen_controller.dart';
import '../controller/season_notifier.dart';

class SeasonScreen extends CustomConsumerWidget {
  static const String id = "season-screen";

  const SeasonScreen({
    Key? key,
  }) : super(key: key, title: "Sezony", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ModelToStringListview(
              state: ref.watch(seasonNotifierProvider),
              notifier: ref.read(seasonNotifierProvider.notifier)),
          ),
          floatingActionButton: FloatingActionButton(
            key: const ValueKey('add_season_floating_button'),
            onPressed: () => ref
                .read(screenControllerProvider)
                .changeFragment(AddSeasonScreen.id),
            elevation: 4.0,
            child: const Icon(Icons.add),
          ));
  }
}
