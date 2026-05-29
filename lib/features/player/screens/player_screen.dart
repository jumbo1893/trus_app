import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/player/controller/player_notifier.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';

import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../../models/api/player/player_api_model.dart';
import '../widget/player_list_tile.dart';

class PlayerScreen extends CustomConsumerWidget {
  static const String id = "player-screen";

  const PlayerScreen({Key? key}) : super(key: key, title: "Hráči", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ModelToStringListview(
          storageKey: id,
          state: ref.watch(playerNotifierProvider),
          notifier: ref.read(playerNotifierProvider.notifier),
          itemBuilder: (context, item, onTap, _, _) {
            return PlayerListTile(
              player: item as PlayerApiModel,
              onTap: onTap,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref
            .read(screenNotifierProvider.notifier)
            .changeFragment(AddPlayerScreen.id),
        elevation: 4.0,
        child: const Icon(Icons.add),
      ),
    );
  }
}
