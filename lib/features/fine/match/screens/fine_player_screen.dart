import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/controller/fine_player_notifier.dart';
import 'package:trus_app/features/fine/match/fine_player_args.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../../../../common/widgets/builder/add_list_builder.dart';
import '../../../../common/widgets/header/header_card.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../../common/widgets/bar/bottom_bar.dart';

class FinePlayerScreen extends CustomConsumerStatefulWidget {
  static const String id = "fine-player-screen";

  const FinePlayerScreen({
    Key? key,
  }) : super(key: key, title: "Přidat pokutu hráči", name: id);

  @override
  ConsumerState<FinePlayerScreen> createState() => _FinePlayerScreenState();
}

class _FinePlayerScreenState extends ConsumerState<FinePlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final sc = ref.read(screenVariablesNotifierProvider);
    final match = sc.matchModel;
    final player = sc.playerModel;

    final args = FinePlayerArgs(match.id!, player.id!);
    final state = ref.watch(finePlayerNotifier(args));
    final notifier = ref.read(finePlayerNotifier(args).notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HeaderCard(
                title: player.name,
                text: "Uprav počet pokuv pro hřáče",
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AddListBuilder(
                  items: state.receivedFines,
                  onAdd: (index) => notifier.addNumber(index),
                  onRemove: (index) => notifier.removeNumber(index),
                  goal: true,
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
    );
  }
}