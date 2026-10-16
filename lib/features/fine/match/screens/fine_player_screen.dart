import '../../../../common/utils/calendar.dart';
import '../../../../common/widgets/entry_draft_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/controller/fine_player_notifier.dart';
import 'package:trus_app/features/fine/match/fine_player_args.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../widget/quick_fine_list.dart';
import '../widget/fine_correction_button.dart';
import '../../../../common/widgets/header/header_card.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';

class FinePlayerScreen extends CustomConsumerStatefulWidget {
  static const String id = "fine-player-screen";

  const FinePlayerScreen({Key? key})
    : super(key: key, title: "Přidat pokutu hráči", name: id);

  @override
  ConsumerState<FinePlayerScreen> createState() => _FinePlayerScreenState();
}

class _FinePlayerScreenState extends ConsumerState<FinePlayerScreen> {
  bool _correcting = false;
  @override
  Widget build(BuildContext context) {
    final sc = ref.read(screenVariablesNotifierProvider);
    final match = sc.matchModel;
    final player = sc.playerModel;

    final args = FinePlayerArgs(match.id!, player.id!);
    final state = ref.watch(finePlayerNotifier(args));
    final notifier = ref.read(finePlayerNotifier(args).notifier);

    return EntryDraftScope(
      key: ValueKey(notifier.draftId),
      screenId: FinePlayerScreen.id,
      draftId: notifier.draftId,
      loaded: state.matchId > 0,
      values: notifier.draftValues,
      baseline: notifier.draftBaseline,
      labels: {
        for (final f in state.receivedFines) '${f.fine.id}': f.fine.name,
      },
      hasChanges: () => ref.read(finePlayerNotifier(args)).hasChanges,
      restore: notifier.restoreDraft,
      save: () => notifier.changeFines(navigate: false),
      showStatus: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HeaderCard(
                  title: player.name,
                  text:
                      "Zápas proti ${match.name} · ${dateTimeToString(match.date)}",
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: QuickFineList(
                    items: state.receivedFines,
                    correcting: _correcting,
                    onAdd: (index) => notifier.addNumber(index),
                    onRemove: (index) => notifier.removeNumber(index),
                  ),
                ),
              ),
              if (notifier.saveFailed)
                TextButton.icon(
                  onPressed: () => notifier
                      .changeFines(navigate: false)
                      .catchError((Object _) {}),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Nepodařilo se uložit · Zkusit znovu'),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(notifier.saving
                          ? 'Ukládá se…'
                          : notifier.saveFailed
                              ? 'Neuloženo'
                              : 'Ukládá se automaticky'),
                    ),
                    FineCorrectionButton(
                      correcting: _correcting,
                      onTap: () => setState(() => _correcting = !_correcting),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
