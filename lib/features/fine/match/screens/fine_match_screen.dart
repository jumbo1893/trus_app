import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/dropdown/match_dropdown.dart';
import 'package:trus_app/models/match_model.dart';

import '../../../../common/widgets/listview/custom_checkbox_list_tile.dart';
import '../../../../models/player_model.dart';
import '../../../player/controller/player_controller.dart';

class FineMatchScreen extends ConsumerStatefulWidget {
  final Function(PlayerModel playerModel) setPlayer;
  final Function(MatchModel matchModel) setMainMatch;
  final Function(List<PlayerModel> playerListToChangeFines)
      playerListToChangeFines;
  final MatchModel mainMatch;
  const FineMatchScreen({
    Key? key,
    required this.setPlayer,
    required this.playerListToChangeFines,
    required this.setMainMatch,
    required this.mainMatch,
  }) : super(key: key);

  @override
  ConsumerState<FineMatchScreen> createState() => _FineMatchScreenState();
}

class _FineMatchScreenState extends ConsumerState<FineMatchScreen>
    with TickerProviderStateMixin {
  MatchModel? selectedValue; //ukládáme zde zvolený zápas ze spinneru z appbaru
  List<String> matchPlayers = []; // list hráčů, kteří se účastnili zápasu
  List<PlayerModel> allPlayers = []; //list všech hráčů z db
  bool multiselect = false; //pokud má bejt zobrazenej multiselect listview
  List<bool> checkedPlayers = []; //list všech hráčů z db pro check

  late AnimationController _controller;

  //musíme udělat init AnimationControlleru v initState, abysme mohli doplnit parametr vsync. Ten čerpá z TickerProviderStateMixin
  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    super.initState();
  }

  //metody pro multicheck
  void _setNewCheckedPlayers(int length) {
    if (checkedPlayers.length != length) {
      checkedPlayers.clear();
      for (int i = 0; i < length; i++) {
        checkedPlayers.add(false);
      }
    }
  }

  void _checkAllPlayers() {
    for (int i = 0; i < checkedPlayers.length; i++) {
      if (_isPlayerAndActive(i)) {
        checkedPlayers[i] = true;
      } else {
        checkedPlayers[i] = false;
      }
    }
  }

  void _checkOnlyPlayers(bool player) {
    for (int i = 0; i < allPlayers.length; i++) {
      if (_isPlayerAndActive(i)) {
        if (matchPlayers.contains(allPlayers[i].id)) {
          checkedPlayers[i] = player;
        } else {
          checkedPlayers[i] = !player;
        }
      } else {
        checkedPlayers[i] = false;
      }
    }
  }

  bool _isPlayerAndActive(int index) {
    return (allPlayers[index].isActive && !allPlayers[index].fan);
  }

  //ikony pro floatingActionBar
  static const List<IconData> icons = [
    Icons.check,
    Icons.group,
    Icons.accessible_forward,
    Icons.man
  ];

  void _setNewMatch(MatchModel matchModel) {
    setState(() {
      selectedValue = matchModel;
    });
    widget.setMainMatch(matchModel);
  }

  List<PlayerModel> _getCheckedPlayers() {
    List<PlayerModel> returnList = [];
    for (int i = 0; i < checkedPlayers.length; i++) {
      if (checkedPlayers[i]) {
        returnList.add(allPlayers[i]);
      }
    }
    return returnList;
  }

  void _setMultiSelect(bool multi) {
    setState(() {
      multiselect = multi;
    });
  }

  //seřadí hráče podle toho, jestli se účastnili zápasu
  List<PlayerModel> sortPlayerByAttendanceInMatch(
      List<PlayerModel> allPlayers, List<String> matchPlayers) {
    if (matchPlayers.isEmpty) {
      matchPlayers.addAll(widget.mainMatch.playerIdList);
    }
    List<PlayerModel> returnList = [];
    List<PlayerModel> otherPlayers = [];
    for (PlayerModel playerModel in allPlayers) {
      if (matchPlayers.contains(playerModel.id)) {
        returnList.add(playerModel);
      } else {
        otherPlayers.add(playerModel);
      }
    }
    returnList
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    otherPlayers
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    returnList.addAll(otherPlayers);
    return returnList;
  }

  void onIconClick(int index) {
    switch (index) {
      //fajfka
      case 0:
        {
          List<PlayerModel> players = _getCheckedPlayers();
          if (players.isEmpty) {
            showSnackBar(
                context: context,
                content: "Musí být označen aspoň jeden hráč!");
          } else {
            widget.playerListToChangeFines(players);
          }
          break;
        }
      //všichni hráči
      case 1:
        {
          _checkAllPlayers();
          setState(() {});
          break;
        }
      //nehrající
      case 2:
        {
          _checkOnlyPlayers(false);
          setState(() {});
          break;
        }
      //hrající
      case 3:
        {
          _checkOnlyPlayers(true);
          setState(() {});
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: ConstrainedBox(
          constraints: BoxConstraints(minWidth: size.width),
          child: MatchDropdown(
              onMatchSelected: (matchModel) => _setNewMatch(matchModel!),
              onInitMatchSelected: (matchModel) =>
                  widget.setMainMatch(matchModel!),
              initMatch: selectedValue,
              onPlayersSelected: (players) {
                matchPlayers = players;
              }),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 20),
        child: StreamBuilder<List<PlayerModel>>(
            stream: ref.watch(playerControllerProvider).players(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  List<PlayerModel> players = sortPlayerByAttendanceInMatch(
                      snapshot.data!, matchPlayers);
                  allPlayers = players;
                  var player = players[index];

                  if (player.isActive && !player.fan) {
                    if (!multiselect) {
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              widget.setPlayer(player);
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
                    } else {
                      _setNewCheckedPlayers(players.length);
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
                              initValue: checkedPlayers[index],
                              player: player,
                              onCheck: (value) {
                                checkedPlayers[index] = value;
                              },
                            )),
                      );
                    }
                  } else {
                    return Container();
                  }
                },
              );
            }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(icons.length, (int index) {
            Color backColor;
            Color iconColor;
            if (index == 0) {
              backColor = Colors.lightGreen;
              iconColor = Colors.black;
            } else {
              backColor = backgroundColor;
              iconColor = Colors.orange;
            }
            Widget child = Container(
              height: 70.0,
              width: 56.0,
              alignment: FractionalOffset.topCenter,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: Interval(0.0, 1.0 - index / icons.length / 2.0,
                      curve: Curves.easeOut),
                ),
                child: FloatingActionButton(
                  heroTag: null,
                  backgroundColor: backColor,
                  mini: true,
                  child: Icon(icons[index], color: iconColor),
                  onPressed: () {
                    onIconClick(index);
                  },
                ),
              ),
            );
            return child;
          }).toList()
            ..add(
              FloatingActionButton(
                heroTag: null,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget? child) {
                    return Transform(
                      transform:
                          Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                      alignment: FractionalOffset.center,
                      child: Icon(_controller.isDismissed
                          ? Icons.checklist
                          : Icons.close),
                    );
                  },
                ),
                onPressed: () {
                  if (_controller.isDismissed) {
                    _controller.forward();
                    _setMultiSelect(true);
                  } else {
                    _controller.reverse();
                    _setMultiSelect(false);
                    checkedPlayers.clear();
                  }
                },
              ),
            ),
        ),
      ),
    );
  }
}
