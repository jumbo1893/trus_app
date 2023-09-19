import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/controller/fine_player_controller.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';

import '../../../../common/widgets/builder/add_builder.dart';
import '../../../../common/widgets/builder/error_future_builder.dart';
import '../../../../common/widgets/button/confirm_button.dart';
import '../../../../models/api/player_api_model.dart';

class FinePlayerScreen extends ConsumerStatefulWidget {
  final VoidCallback onButtonConfirmPressed;
  final VoidCallback backToMainMenu;
  final PlayerApiModel playerModel;
  final MatchApiModel matchModel;
  final bool isFocused;
  const FinePlayerScreen({
    Key? key,
    required this.playerModel,
    required this.matchModel,
    required this.onButtonConfirmPressed,
    required this.backToMainMenu,
    required this.isFocused,
  }) : super(key: key);

  @override
  ConsumerState<FinePlayerScreen> createState() => _FinePlayerScreenState();
}

class _FinePlayerScreenState extends ConsumerState<FinePlayerScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      return ErrorFutureBuilder<void>(
          future: ref
              .read(finePlayerController)
              .setupPlayer(widget.playerModel.id!, widget.matchModel.id!),
          backToMainMenu: () => widget.backToMainMenu(),
          context: context,
          widget: Column(
            children: [
              Expanded(
                child: AddBuilder(
                  addController: ref.read(finePlayerController),
                  appBarText: widget.playerModel.name,
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
                    widget.onButtonConfirmPressed();
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
