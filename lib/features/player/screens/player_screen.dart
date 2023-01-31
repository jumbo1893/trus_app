import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/player/controller/player_controller.dart';
import 'package:trus_app/models/player_model.dart';

class PlayerScreen extends ConsumerWidget {
  final VoidCallback onPlusButtonPressed;
  final Function(PlayerModel playerModel) setPlayer;
  const PlayerScreen({
    Key? key,
    required this.onPlusButtonPressed,
    required this.setPlayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StreamBuilder<List<PlayerModel>>(
              stream: ref.watch(playerControllerProvider).players(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var player = snapshot.data![index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => setPlayer(player),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8.0, left: 8, right: 8),
                            child: Container(
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                color: Colors.grey,
                              ))),
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    player.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                                subtitle: Text(
                                  player.toStringForPlayerList(),
                                  style: const TextStyle(
                                      color: listviewSubtitleColor),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onPlusButtonPressed,
          elevation: 4.0,
          child: const Icon(Icons.add),
        ));
  }
}
