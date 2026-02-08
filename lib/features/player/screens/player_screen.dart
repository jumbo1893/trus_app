import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/player/controller/player_notifier.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';

import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../main/screen_controller.dart';

class PlayerScreen extends CustomConsumerWidget {
  static const String id = "player-screen";

  const PlayerScreen({
    Key? key,
  }) : super(key: key, title: "Hráči", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ModelToStringListview(
              state: ref.watch(playerNotifierProvider),
              notifier: ref.read(playerNotifierProvider.notifier)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => ref
              .read(screenControllerProvider)
              .changeFragment(AddPlayerScreen.id),
          elevation: 4.0,
          child: const Icon(Icons.add),
        ));
  }
}
