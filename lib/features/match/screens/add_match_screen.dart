import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/rows/row_calendar.dart';
import 'package:trus_app/common/widgets/rows/row_switch.dart';
import 'package:trus_app/common/widgets/rows/row_text_field.dart';
import 'package:trus_app/common/widgets/sliding_pkfl_appbar.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';
import 'package:trus_app/features/match/screens/match_screen.dart';
import 'package:trus_app/models/helper/player_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/utils/field_validator.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/appbar_headline.dart';
import '../../../common/widgets/custom_text.dart';
import '../../../common/widgets/dropdown/player_dropdown_multiselect.dart';
import '../../../common/widgets/dropdown/season_dropdown_button.dart';
import '../../../common/widgets/listview/listview_add_model.dart';
import '../../../common/widgets/loader.dart';
import '../../fine/match/controller/fine_match_controller.dart';
import '../../season/controller/season_controller.dart';
import '../../season/utils/season_calculator.dart';
import '../match_screens.dart';

class AddMatchScreen extends ConsumerStatefulWidget {
  final VoidCallback onAddMatchPressed;
  const AddMatchScreen({
    Key? key,
    required this.onAddMatchPressed,
  }) : super(key: key);

  @override
  ConsumerState<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends ConsumerState<AddMatchScreen> {
  MatchScreens screen = MatchScreens.editMatch;
  final _nameController = TextEditingController();
  final _calendarController = TextEditingController();
  String nameErrorText = "";
  String seasonErrorText = "";

  DateTime pickedDate = DateTime.now();
  bool isHomeChecked = false;
  bool writeToFines = true;
  SeasonModel? pickedSeason;
  List<String> playerList = [];
  List<String> fansList = [];
  List<SeasonModel> allSeasons = [];
  MatchModel? addedMatch;
  List<PlayerStatsHelperModel> playerStatsList = [];
  List<int> goalNumber = [];
  List<int> assistNumber = [];
  bool appBarVisibility = true;

  @override
  void dispose() {
    _nameController.dispose();
    _calendarController.dispose();

    super.dispose();
  }

  Future<void> addMatch(bool playerStats) async {
    String name = _nameController.text.trim();
    setState(() {
      nameErrorText = validateEmptyField(name);
    });
    if (pickedSeason == null || pickedSeason == SeasonModel.automaticSeason()) {
      pickedSeason = calculateAutomaticSeason(allSeasons, pickedDate);
    }
    if (nameErrorText.isEmpty) {
      addedMatch = await ref.read(matchControllerProvider).addMatch(
          context,
          name,
          pickedDate,
          isHomeChecked,
          (playerList + fansList),
          pickedSeason!.id);
      if (addedMatch != null) {
        if (!playerStats) {
          widget.onAddMatchPressed.call();
        } else {
          changeScreens(MatchScreens.addGoals);
        }
      }
    }
  }

  void setNewPlayerStatsNumber(int length) {
    goalNumber.clear();
    assistNumber.clear();
    for (int i = 0; i < length; i++) {
      goalNumber.add(-1);
      assistNumber.add(-1);
    }
  }

  void changeScreens(MatchScreens screen) {
    setState(() {
      this.screen = screen;
    });
  }

  Future<void> changePlayerStats() async {
    showLoaderSnackBar(context: context);
    for (int i = 0; i < goalNumber.length; i++) {
      if (goalNumber[i] != -1 || assistNumber[i] != -1) {
        if (await addPlayerStats(
                playerStatsList[i].id,
                playerStatsList[i].player.id,
                goalNumber[i] == -1
                    ? playerStatsList[i].goalNumber
                    : goalNumber[i],
                assistNumber[i] == -1
                    ? playerStatsList[i].assistNumber
                    : assistNumber[i]) &&
            writeToFines) {
          await rewriteFinesForPlayer(
              playerStatsList[i].player.id,
              goalNumber[i] == -1
                  ? playerStatsList[i].goalNumber
                  : goalNumber[i]);
        }
      }
    }
    hideSnackBar(context);
    showSnackBar(
      context: context,
      content: "Stavy gólů a asistencí úspěšně změněny",
    );
    widget.onAddMatchPressed.call();
  }

  Future<bool> addPlayerStats(
      String id, String playerId, int goalNumber, int assistNumber) async {
    return await ref.read(matchControllerProvider).addPlayerStatsInMatch(
        context, id, addedMatch!.id, playerId, goalNumber, assistNumber);
  }

  //TODO pokuta gol a hattrick natvrdo
  Future<void> rewriteFinesForPlayer(String playerId, int number) async {
    if (await ref.read(matchControllerProvider).addFinesInMatch(
        context, addedMatch!.id, playerId, "ubSjhRc8KThXHo3yIEQc", number)) {}
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;
    final size = MediaQuery.of(context).size;
    switch (screen) {
      case MatchScreens.editMatch:
        _calendarController.text = dateTimeToString(pickedDate);
        return FutureBuilder<PkflMatch?>(
            future: appBarVisibility ? ref.read(matchControllerProvider).getLastPkflMatch() : null,
            builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                var pkflMatch = snapshot.data;
                if(pkflMatch == null) {
                  appBarVisibility = false;
                }
              return Scaffold(
                appBar: appBarVisibility ? SlidingPkflAppBar(pkflMatch: snapshot.data, onConfirmPressed: () {
                  setState(() {
                    _nameController.text = pkflMatch?.opponent ?? "";
                    pickedDate = (pkflMatch?.date ?? pickedDate);
                    isHomeChecked = pkflMatch?.homeMatch ?? false;
                    appBarVisibility = false;
                  });
                }, onAppBarInvisible: () {   setState(() {
                  appBarVisibility = false;

                });  },
                  ): null,
                body: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: SafeArea(
                    child: ListView(
                      children: [
                        RowTextField(
                            size: size,
                            padding: padding,
                            textController: _nameController,
                            errorText: nameErrorText,
                            labelText: "jméno",
                            textFieldText: "Jméno soupeře:"),
                        const SizedBox(height: 10),
                        RowCalendar(
                          pickedDate: pickedDate,
                          size: size,
                          padding: padding,
                          calendarController: _calendarController,
                          textFieldText: "Datum zápasu:",
                          onDateChanged: (date) {
                            setState(() => pickedDate = date);
                          },
                        ),
                        const SizedBox(height: 10),
                        RowSwitch(
                          size: size,
                          padding: padding,
                          textFieldText: "Domácí zápas?",
                          initChecked: isHomeChecked,
                          onChecked: (home) {
                            setState(() => isHomeChecked = home);
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width: (size.width / 3) - padding,
                                  child: CustomText(text: "Vyber sezonu:")),
                              SizedBox(
                                width: (size.width / 1.5) - padding,
                                child: StreamBuilder<List<SeasonModel>>(
                                    stream: ref
                                        .watch(seasonControllerProvider)
                                        .seasons(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Loader();
                                      }
                                      List<SeasonModel> seasons =
                                          snapshot.data!;
                                      allSeasons = snapshot.data!;
                                      seasons.add(SeasonModel.otherSeason());

                                      seasons.insert(
                                          0, SeasonModel.automaticSeason());

                                      return SeasonDropdownButton(
                                        errorText: seasonErrorText,
                                        items: seasons,
                                        onSeasonSelected: (season) {
                                          pickedSeason = season;
                                        },
                                      );
                                    }),
                              ),
                            ]),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: (size.width / 3) - padding,
                                child: CustomText(text: "Vyber hráče:")),
                            SizedBox(
                                width: (size.width / 1.5) - padding,
                                child: PlayerDropdownMultiSelect(
                                  onPlayersSelected: (players) {
                                    playerList = players;
                                  },
                                  fan: false,
                                  initPlayers: const [],
                                )),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: (size.width / 3) - padding,
                                child: CustomText(text: "Vyber fanoušky:")),
                            SizedBox(
                                width: (size.width / 1.5) - padding,
                                child: PlayerDropdownMultiSelect(
                                  onPlayersSelected: (players) {
                                    fansList = players;
                                  },
                                  fan: true,
                                  initPlayers: const [],
                                )),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                            text: "Přidej zápas",
                            onPressed: () => addMatch(false)),
                        CustomButton(
                            text: "Pokračuj k hráčům",
                            onPressed: () => addMatch(true))
                      ],
                    ),
                  ),
                ),
              );
            });
      case MatchScreens.addGoals:
        return Scaffold(
          appBar: const AppBarHeadline(
            text: "Přidej góly",
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: StreamBuilder<List<PlayerStatsHelperModel>>(
              stream: ref
                  .watch(matchControllerProvider)
                  .playersStatsInMatch(playerList, addedMatch!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                playerStatsList = (snapshot.data!);
                setNewPlayerStatsNumber(snapshot.data!.length);
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var playerStats = playerStatsList[index];
                          return Column(
                            children: [
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, left: 8, right: 8),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                      color: Colors.grey,
                                    ))),
                                    child: ListviewAddModel(
                                      onNumberChanged: (number) {
                                        goalNumber[index] = number;
                                      },
                                      padding: 16,
                                      helperModel: playerStats,
                                      fieldName: "goal",
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CustomButton(
                          text: "Pokračuj k asistencím",
                          onPressed: () =>
                              changeScreens(MatchScreens.addAssists)),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      case MatchScreens.addAssists:
        return Scaffold(
          appBar: const AppBarHeadline(
            text: "Přidej asistence",
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: StreamBuilder<List<PlayerStatsHelperModel>>(
              stream: ref
                  .watch(matchControllerProvider)
                  .playersStatsInMatch(playerList, addedMatch!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                playerStatsList = (snapshot.data!);
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var playerStats = playerStatsList[index];
                          return Column(
                            children: [
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, left: 8, right: 8),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                      color: Colors.grey,
                                    ))),
                                    child: ListviewAddModel(
                                      onNumberChanged: (number) {
                                        assistNumber[index] = number;
                                      },
                                      padding: 16,
                                      helperModel: playerStats,
                                      fieldName: "assist",
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(padding),
                      child: RowSwitch(
                        size: size,
                        padding: padding,
                        textFieldText: "Propsat do pokut?",
                        initChecked: writeToFines,
                        onChecked: (write) {
                          setState(() => writeToFines = write);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CustomButton(
                          text: "Ulož hráčské statistiky",
                          onPressed: () => changePlayerStats()),
                    ),
                  ],
                );
              },
            ),
          ),
        );
    }
  }
}
