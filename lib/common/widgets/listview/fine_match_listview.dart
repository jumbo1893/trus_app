import 'package:flutter/material.dart';

import '../../../colors.dart';
import '../../../models/api/player/player_api_model.dart';
import '../../repository/exception/loading_exception.dart';
import '../loader.dart';
import 'custom_checkbox_list_tile.dart';

class FineMatchListview extends StatefulWidget {
  final VoidCallback initPlayerStream;
  final Stream<List<PlayerApiModel>> playersStream;
  final Stream<bool> multiselectStream;
  final Stream<List<PlayerApiModel>> checkedPlayersStream;
  final Function(PlayerApiModel playerApiModel) onPlayerSelected;
  final Function(PlayerApiModel playerApiModel) onPlayerChecked;
  const FineMatchListview(
      {Key? key,
        required this.initPlayerStream,
        required this.playersStream,
        required this.multiselectStream,
        required this.onPlayerSelected,
        required this.onPlayerChecked,
        required this.checkedPlayersStream,
      })
      : super(key: key);

  @override
  State<FineMatchListview> createState() => _FineMatchListviewState();
}

class _FineMatchListviewState extends State<FineMatchListview> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 20),

      child: StreamBuilder<bool>(
        stream: widget.multiselectStream,
        builder: (context, multiselectSnapshot) {
          bool multiselect;
          if (multiselectSnapshot.connectionState == ConnectionState.waiting) {
            multiselect = false;
          }
          if(multiselectSnapshot.hasData) {
            multiselect = multiselectSnapshot.data!;
          }
          else {
            multiselect = false;
          }
          return StreamBuilder<List<PlayerApiModel>>(
              stream: widget.playersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  widget.initPlayerStream();
                  return const Loader();
                }
                if (snapshot.hasError) {
                  if(snapshot.error is LoadingException) {
                    return const Loader();
                  }
                }
                return StreamBuilder<List<PlayerApiModel>>(
                  stream: widget.checkedPlayersStream,
                  builder: (context, checkedSnapshot) {
                    List<PlayerApiModel> checkedPlayers = [];
                    if(checkedSnapshot.hasData) {
                      checkedPlayers = checkedSnapshot.data!;
                    }
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          List<PlayerApiModel> players = snapshot.data!;
                          var player = players[index];
                          if (!multiselect) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    widget.onPlayerSelected(player);
                                  },
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
                                          padding:
                                          const EdgeInsets.only(bottom: 16),
                                          child: Text(
                                            player.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ),
                                        subtitle: Text(
                                          player.toStringForListView(),
                                          style: const TextStyle(
                                              color: listviewSubtitleColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 8.0, left: 8, right: 8),
                              child: Container(
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey,
                                          ))),
                                  child: CustomCheckboxListTile(
                                    initValue: checkedPlayers.contains(player),
                                    player: player,
                                    onCheck: (value) {
                                      widget.onPlayerChecked(player);
                                    },
                                  )),
                            );
                          }
                        });
                  }
                );
              });
        }
      ),
    );
  }
}
