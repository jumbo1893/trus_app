import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/custom_text.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';
import 'package:trus_app/features/statistics/repository/stats_repository.dart';
import 'package:trus_app/models/helper/beer_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../common/widgets/custom_text_field.dart';
import '../../../common/widgets/dropdown/season_dropdown.dart';
import '../../../common/widgets/icon_text_field.dart';
import '../../../models/beer_model.dart';
import '../../../models/enum/drink.dart';
import '../../../models/enum/participant.dart';
import '../../../models/helper/beer_helper_model.dart';
import '../controller/stats_controller.dart';
import '../utils.dart';

class PlayerBeerStatsScreen extends ConsumerStatefulWidget {
  const PlayerBeerStatsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PlayerBeerStatsScreen> createState() =>
      _PlayerBeerStatsScreenState();
}

class _PlayerBeerStatsScreenState extends ConsumerState<PlayerBeerStatsScreen> {
  bool orderDescending = true;
  bool showPlayerDetail = false;
  late BeerStatsHelperModel pickedPlayer;
  List<BeerStatsHelperModel> players = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void setSelectedSeason(SeasonModel seasonModel) {
    setState(() {
      ref.read(statsControllerProvider).selectedSeason = seasonModel;
    });
  }

  ///první hodnota je pivo
  ///druhá hodnota je panák
  ///třetí hodnota je dohromady
  List<int> overallValuesForPlayers() {
    int beer = 0;
    int liquor = 0;
    int overall = 0;
    for (BeerStatsHelperModel player in players) {
      beer += player.getNumberOfDrinksInMatches(Drink.beer, Participant.both, null);
      liquor += player.getNumberOfDrinksInMatches(Drink.liquor, Participant.both, null);
      overall += player.getNumberOfDrinksInMatches(Drink.both, Participant.both, null);
    }
    return [beer, liquor, overall];
  }

  ///vyfiltruje hráče na základě zadaného řetězce v poli hledat
  ///použít předtím, než se bude buildit listview
  List<BeerStatsHelperModel> filterPlayers(
      List<BeerStatsHelperModel> snapshotPlayers) {
    List<BeerStatsHelperModel> players = [];
    for (BeerStatsHelperModel player in snapshotPlayers) {
      if (player.player!.name.contains(_searchController.text)) {
        players.add(player);
      }
    }
    return players;
  }

  void changeScreens(bool detail) {
    setState(() {
      showPlayerDetail = detail;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double padding = 8.0;
    if (!showPlayerDetail) {
      return FutureBuilder<SeasonModel>(
        future: ref.read(statsControllerProvider).currentSeason(),
        builder: (context, seasonSnapshot) {
          if (seasonSnapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(padding),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                          width: size.width / 2.5 - padding,
                          child: SeasonDropdown(
                              onSeasonSelected: (seasonModel) => {
                                    setSelectedSeason(seasonModel!),
                                    _searchController.clear()
                                  },
                              initSeason: ref.read(statsControllerProvider).selectedSeason ?? seasonSnapshot.data,
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
                  StreamBuilder<List<BeerStatsHelperModel>>(
                      stream: ref
                          .watch(statsControllerProvider)
                          .beersForPlayersInSeason(
                          ref.read(statsControllerProvider).selectedSeason),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Loader();
                        }
                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filterPlayers(snapshot.data ?? []).length + 1,
                            itemBuilder: (context, index) {
                              players = sortStatsByDrinks(
                                  filterPlayers(snapshot.data ?? []), orderDescending);
                              if (index == 0) {
                                List<int> overallStats = overallValuesForPlayers();
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () => {},
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                          color: Colors.grey,
                                        ))),
                                        child: ListTile(
                                          title: const Padding(
                                            padding: EdgeInsets.only(bottom: 16),
                                            child: Text(
                                              "Celkem",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Počet piv: ${overallStats[0]} , počet panáků: ${overallStats[1]}, dohromady: ${overallStats[2]}",
                                            style: const TextStyle(
                                                color: listviewSubtitleColor),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }
                              var player = players[index - 1];
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      pickedPlayer = player;
                                      changeScreens(true);
                                    },
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
                                            player.player!.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ),
                                        subtitle: Text(
                                          "Počet piv: ${player.getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} , počet panáků: ${player.getNumberOfDrinksInMatches(Drink.liquor, Participant.both, null)}, dohromady: ${player.getNumberOfDrinksInMatches(Drink.both, Participant.both, null)}",
                                          style: const TextStyle(
                                              color: listviewSubtitleColor),
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
              ),
            ),
          );
        }
      );
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),

                      onPressed: () {
                        changeScreens(false);
                      },
                      color: orangeColor,
                    )),
                SizedBox(
                    child: TextButton(child: const Text("Zpět", style: TextStyle(color: blackColor, fontSize: 18, fontWeight: FontWeight.normal),), onPressed: () => changeScreens(false)))
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: CustomText(text: "Detail výkonu hráče ${pickedPlayer.player!.name}"),
            ),
            FutureBuilder<List<MatchModel>>(
              future: ref.read(statsControllerProvider).matchNamesById(pickedPlayer.getMatchIdsFromPickedPlayer()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: pickedPlayer.listOfBeers.length,
                      itemBuilder: (context, index) {
                        List<MatchModel> matches = snapshot.data!;
                        var match = matches[index];
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                              },
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
                                      match.toStringWithOpponentNameAndDate(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Počet piv: ${pickedPlayer.listOfBeers[index].beerNumber} , počet panáků: ${pickedPlayer.listOfBeers[index].liquorNumber}, dohromady: ${pickedPlayer.listOfBeers[index].beerNumber+pickedPlayer.listOfBeers[index].liquorNumber}",
                                    style: const TextStyle(
                                        color: listviewSubtitleColor),
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
        ),
      ),
    );
  }
}
