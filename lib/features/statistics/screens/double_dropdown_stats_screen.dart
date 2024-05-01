import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/custom_text.dart';

import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/builder/statistics_error_future_builder.dart';
import '../../../common/widgets/button/statistics_buttons.dart';
import '../../../common/widgets/dropdown/custom_dropdown.dart';
import '../../../models/api/season_api_model.dart';
import '../controller/stats_controller.dart';
import '../stats_screen_enum.dart';

class DoubleDropdownStatsScreen extends ConsumerStatefulWidget {
  final bool isFocused;
  final StatsController controller;
  final String detailedText;
  final bool matchStatsOrPlayerStats;
  final bool doubleDetail;

  const DoubleDropdownStatsScreen({
    required this.isFocused,
    required this.controller,
    required this.detailedText,
    required this.matchStatsOrPlayerStats,
    required this.doubleDetail,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DoubleDropdownStatsScreen> createState() => _DoubleDropdownStatsScreenState();
}

class _DoubleDropdownStatsScreenState extends ConsumerState<DoubleDropdownStatsScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
      return StreamBuilder<StatsScreenEnum>(
          stream: widget.controller.screenDetailStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data == StatsScreenEnum.firstScreen) {
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              width: size.width / 2.5 - padding,
                              child: CustomDropdown(
                                onItemSelected: (season) =>
                                    widget.controller.setPickedSeason(season as SeasonApiModel),
                                dropdownList: widget.controller.getSeasons(),
                                pickedItem: widget.controller.pickedSeason(),
                                initData: () =>
                                    widget.controller.setCurrentSeason(),
                                hint: 'Vyber sezonu',
                              )),
                          StatisticsButtons(
                            onSearchButtonClicked: (text) =>
                                widget.controller.getFilteredModels(text),
                            onOrderButtonClicked: () =>
                                widget.controller.onRevertTap(),
                            padding: padding,
                            size: size,
                          )
                        ],
                      ),
                      Expanded(
                        child: StatisticsErrorFutureBuilder(
                          future: widget.controller
                              .getModels(widget.matchStatsOrPlayerStats),
                          onPressed: (model) {
                            widget.controller.setDetail(model);
                          },
                          context: context,
                          rebuildStream: widget.controller.listStream(),
                          overallStream: widget.controller.overAllStatsStream(),
                          overAllStatsInit: () =>
                              widget.controller.initOverallStats(),
                        ),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return Scaffold();
            }
          });
    } else {
      return Container();
    }
  }
}
