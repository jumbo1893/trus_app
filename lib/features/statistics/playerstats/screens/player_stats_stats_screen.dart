import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/models/enum/spinner_options.dart';
import 'package:trus_app/models/helper/player_stats_helper_model.dart';

import '../../../../common/widgets/custom_text.dart';
import '../../../../common/widgets/dropdown/season_dropdown.dart';
import '../../../../common/widgets/icon_text_field.dart';
import '../../../../common/widgets/loader.dart';
import '../../../../models/season_model.dart';
import '../../utils.dart';
import '../controller/player_stats_controller.dart';


class PlayerStatsStatsScreen extends ConsumerStatefulWidget {
  const PlayerStatsStatsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PlayerStatsStatsScreen> createState() =>
      _PlayerStatsStatsScreenState();
}

class _PlayerStatsStatsScreenState
    extends ConsumerState<PlayerStatsStatsScreen> {
  SpinnerOption? selectedValue;
  bool orderDescending = true;
  bool goalsScreen = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void onTabChanged(int tab) {
    if (tab == 0) {
      goalsScreen = true;
    } else {
      goalsScreen = false;
    }
    setState(() {
    });
  }

  List<PlayerStatsHelperModel> filterPlayers(
      List<PlayerStatsHelperModel> snapshotPlayers) {
    List<PlayerStatsHelperModel> players = [];
    for (PlayerStatsHelperModel player in snapshotPlayers) {
      if (player.player.name.contains(_searchController.text)) {
        players.add(player);
      }
    }
    return players;
  }

  void setSelectedSeason(SeasonModel seasonModel) {
    setState(() {
      ref.read(playerStatsControllerProvider).selectedSeason = seasonModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double padding = 8.0;
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 0,
            bottom: TabBar(
              onTap: (tab) => onTabChanged(tab),
              labelColor: blackColor,
              indicatorColor: orangeColor,
              tabs: [
                FittedBox(
                    child: Tab(
                  child: CustomText(text: "Góly"),
                )),
                FittedBox(
                    child: Tab(
                  child: CustomText(text: "Asistence"),
                )),
              ],
            ),
          ),
          body: FutureBuilder(
            future: ref.read(playerStatsControllerProvider).currentSeason(),
            builder: (context, seasonSnapshot) {
              if (seasonSnapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              return Column(
                children: [Row(
                  children: [
                    SizedBox(
                        width: size.width / 2.5 - padding,
                        child: SeasonDropdown(
                            onSeasonSelected: (seasonModel) =>
                            {
                              setSelectedSeason(seasonModel!),
                              _searchController.clear()
                            },
                            initSeason: ref
                                .read(playerStatsControllerProvider)
                                .selectedSeason ?? seasonSnapshot.data,
                            allSeasons: true,
                            otherSeason: true)),
                    SizedBox(
                        width: size.width / 5,
                        child: Center(
                          child: IconButton(
                            icon: (orderDescending
                                ? const Icon(Icons.arrow_upward)
                                : const Icon(Icons.arrow_downward)),
                            onPressed: () {
                              setState(() {
                                orderDescending = !orderDescending;
                              });
                            },
                            color: orangeColor,
                          ),
                        )),
                    SizedBox(
                        width: size.width / 2.5 - padding,
                        child: IconTextField(
                          textController: _searchController,
                          labelText: "hledat",
                          onIconPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.search, color: blackColor),
                        )),
                  ],
                ),
                  StreamBuilder<List<PlayerStatsHelperModel>>(
                      stream: ref
                          .watch(playerStatsControllerProvider)
                          .playerStatsForPlayersInSeason(ref
                          .read(playerStatsControllerProvider)
                          .selectedSeason),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          //updatePlayerStats();
                        }
                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filterPlayers((snapshot.data ?? [])).length,
                            itemBuilder: (context, index) {
                              var player = filterPlayers(sortByGoalsOrAssists(snapshot.data!, orderDescending, goalsScreen))[index];
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey,
                                              ))),
                                      child: ListTile(
                                        title: Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              bottom: 16),
                                          child: Text(
                                            player.player.name,
                                            style: const TextStyle(
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ),
                                        subtitle: Text(goalsScreen ?
                                          "počet gólů: ${player.goalNumber}" : "počet asistencí: ${player.assistNumber}",
                                          style: const TextStyle(
                                              color:
                                              listviewSubtitleColor),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        );
                      }),
                ],
              );
            }),
        ),
      ),
    );
  }
}
