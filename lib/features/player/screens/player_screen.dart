import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/player_api_model.dart';
import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../controller/player_controller.dart';

class PlayerScreen extends ConsumerWidget {
  final VoidCallback onPlusButtonPressed;
  final VoidCallback backToMainMenu;
  final Function(PlayerApiModel playerModel) setPlayer;
  final bool isFocused;
  const PlayerScreen({
    Key? key,
    required this.onPlusButtonPressed,
    required this.setPlayer,
    required this.backToMainMenu,
    required this.isFocused,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isFocused) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ModelsErrorFutureBuilder(
            future: ref.watch(playerControllerProvider).getModels(),
            onPressed: (player) => {setPlayer(player as PlayerApiModel)},
            onDialogCancel: () => backToMainMenu.call(),
            context: context,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onPlusButtonPressed,
          elevation: 4.0,
          child: const Icon(Icons.add),
        ));
    }
    else {
      return Container();
    }
  }
}
