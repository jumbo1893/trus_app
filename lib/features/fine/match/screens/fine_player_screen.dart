import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/controller/fine_player_controller.dart';
import 'package:trus_app/features/fine/match/screens/fine_match_screen.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';

import '../../../../common/widgets/builder/add_builder.dart';
import '../../../../common/widgets/builder/error_future_builder.dart';
import '../../../../common/widgets/button/confirm_button.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../../models/api/player_api_model.dart';
import '../../../main/screen_controller.dart';

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
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(FinePlayerScreen.id)) {
      PlayerApiModel player = ref.watch(screenControllerProvider).playerModel;
      MatchApiModel matchModel = ref.read(screenControllerProvider).matchModel;
      return ErrorFutureBuilder<void>(
          future: ref
              .read(finePlayerController)
              .setupPlayer(player.id!, matchModel.id!),
          context: context,
          widget: Column(
            children: [
              Expanded(
                child: AddBuilder(
                  addController: ref.read(finePlayerController),
                  appBarText: player.name,
                  goal: false,
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
