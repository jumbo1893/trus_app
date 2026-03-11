import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/controller/fine_player_notifier.dart';
import 'package:trus_app/features/fine/match/fine_player_args.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../../../../common/widgets/builder/add_list_builder.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';

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
    return Column(
      children: [
        Expanded(
          child: AddListBuilder(
            appBarText: player.name,
            goal: true,
            items: state.receivedFines,
            onAdd: (index) => notifier.addNumber(
              index,
            ),
            onRemove: (index) => notifier.removeNumber(
              index,
            ),
          ),
        ),

          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: CustomButton(
              text: "Potvrď změny",
              onPressed: notifier.changeFines,
            ),
          ),
      ],
    );
  }
}
