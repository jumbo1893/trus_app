import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/dropdown/custom_dropdown_sheet.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/match/controller/match_notifier.dart';
import 'package:trus_app/features/match/match_notifier_args.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';

import '../../../common/widgets/filter_card.dart';
import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../season/controller/season_dropdown_notifier.dart';
import '../../season/season_args.dart';
import '../widget/match_list_tile.dart';

class MatchScreen extends CustomConsumerWidget {
  static const String id = "match-screen";

  const MatchScreen({
    Key? key,
  }) : super(key: key, title: "Zápasy", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const horizontalPadding = 16.0;
    const sectionSpacing = 16.0;

    final seasonProvider =
    seasonDropdownNotifierProvider(const SeasonArgs(false, true, true));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: FilterCard(
                child: CustomDropdownSheet(
                  hint: "Vyber sezonu",
                  notifier: ref.read(seasonProvider.notifier),
                  state: ref.watch(seasonProvider),
                ),
              ),
            ),
            const SizedBox(height: sectionSpacing),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ModelToStringListview(
                  storageKey: id,
                  state: ref.watch(matchNotifierProvider),
                  notifier: ref.read(matchNotifierProvider.notifier),
                  itemBuilder: (context, item, onTap, _, _) {
                    return MatchListTile(
                      match: item as MatchApiModel,
                      onTap: onTap,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref
              .read(screenVariablesNotifierProvider.notifier)
              .setMatchNotifierArgs(const MatchNotifierArgs.add());
          ref.read(screenNotifierProvider.notifier).changeFragment(AddMatchScreen.id);
        },
        elevation: 4.0,
        child: const Icon(Icons.add),
      ),
    );
  }
}