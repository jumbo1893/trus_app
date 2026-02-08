import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/table/controller/football_table_notifier.dart';

import '../../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';


class FootballTableScreen extends CustomConsumerStatefulWidget {
  static const String id = "pkfl-table-screen";

  const FootballTableScreen({
    Key? key,
  }) : super(key: key, title: "Tabulka", name: id);

  @override
  ConsumerState<FootballTableScreen> createState() => _FootballTableScreenState();
}

class _FootballTableScreenState extends ConsumerState<FootballTableScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ModelToStringListview(
            state: ref.watch(footballTableNotifier),
            notifier: ref.read(footballTableNotifier.notifier)),
      ),
    );
  }
}
