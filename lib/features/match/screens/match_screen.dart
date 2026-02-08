import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/match/controller/match_notifier.dart';
import 'package:trus_app/features/match/match_notifier_args.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';

import '../../../common/widgets/notifier/dropdown/custom_dropdown.dart';
import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../main/screen_controller.dart';
import '../../season/controller/season_dropdown_notifier.dart';
import '../../season/season_args.dart';

class MatchScreen extends CustomConsumerWidget {
  static const String id = "match-screen";

  const MatchScreen({
    Key? key,
  }) : super(key: key, title: "Zápasy", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    const double padding = 8.0;
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: size.width / 2 - padding,
                    child: CustomDropdown(
                      hint: "Vyber sezonu",
                      notifier: ref.read(seasonDropdownNotifierProvider(const SeasonArgs(false, true, true)).notifier),
                      state: ref.watch(seasonDropdownNotifierProvider(const SeasonArgs(false, true, true))),
                    ),),
                ],
              ),
              Expanded(
                child: ModelToStringListview(
                    state: ref.watch(matchNotifierProvider),
                    notifier: ref.read(matchNotifierProvider.notifier)),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              {ref
                  .read(screenControllerProvider)
                  .setMatchNotifierArgs(const MatchNotifierArgs.add()),
              ref
              .read(screenControllerProvider)
              .changeFragment(AddMatchScreen.id)},
          elevation: 4.0,
          child: const Icon(Icons.add),
        ));
  }
}
