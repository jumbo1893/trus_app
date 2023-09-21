import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder_with_pkfl.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/rows/stream/row_calendar_stream.dart';
import '../../../common/widgets/rows/stream/row_player_list_stream.dart';
import '../../../common/widgets/rows/stream/row_season_stream.dart';
import '../../../common/widgets/rows/stream/row_switch_stream.dart';
import '../../../common/widgets/rows/stream/row_text_field_stream.dart';
import '../../../models/enum/crud.dart';

class AddMatchScreen extends ConsumerStatefulWidget {
  final VoidCallback onAddMatchPressed;
  final Function(int id) setMatchId;
  final VoidCallback onChangePlayerGoalsPressed;
  final VoidCallback backToMainMenu;
  final bool isFocused;
  const AddMatchScreen({
    Key? key,
    required this.onAddMatchPressed,
    required this.isFocused,
    required this.setMatchId,
    required this.onChangePlayerGoalsPressed,
    required this.backToMainMenu,
  }) : super(key: key);

  @override
  ConsumerState<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends ConsumerState<AddMatchScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      const double padding = 8.0;
      final size =
          MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
      return FutureBuilder<void>(
          future: ref.watch(matchControllerProvider).setupNewMatch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            } else if (snapshot.hasError) {
              Future.delayed(
                  Duration.zero,
                  () => showErrorDialog(snapshot.error!.toString(),
                      widget.onAddMatchPressed, context));
              return const Loader();
            }
            return ColumnFutureBuilderWithPkfl(
              loadModelFuture: ref.watch(matchControllerProvider).newMatch(),
              loadingScreen: null,
              pkflMatchFuture:
                  ref.watch(matchControllerProvider).getLastPkflMatch(),
              onPkflConfirmClick: () =>
                  ref.read(matchControllerProvider).setFieldsByPkflMatch(),
              backToMainMenu: () => widget.backToMainMenu(),
              columns: [
                RowTextFieldStream(
                  size: size,
                  labelText: "jméno",
                  textFieldText: "Jméno soupeře:",
                  padding: padding,
                  textStream: ref.watch(matchControllerProvider).name(),
                  errorTextStream:
                      ref.watch(matchControllerProvider).nameErrorText(),
                  onTextChanged: (name) =>
                      {ref.watch(matchControllerProvider).setName(name)},
                ),
                const SizedBox(height: 10),
                RowCalendarStream(
                  size: size,
                  padding: padding,
                  textFieldText: "Datum zápasu:",
                  onDateChanged: (date) {
                    ref.watch(matchControllerProvider).setDate(date);
                  },
                  dateStream: ref.watch(matchControllerProvider).date(),
                ),
                const SizedBox(height: 10),
                RowSwitchStream(
                  size: size,
                  padding: padding,
                  textFieldText: "domácí zápas?",
                  stream: ref.watch(matchControllerProvider).home(),
                  onChecked: (fan) {
                    ref.watch(matchControllerProvider).setHome(fan);
                  },
                ),
                const SizedBox(height: 10),
                RowSeasonStream(
                  size: size,
                  padding: padding,
                  seasonList: ref.watch(matchControllerProvider).seasonList(),
                  pickedSeason: ref.watch(matchControllerProvider).season(),
                  onSeasonChanged: (season) {
                    ref.watch(matchControllerProvider).setSeason(season);
                  },
                ),
                const SizedBox(height: 10),
                RowPlayerListStream(
                  size: size,
                  padding: padding,
                  playerList: ref.watch(matchControllerProvider).playerList(),
                  checkedPlayerList:
                      ref.watch(matchControllerProvider).checkedPlayers(),
                  textFieldText: "Vyber hráče",
                  errorTextStream:
                      ref.watch(matchControllerProvider).playerErrorText(),
                  initData: () =>
                      ref.watch(matchControllerProvider).initCheckedPlayers(),
                  onPlayersChanged: (players) {
                    ref.watch(matchControllerProvider).setPlayers(players);
                  },
                ),
                const SizedBox(height: 10),
                RowPlayerListStream(
                  size: size,
                  padding: padding,
                  playerList: ref.watch(matchControllerProvider).fanList(),
                  checkedPlayerList:
                      ref.watch(matchControllerProvider).checkedFans(),
                  textFieldText: "Vyber fanoušky",
                  initData: () =>
                      ref.watch(matchControllerProvider).initCheckedFans(),
                  onPlayersChanged: (players) {
                    ref.watch(matchControllerProvider).setFans(players);
                  },
                ),
                const SizedBox(height: 10),
                CrudButton(
                  text: "Potvrď",
                  context: context,
                  crud: Crud.create,
                  crudOperations: ref.read(matchControllerProvider),
                  onOperationComplete: (id) {
                    widget.setMatchId(id);
                    widget.onAddMatchPressed();
                  },
                  backToMainMenu: () => widget.backToMainMenu(),
                ),
                CrudButton(
                  text: "Potvrď a přejdi ke gólům",
                  context: context,
                  crud: Crud.create,
                  crudOperations: ref.read(matchControllerProvider),
                  onOperationComplete: (id) {
                    widget.setMatchId(id);
                    widget.onChangePlayerGoalsPressed();
                  },
                  backToMainMenu: () => widget.backToMainMenu(),
                ),
              ],
            );
          });
      /*return FutureBuilder<PkflMatch?>(
            future: appBarVisibility ? ref.read(matchControllerProvider).getLastPkflMatch() : null,
            builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                var pkflMatch = snapshot.data;
                if(pkflMatch == null) {
                  //appBarVisibility = false;
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
                        const SizedBox(height: 10),
                        CustomButton(
                            text: "Přidej zápas",
                            onPressed: () => {}),
                        CustomButton(
                            text: "Pokračuj k hráčům",
                            onPressed: () => {})
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
        );*/
      //}
    } else {
      return Container();
    }
  }
}
