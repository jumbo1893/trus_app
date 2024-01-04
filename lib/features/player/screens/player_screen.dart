import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/models/api/player_api_model.dart';
import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../main/screen_controller.dart';
import '../controller/player_controller.dart';
import 'edit_player_screen.dart';

class PlayerScreen extends CustomConsumerWidget {
  static const String id = "player-screen";

  const PlayerScreen({
    Key? key,
  }) : super(key: key, title: "Hráči", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(screenControllerProvider).isScreenFocused(id)) {
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ModelsErrorFutureBuilder(
              key: const ValueKey('player_list'),
              future: ref.watch(playerControllerProvider).getModels(),
              onPressed: (player) => {
                ref
                    .read(screenControllerProvider)
                    .setPlayer(player as PlayerApiModel),
                ref
                    .read(screenControllerProvider)
                    .changeFragment(EditPlayerScreen.id)
              },
              context: context,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => ref
                .read(screenControllerProvider)
                .changeFragment(AddPlayerScreen.id),
            elevation: 4.0,
            child: const Icon(Icons.add),
          ));
    } else {
      return Container();
    }
  }
}
