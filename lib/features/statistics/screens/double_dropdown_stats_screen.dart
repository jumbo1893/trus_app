import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/builder/statistics_error_future_builder.dart';
import '../../../common/widgets/dropdown/custom_dropdown.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/api/season_api_model.dart';
import '../../../models/api/stats/stats.dart';
import '../../main/screen_controller.dart';
import '../controller/double_dropdown_stats_controller.dart';

class DoubleDropdownStatsScreen extends CustomConsumerStatefulWidget {
  static const String id = "double-dropdown-stats-screen";

  const DoubleDropdownStatsScreen({
    Key? key,
  }) : super(key: key, title: "Podrobné statistiky piv", name: id);

  @override
  ConsumerState<DoubleDropdownStatsScreen> createState() => _DoubleDropdownStatsScreenState();
}

class _DoubleDropdownStatsScreenState extends ConsumerState<DoubleDropdownStatsScreen> {
  @override
  Widget build(BuildContext context) {
    if (ref.read(screenControllerProvider).isScreenFocused(DoubleDropdownStatsScreen.id)) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              width: size.width / 2 - padding,
                              child: CustomDropdown(
                                onItemSelected: (season) =>
                                    ref.read(doubleDropdownStatsControllerProvider).setPickedSeason(season as SeasonApiModel),
                                dropdownList: ref.read(doubleDropdownStatsControllerProvider).getSeasons(),
                                pickedItem: ref.read(doubleDropdownStatsControllerProvider).pickedSeason(),
                                initData: () =>
                                    ref.read(doubleDropdownStatsControllerProvider).setCurrentSeason(),
                                hint: 'Vyber sezonu',
                              )),
                          SizedBox(
                              width: size.width / 2 - padding,
                              child:  CustomDropdown(
                                    onItemSelected: (stat) =>
                                        ref.read(doubleDropdownStatsControllerProvider).setPickedDropdown(stat as Stats),
                                    dropdownList: ref.read(doubleDropdownStatsControllerProvider).getDropDown(),
                                    pickedItem: ref.read(doubleDropdownStatsControllerProvider).pickedDropDown(),
                                    initData: () =>
                                        ref.read(doubleDropdownStatsControllerProvider).setCurrentDropdown(),
                                    hint: 'Vyber možnost',
                                  )

                              ),
                        ],
                      ),
                      Expanded(
                        child: StatisticsErrorFutureBuilder(
                          future: ref.read(doubleDropdownStatsControllerProvider)
                              .getModels(false),
                          onPressed: (model) {
                          },
                          context: context,
                          rebuildStream: ref.read(doubleDropdownStatsControllerProvider).listStream(),
                          overallStream: null,
                          overAllStatsInit: null,
                          includeOverAllStream: false,

                        ),
                      )
                    ],
                  ),
                ),
          );
    } else {
      return Container();
    }
  }
}
