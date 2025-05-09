import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';

import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/dropdown/custom_dropdown.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../../models/api/season_api_model.dart';
import '../../football/screens/match_detail_screen.dart';
import '../../main/screen_controller.dart';
import '../controller/match_screen_controller.dart';

class MatchScreen extends CustomConsumerWidget {
  static const String id = "match-screen";

  const MatchScreen({
    Key? key,
  }) : super(key: key, title: "Zápasy", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(screenControllerProvider).isScreenFocused(MatchScreen.id)) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(padding),
            child: SingleChildScrollView(
              key: const ValueKey('match_screen'),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                          width: size.width / 2 - padding,
                          child: CustomDropdown(
                            key: const ValueKey('season_dropdown'),
                            onItemSelected: (season) => ref
                                .watch(matchScreenControllerProvider)
                                .setPickedSeason(season as SeasonApiModel),
                            dropdownList: ref
                                .watch(matchScreenControllerProvider)
                                .getSeasons(),
                            pickedItem: ref
                                .watch(matchScreenControllerProvider)
                                .pickedSeason(),
                            initData: () => ref
                                .watch(matchScreenControllerProvider)
                                .setCurrentSeason(),
                            hint: 'Vyber sezonu',
                          )),
                    ],
                  ),
                  ModelsErrorFutureBuilder(
                    key: const ValueKey('match_list'),
                    future:
                        ref.watch(matchScreenControllerProvider).getModels(),
                    rebuildStream: ref
                        .watch(matchScreenControllerProvider)
                        .streamMatches(),
                    onPressed: (match) => {
                      ref
                          .read(screenControllerProvider)
                          .setMatchId(match.getId()),
                      ref
                          .read(screenControllerProvider)
                          .changeFragment(MatchDetailScreen.id)
                    },
                    context: context,
                    scrollable: false,
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            key: const ValueKey('add_match_floating_button'),
            onPressed: () => ref
                .read(screenControllerProvider)
                .changeFragment(AddMatchScreen.id),
            elevation: 4.0,
            child: const Icon(Icons.add),
          ));
    } else {
      return Container();
    }
  }
}
