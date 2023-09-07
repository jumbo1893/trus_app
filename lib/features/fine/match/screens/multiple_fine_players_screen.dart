import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/listview/listview_add_model.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/fine/match/controller/fine_player_controller.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/helper/fine_match_helper_model.dart';
import 'package:trus_app/models/match_model.dart';

import '../../../../common/widgets/builder/add_builder.dart';
import '../../../../common/widgets/builder/error_future_builder.dart';
import '../../../../common/widgets/button/confirm_button.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../models/api/player_api_model.dart';
import '../../../../models/player_model.dart';
import '../../../notification/controller/notification_controller.dart';
import '../controller/fine_match_controller.dart';

class MultipleFinePlayersScreen extends ConsumerStatefulWidget {
  final VoidCallback onButtonConfirmPressed;
  final List<int> playerIdList;
  final MatchApiModel matchModel;
  final bool isFocused;
  const MultipleFinePlayersScreen({
    Key? key,
    required this.playerIdList,
    required this.matchModel,
    required this.onButtonConfirmPressed,
    required this.isFocused,
  }) : super(key: key);

  @override
  ConsumerState<MultipleFinePlayersScreen> createState() => _MultipleFinePlayersScreenState();
}

class _MultipleFinePlayersScreenState extends ConsumerState<MultipleFinePlayersScreen> {


  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      return ErrorFutureBuilder<void>(
          future: ref.read(finePlayerController).setupMultiFines(widget.playerIdList, widget.matchModel.id!),
          onDialogCancel: () => widget.onButtonConfirmPressed(),
          context: context,
          widget:  Column(
            children: [
              Expanded(
                child: AddBuilder(
                  addController: ref.read(finePlayerController),
                  appBarText: "Pokuty v zápase ${widget.matchModel.name}",
                  goal: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ConfirmButton(
                  text: "Potvrď",
                  context: context,
                  confirmOperations: ref
                      .read(finePlayerController),
                  onOperationComplete: () {
                    widget.onButtonConfirmPressed();
                  },
                  id: -1,),
              )
            ],
          )
      );
    } else {
      return Container();
    }
  }
}
