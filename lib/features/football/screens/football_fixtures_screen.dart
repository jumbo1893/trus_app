import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/controller/football_fixtures_notifier.dart';

import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';

class FootballFixturesScreen extends CustomConsumerWidget {
  static const String id = "football-fixtures-screen";

  const FootballFixturesScreen({
    Key? key,
  }) : super(key: key, title: "Program zápasů", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ModelToStringListview(
              state: ref.watch(footballFixturesNotifier),
              notifier: ref.read(footballFixturesNotifier.notifier)),
        ),
      );
  }
}
