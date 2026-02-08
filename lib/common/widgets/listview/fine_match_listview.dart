import 'package:flutter/material.dart';

import '../../../colors.dart';
import '../../../models/api/player/player_api_model.dart';
import 'custom_checkbox_list_tile.dart';

class FineMatchListview extends StatefulWidget {
  final List<PlayerApiModel> players;
  final bool multiselect;
  final List<PlayerApiModel> checkedPlayers;
  final Function(PlayerApiModel playerApiModel) onPlayerSelected;
  final Function(PlayerApiModel playerApiModel) onPlayerChecked;

  const FineMatchListview({
    Key? key,
    required this.players,
    required this.multiselect,
    required this.onPlayerSelected,
    required this.onPlayerChecked,
    required this.checkedPlayers,
  }) : super(key: key);

  @override
  State<FineMatchListview> createState() => _FineMatchListviewState();
}

class _FineMatchListviewState extends State<FineMatchListview> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 20),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: widget.players.length,
          itemBuilder: (context, index) {
            List<PlayerApiModel> players = widget.players;
            var player = players[index];
            if (!widget.multiselect) {
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      widget.onPlayerSelected(player);
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
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
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          subtitle: Text(
                            player.toStringForListView(),
                            style:
                                const TextStyle(color: listviewSubtitleColor),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
                child: Container(
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      color: Colors.grey,
                    ))),
                    child: CustomCheckboxListTile(
                      initValue: widget.checkedPlayers.contains(player),
                      player: player,
                      onCheck: (value) {
                        widget.onPlayerChecked(player);
                      },
                    )),
              );
            }
          }),
    );
  }
}
