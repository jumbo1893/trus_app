import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/controller/fine_match_notifier.dart';

import '../../../../common/widgets/button/floating_finematch_button.dart';
import '../../../../common/widgets/dropdown/match_dropdown_notifier.dart';
import '../../../../common/widgets/listview/fine_match_listview.dart';
import '../../../../common/widgets/notifier/dropdown/custom_dropdown.dart';
import '../../../../common/widgets/notifier/loader/loading_overlay.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../main/screen_controller.dart';
import '../../../season/controller/season_dropdown_notifier.dart';
import '../../../season/season_args.dart';

class FineMatchScreen extends CustomConsumerStatefulWidget {
  static const String id = "fine-match-screen";
  const FineMatchScreen({
    Key? key,
  }) : super(key: key, title: "Přidání pokut", name: id);

  @override
  ConsumerState<FineMatchScreen> createState() => _FineMatchScreenState();
}

class _FineMatchScreenState extends ConsumerState<FineMatchScreen> {
  bool _initDone = false;

  @override
  Widget build(BuildContext context) {
    final sc = ref.read(screenControllerProvider);
    final state = ref.watch(fineMatchNotifierProvider);
    final notifier = ref.read(fineMatchNotifierProvider.notifier);

    if (!_initDone) {
      _initDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.init(matchId: sc.matchId);
      });
    }
    return LoadingOverlay(
      state: state,
      onClearError: notifier.clearErrorMessage,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: state.matches.when(
            loading: () => const SizedBox(height: 24),
            error: (_, __) => const SizedBox.shrink(),
            data: (matches) => ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              child: MatchDropdownNotifier(
                matches: matches,
                selected: state.selectedMatch,
                onSelected: notifier.selectMatch,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: CustomDropdown(
                    hint: "Vyber sezonu",
                    notifier: ref.read(
                      seasonDropdownNotifierProvider(const SeasonArgs(false, true, true)).notifier,
                    ),
                    state: ref.watch(
                      seasonDropdownNotifierProvider(const SeasonArgs(false, true, true)),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: FineMatchListview(
               checkedPlayers: state.checkedPlayers,
                multiselect: state.multiCheck,
                onPlayerChecked: (player) => notifier.toggleCheckedPlayer(player),
                onPlayerSelected: (player) => notifier.setSelectedPlayer(player),
                players: state.allPlayers,
              ),
            )
          ],
        ),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.endDocked,
          floatingActionButton: FloatingFineMatchButton(
            onMultiselectClicked: (multi) =>
               notifier.switchScreen(multi),
            onIconClicked: (index) => notifier.onIconClick(index),
          )
      ),
    );
  }
}
