import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/model_to_string_listview.dart';
import 'package:trus_app/features/season/controller/season_dropdown_notifier.dart';
import 'package:trus_app/features/statistics/controller/beer_detail_stats_notifier.dart';

import '../../../../common/widgets/notifier/dropdown/custom_dropdown.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../season/season_args.dart';

class BeerDetailStatsScreen extends CustomConsumerStatefulWidget {
  static const String id = "beer-detail-stats-screen";

  const BeerDetailStatsScreen({
    Key? key,
  }) : super(key: key, title: "Podrobné statistiky piv", name: id);

  @override
  ConsumerState<BeerDetailStatsScreen> createState() =>
      _BeerDetailStatsScreenState();
}

class _BeerDetailStatsScreenState
    extends ConsumerState<BeerDetailStatsScreen> {
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
                    notifier: ref.read(seasonDropdownNotifierProvider(const SeasonArgs(false, false, true)).notifier),
                    state: ref.watch(seasonDropdownNotifierProvider(const SeasonArgs(false, false, true))),
                  ),
                ),
                SizedBox(
                  width: size.width / 2 - padding,
                  child: CustomDropdown(
                    hint: "Vyber možnost",
                    notifier: ref.read(beerDetailStatsNotifierProvider.notifier),
                    state: ref.watch(beerDetailStatsNotifierProvider),
                  ),
                ),
              ],
            ),
          Expanded(
            child: ModelToStringListview(
                state: ref.watch(beerDetailStatsNotifierProvider),
                notifier: null,),
          )
        ],
      ),
    );
  }
}


