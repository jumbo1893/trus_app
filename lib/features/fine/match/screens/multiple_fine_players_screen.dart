import '../../../../common/widgets/entry_draft_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/controller/fine_multiple_player_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../widget/quick_fine_list.dart';
import '../../../../common/widgets/header/header_card.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../fine_multiple_player_args.dart';
import '../../../../common/widgets/bar/bottom_bar.dart';

class MultipleFinePlayersScreen extends CustomConsumerStatefulWidget {
  static const String id = "multiple-fine-players-screen";

  const MultipleFinePlayersScreen({Key? key})
    : super(key: key, title: "Přidat pokutu více hráčům", name: id);

  @override
  ConsumerState<MultipleFinePlayersScreen> createState() =>
      _MultipleFinePlayersScreenState();
}

class _MultipleFinePlayersScreenState
    extends ConsumerState<MultipleFinePlayersScreen> {
  @override
  Widget build(BuildContext context) {
    final sc = ref.read(screenVariablesNotifierProvider);
    final match = sc.matchModel;
    final playerIdList = sc.playerIdList;
    final args = FineMultiplePlayerArgs(match.id!, playerIdList);
    final state = ref.watch(fineMultiplePlayerNotifier(args));
    final notifier = ref.read(fineMultiplePlayerNotifier(args).notifier);
    return EntryDraftScope(
      key: ValueKey(notifier.draftId),
      screenId: MultipleFinePlayersScreen.id,
      draftId: notifier.draftId,
      loaded: state.matchId > 0,
      values: notifier.draftValues,
      baseline: notifier.draftBaseline,
      labels: {
        for (final f in state.receivedFines) '${f.fine.id}': f.fine.name,
      },
      hasChanges: () => ref.read(fineMultiplePlayerNotifier(args)).hasChanges,
      restore: notifier.restoreDraft,
      save: () => notifier.changeFines(navigate: false),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HeaderCard(
                  title: "Vícenásobná úprava pokut",
                  text: "V zápase proti ${match.name}",
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: QuickFineList(
                    items: state.receivedFines,
                    onAdd: (index) => notifier.addNumber(index),
                    onRemove: (index) => notifier.removeNumber(index),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomBar(
          enabled: state.hasChanges,
          onConfirm: notifier.changeFines,
        ),
      ),
    );
  }
}
