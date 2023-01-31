import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/player/controller/player_controller.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../colors.dart';
import '../../../features/player/utils.dart';
import '../../utils/match_util.dart';

class PlayerDropdownMultiSelect extends ConsumerStatefulWidget {
  final Function(List<String> playersIds) onPlayersSelected;
  final List<String> initPlayers;
  final bool fan;
  const PlayerDropdownMultiSelect(
      {Key? key,
      required this.onPlayersSelected,
      required this.fan,
      required this.initPlayers})
      : super(key: key);

  @override
  ConsumerState<PlayerDropdownMultiSelect> createState() =>
      _PlayerDropdownMultiSelectState();
}

class _PlayerDropdownMultiSelectState
    extends ConsumerState<PlayerDropdownMultiSelect> {

  bool init = true;
  List<PlayerModel?> convertIdsToPlayers(List<PlayerModel> players) {
    List<PlayerModel?> returnList = [];
    for (String playerId in widget.initPlayers) {
      for (PlayerModel playerModel in players) {
        if (playerId == playerModel.id && playerModel.fan == widget.fan) {
          returnList.add(playerModel);
          break;
        }
      }
    }
    print(selectedPlayers);
    if(init) {
      selectedPlayers += returnList;
      init = false;
    }
    //pošleme rovnou callback na screenu, aby viděli co je aktuálně označený
    widget.onPlayersSelected(convertPlayerListToIdList(selectedPlayers));
    return selectedPlayers;
  }

  List<PlayerModel?> selectedPlayers = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlayerModel>>(
        stream: ref.watch(playerControllerProvider).playersOrFans(widget.fan),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          List<PlayerModel> players = sortPlayersByName(snapshot.data!);
          return MultiSelectChipField(
            items: players
                .map((e) => MultiSelectItem<PlayerModel?>(e, e.name))
                .toList(),
            selectedChipColor: orangeColor,
            initialValue: convertIdsToPlayers(players),
            onTap: (List<PlayerModel?> values) {
              selectedPlayers = values;
              widget.onPlayersSelected(convertPlayerListToIdList(selectedPlayers));
            },
            showHeader: false,
            scroll: true,
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 1, color: orangeColor))),
          );
        });
  }
}
