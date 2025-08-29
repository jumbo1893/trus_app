import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/view_player_screen.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../../../common/widgets/builder/models_cache_builder.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../main/screen_controller.dart';
import '../controller/player_controller.dart';

class PlayerScreen extends CustomConsumerWidget {
  static const String id = "player-screen";

  const PlayerScreen({
    Key? key,
  }) : super(key: key, title: "Hráči", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(screenControllerProvider).isScreenFocused(id)) {
      var provider = ref.watch(playerControllerProvider);
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ModelsCacheBuilder(
              key: const ValueKey('fine_list'),
              listSetup: provider.setupPlayerList(),
              modelToStringListControllerMixin: provider,
              hashKey: provider.playerListId,
              onPressed: (player) => {
                ref
                    .read(screenControllerProvider)
                    .setPlayer(player as PlayerApiModel),
                ref
                    .read(screenControllerProvider)
                    .changeFragment(ViewPlayerScreen.id)
              },
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
