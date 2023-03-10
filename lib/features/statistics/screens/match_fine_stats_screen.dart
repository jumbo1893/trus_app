import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/custom_text.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/models/helper/fine_stats_helper_model.dart';
import 'package:trus_app/models/player_model.dart';
import 'package:trus_app/models/season_model.dart';
import '../../../common/widgets/dropdown/season_dropdown.dart';
import '../../../common/widgets/icon_text_field.dart';
import '../../../models/enum/fine.dart';
import '../controller/stats_controller.dart';
import '../utils.dart';

class MatchFineStatsScreen extends ConsumerStatefulWidget {
  const MatchFineStatsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MatchFineStatsScreen> createState() =>
      _MatchFineStatsScreenState();
}

class _MatchFineStatsScreenState extends ConsumerState<MatchFineStatsScreen> {
  bool orderDescending = true;
  bool showMatchDetail = false;
  late FineStatsHelperModel pickedMatch;
  List<FineStatsHelperModel> matches = [];
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
  ///druhá hodnota je celkem
  List<int> overallValuesForMatches() {
    int number = 0;
    int amount = 0;
    for (FineStatsHelperModel match in matches) {
      number += match.getNumberOrAmountOfFines(Fine.number);
      amount += match.getNumberOrAmountOfFines(Fine.amount);
    }
    return [number, amount];
  }

  ///vyfiltruje hráče na základě zadaného řetězce v poli hledat
  ///použít předtím, než se bude buildit listview
  List<FineStatsHelperModel> filterMatches(
      List<FineStatsHelperModel> snapshotMatches) {
    List<FineStatsHelperModel> matches = [];
    for (FineStatsHelperModel match in snapshotMatches) {
      if (match.match!.name.contains(_searchController.text)) {
        matches.add(match);
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
                  StreamBuilder<List<FineStatsHelperModel>>(
                      stream: ref
                          .watch(statsControllerProvider)
                          .finesForMatchesInSeason(
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
                              matches = sortStatsByFines(
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
                                            "Počet pokut: ${overallStats[0]}, celková částka: ${overallStats[1]} Kč",
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
                                            match.match!.toStringWithOpponentName(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ),
                                        subtitle: Text(
                                          "Počet pokut: ${match.getNumberOrAmountOfFines(Fine.number)}, celkem: ${match.getNumberOrAmountOfFines(Fine.amount)} Kč",
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
              child: CustomText(text: "Detail pokut ze zápasu ${pickedMatch.match!.name}"),
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
                      itemCount: snapshot.data!.length,
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
                                    pickedMatch.returnMatchDetail(player.id),
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
