import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/controller/fine_player_controller.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';

import '../../../../common/widgets/builder/add_builder.dart';
import '../../../../common/widgets/builder/error_future_builder.dart';
import '../../../../common/widgets/button/confirm_button.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../main/screen_controller.dart';
import 'fine_match_screen.dart';

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
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(MultipleFinePlayersScreen.id)) {
      List<int> playerIdList = ref.read(screenControllerProvider).playerIdList;
      MatchApiModel matchModel = ref.read(screenControllerProvider).matchModel;
      return ErrorFutureBuilder<void>(
          future: ref
              .read(finePlayerController)
              .setupMultiFines(playerIdList, matchModel.id!),
          context: context,
          widget: Column(
            children: [
              Expanded(
                child: AddBuilder(
                  addController: ref.read(finePlayerController),
                  appBarText: "Pokuty v zápase ${matchModel.name}",
                  goal: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ConfirmButton(
                  text: "Potvrď změny",
                  context: context,
                  confirmOperations: ref.read(finePlayerController),
                  onOperationComplete: () {
                    ref
                        .read(screenControllerProvider)
                        .changeFragment(FineMatchScreen.id);
                  },
                  id: -1,
                ),
              )
            ],
          ));
    } else {
      return Container();
    }
  }
}
