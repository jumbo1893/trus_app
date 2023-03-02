
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/rows/row_calendar.dart';
import 'package:trus_app/common/widgets/rows/row_switch.dart';
import 'package:trus_app/common/widgets/rows/row_text_field.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/utils/field_validator.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/appbar_headline.dart';
import '../../../common/widgets/confirmation_dialog.dart';
import '../../../common/widgets/custom_text.dart';
import '../../../common/widgets/listview/listview_add_model.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/dropdown/player_dropdown_multiselect.dart';
import '../../../common/widgets/dropdown/season_dropdown_button.dart';
import '../../../models/helper/player_stats_helper_model.dart';
import '../../season/controller/season_controller.dart';
import '../../season/utils/season_calculator.dart';
import '../match_screens.dart';

class EditMatchScreen extends ConsumerStatefulWidget {
  final VoidCallback onButtonConfirmPressed;
  final MatchModel? matchModel;
  bool init;
  EditMatchScreen({
    Key? key,
    this.init = true,
    required this.onButtonConfirmPressed,
    required this.matchModel,
  }) : super(key: key);

  @override
  ConsumerState<EditMatchScreen> createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends ConsumerState<EditMatchScreen> {
  final _nameController = TextEditingController();
  final _calendarController = TextEditingController();
  String nameErrorText = "";
  String seasonErrorText = "";
  bool writeToFines = true;
  DateTime pickedDate = DateTime.now();
  bool isHomeChecked = false;
  SeasonModel? pickedSeason;
  List<String> fanList = [];
  List<String> playerList = [];
  List<SeasonModel> allSeasons = [];
  List<String> initPlayerIdList = [];
  String? initSeasonId;
  List<PlayerStatsHelperModel> playerStatsList = [];
  List<int> goalNumber = [];
  List<int> assistNumber = [];
  MatchScreens screen = MatchScreens.editMatch;

  @override
  void dispose() {
    _nameController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  Future<void> editMatch(bool playerStats) async {
    String name = _nameController.text.trim();
    setState(() {
      nameErrorText = validateEmptyField(name);
    });
    if (pickedSeason == null || pickedSeason == SeasonModel.automaticSeason()) {
      pickedSeason = calculateAutomaticSeason(allSeasons, pickedDate);
    }
    if (nameErrorText.isEmpty) {
      if (await ref.read(matchControllerProvider).editMatch(
          context,
          name,
          pickedDate,
          isHomeChecked,
          (playerList + fanList),
          pickedSeason!.id,
          widget.matchModel!)) {
        if(!playerStats) {
          widget.onButtonConfirmPressed.call();
        }

      }
    }
  }

  void showDeleteConfirmation() {
    var dialog = ConfirmationDialog("opravdu chcete smazat tohoto hráče?", () {
      deleteMatch();
    });
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  Future<void> deleteMatch() async {
    await ref
        .read(matchControllerProvider)
        .deleteMatch(context, widget.matchModel!);
    widget.onButtonConfirmPressed.call();
  }

  void setMatch(MatchModel? match) {
    if (widget.init) {
      _nameController.text = match?.name ?? "";
      pickedDate = match?.date ?? DateTime.now();
      isHomeChecked = match?.home ?? false;
      _calendarController.text = dateTimeToString(pickedDate);
      initSeasonId = match?.seasonId ?? SeasonModel
          .automaticSeason()
          .id;
      initPlayerIdList = match?.playerIdList ?? [];
      widget.init = false;
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
  
  Future<void> editMatchWithPlayerStats() async {
    await editMatch(true);
    await changePlayerStats();
  }

  Future<void> changePlayerStats() async {
    showLoaderSnackBar(context: context);
    for (int i = 0; i < goalNumber.length; i++) {
      if (goalNumber[i] != -1 || assistNumber[i] != -1) {
        if (await addPlayerStats(
            playerStatsList[i].id, playerStatsList[i].player.id,
            goalNumber[i] == -1 ? playerStatsList[i].goalNumber : goalNumber[i],
            assistNumber[i] == -1
                ? playerStatsList[i].assistNumber
                : assistNumber[i]) && writeToFines) {
          await rewriteFinesForPlayer(playerStatsList[i].player.id, goalNumber[i] == -1
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
    widget.onButtonConfirmPressed.call();
  }

  Future<bool> addPlayerStats(String id, String playerId, int goalNumber,
      int assistNumber) async {
    return await ref.read(matchControllerProvider).addPlayerStatsInMatch(
        context, id,
        widget.matchModel!.id, playerId, goalNumber, assistNumber);
  }

  //TODO pokuta gol a hattrick natvrdo
  Future<void> rewriteFinesForPlayer(String playerId, int number) async {
    if (await ref.read(matchControllerProvider).addFinesInMatch(context,
        widget.matchModel!.id, playerId, "ubSjhRc8KThXHo3yIEQc", number)) {}
  }

  @override
  Widget build(BuildContext context) {
    print("playerList");
    print(playerList);
    const double padding = 8.0;
    final size = MediaQuery
        .of(context)
        .size;
    switch (screen) {
      case MatchScreens.editMatch:
        _calendarController.text = dateTimeToString(pickedDate);
        setMatch(widget.matchModel);
        return Scaffold(
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
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: (size.width / 3) - padding,
                            child: CustomText(text: "Vyber sezonu:")),
                        SizedBox(
                          width: (size.width / 1.5) - padding,
                          child: StreamBuilder<List<SeasonModel>>(
                              stream: ref.watch(seasonControllerProvider)
                                  .seasons(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Loader();
                                }
                                List<SeasonModel> seasons = snapshot.data!;
                                allSeasons = snapshot.data!;
                                seasons.add(SeasonModel.otherSeason());

                                seasons.insert(0, SeasonModel
                                    .automaticSeason());

                                return SeasonDropdownButton(
                                  errorText: seasonErrorText,
                                  items: seasons,
                                  seasonId: initSeasonId,
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
                            initPlayers: initPlayerIdList,

                          )
                      ),
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
                              fanList = players;
                            },
                            fan: true,
                            initPlayers: initPlayerIdList,
                          )
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomButton(text: "Potvrď změny", onPressed: () =>  editMatch(false)),
                  CustomButton(text: "Pokračuj k hráčům", onPressed: () => changeScreens(MatchScreens.addGoals)),
                  CustomButton(
                      text: "Smaž zápas", onPressed: showDeleteConfirmation),
                ],
              ),
            ),
          ),
        );
      case MatchScreens.addGoals:
        return Scaffold(
          appBar: const AppBarHeadline(text: "Přidej góly",),
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: StreamBuilder<List<PlayerStatsHelperModel>>(
              stream: ref
                  .watch(matchControllerProvider)
                  .playersStatsInMatch(playerList, widget.matchModel!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                print("playerList gol2");
                print(playerList);
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
                                        print(goalNumber);
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
                      child: CustomButton(text: "Pokračuj k asistencím",
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
          appBar: const AppBarHeadline(text: "Přidej asistence",),
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: StreamBuilder<List<PlayerStatsHelperModel>>(
              stream: ref
                  .watch(matchControllerProvider)
                  .playersStatsInMatch(playerList, widget.matchModel!.id),
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
                      child: CustomButton(text: "Uprav zápas a statistiky",
                          onPressed: () => editMatchWithPlayerStats()),
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