import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/controller/fine_multiple_player_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../../../../common/widgets/builder/add_list_builder.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../fine_multiple_player_args.dart';

class MultipleFinePlayersScreen extends CustomConsumerStatefulWidget {
  static const String id = "multiple-fine-players-screen";

  const MultipleFinePlayersScreen({
    Key? key,
  }) : super(key: key, title: "Přidat pokutu více hráčům", name: id);

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
    return Column(
      children: [
        Expanded(
          child: AddListBuilder(
            appBarText: "Pokuty v zápase ${match.name}",
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
