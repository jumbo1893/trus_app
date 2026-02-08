import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/controller/football_player_dropdown_notifier.dart';
import 'package:trus_app/features/football/controller/football_player_stats_notifier.dart';

import '../../../../common/widgets/notifier/dropdown/custom_dropdown.dart';
import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';

class FootballPlayerStatsScreen extends CustomConsumerWidget {
  static const String id = "football-player-stats-screen";

  const FootballPlayerStatsScreen({
    Key? key,
  }) : super(key: key, title: "Hráčské statistiky", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery
        .of(context)
        .size;
    const double padding = 8.0;
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: size.width / 2 - padding,
                child: CustomDropdown(
                  hint: "Vyber hráče",
                  notifier: ref.read(
                      footballPlayerDropdownNotifierProvider.notifier),
                  state: ref.watch(footballPlayerDropdownNotifierProvider),
                ),
              ),
            ],
          ),
          Expanded(
            child: ModelToStringListview(
              state: ref.watch(footballPlayerStatsNotifierProvider),
              notifier: null,),
          )
        ],
      ),
    );
  }
}
