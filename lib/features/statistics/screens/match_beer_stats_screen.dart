import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/custom_text.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';
import 'package:trus_app/features/statistics/repository/stats_repository.dart';
import 'package:trus_app/models/helper/beer_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/player_model.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../common/widgets/custom_text_field.dart';
import '../../../common/widgets/dropdown/season_dropdown.dart';
import '../../../common/widgets/icon_text_field.dart';
import '../../../models/beer_model.dart';
import '../../../models/helper/beer_helper_model.dart';
import '../controller/stats_controller.dart';
import '../utils.dart';

class MatchBeerStatsScreen extends ConsumerStatefulWidget {
  const MatchBeerStatsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MatchBeerStatsScreen> createState() =>
      _MatchBeerStatsScreenState();
}

class _MatchBeerStatsScreenState extends ConsumerState<MatchBeerStatsScreen> {
  bool orderDescending = true;
  bool showMatchDetail = false;
  late BeerStatsHelperModel pickedMatch;
  List<BeerStatsHelperModel> matches = [];
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
  List<int> overallValuesForMatches() {
    int beer = 0;
    int liquor = 0;
    int overall = 0;
    for (BeerStatsHelperModel match in matches) {
      beer += match.getNumberOfBeersInMatches();
      liquor += match.getNumberOfLiquorsInMatches();
      overall += match.getNumberOfBeersAndLiquorsInMatches();
    }
    return [beer, liquor, overall];
  }

  ///vyfiltruje zápas na základě zadaného řetězce v poli hledat
  ///použít předtím, než se bude buildit listview
  List<BeerStatsHelperModel> filterMatches(
      List<BeerStatsHelperModel> snapshotPlayers) {
    List<BeerStatsHelperModel> matches = [];
    for (BeerStatsHelperModel statsMatch in snapshotPlayers) {
      if (statsMatch.match!.name.contains(_searchController.text)) {
        matches.add(statsMatch);
      }
    }
    return matches;
  }

  void changeScreens(bool detail) {
    setState(() {
      showMatchDetail = detail;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double padding = 8.0;
    if (!showMatchDetail) {
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
                          .beersForMatchesInSeason(
                          ref.read(statsControllerProvider).selectedSeason),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Loader();
                        }
                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filterMatches(snapshot.data ?? []).length + 1,
                            itemBuilder: (context, index) {
                              matches = sortStatsByDrinks(
                                  filterMatches(snapshot.data ?? []), orderDescending);
                              if (index == 0) {
                                List<int> overallStats = overallValuesForMatches();
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
                              var match = matches[index - 1];
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      pickedMatch = match;
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
                                            match.match!.toStringWithOpponentNameAndDate(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ),
                                        subtitle: Text(
                                          "Počet piv: ${match.getNumberOfBeersInMatches()} , počet panáků: ${match.getNumberOfLiquorsInMatches()}, dohromady: ${match.getNumberOfBeersAndLiquorsInMatches()}",
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
                      icon: const Icon(Icons.arrow_back),

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
              child: CustomText(text: "Detail pitiva v zápase ${pickedMatch.match!.toStringWithOpponentName()}"),
            ),
            FutureBuilder<List<PlayerModel>>(
              future: ref.read(statsControllerProvider).playerNamesById(pickedMatch.getPlayerIdsFromMatchPlayer()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: pickedMatch.listOfBeers.length,
                      itemBuilder: (context, index) {
                        List<PlayerModel> players = snapshot.data!;
                        var player = players[index];
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
                                      player.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Počet piv: ${pickedMatch.listOfBeers[index].beerNumber} , počet panáků: ${pickedMatch.listOfBeers[index].liquorNumber}, dohromady: ${pickedMatch.listOfBeers[index].beerNumber+pickedMatch.listOfBeers[index].liquorNumber}",
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
