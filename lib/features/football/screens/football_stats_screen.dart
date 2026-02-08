import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/model_to_string_listview.dart';
import 'package:trus_app/features/football/controller/current_season_notifier.dart';
import 'package:trus_app/features/football/controller/footbal_stats_notifier.dart';

import '../../../../common/widgets/notifier/dropdown/custom_dropdown.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';

class FootballStatsScreen extends CustomConsumerStatefulWidget {
  static const String id = "football-stats-screen";

  const FootballStatsScreen({
    Key? key,
  }) : super(key: key, title: "Statistika z PKFL", name: id);

  @override
  ConsumerState<FootballStatsScreen> createState() =>
      _FootballStatsScreenState();
}

class _FootballStatsScreenState
    extends ConsumerState<FootballStatsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double padding = 8.0;
    return Scaffold(
      body: Column(
        children: [
            Row(
              children: [
                SizedBox(
                  width: size.width / 2 - padding,
                  child: CustomDropdown(
                    hint: "Vyber sezonu",
                    notifier: ref.read(currentSeasonNotifierProvider.notifier),
                    state: ref.watch(currentSeasonNotifierProvider),
                  ),
                ),
                SizedBox(
                  width: size.width / 2 - padding,
                  child: CustomDropdown(
                    hint: "Vyber možnost",
                    notifier: ref.read(footballStatsNotifierProvider.notifier),
                    state: ref.watch(footballStatsNotifierProvider),
                  ),
                ),
              ],
            ),
          Expanded(
            child: ModelToStringListview(
                state: ref.watch(footballStatsNotifierProvider),
                notifier: null,),
          )
        ],
      ),
    );
  }
}


