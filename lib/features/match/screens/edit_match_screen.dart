
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
import '../../../common/widgets/confirmation_dialog.dart';
import '../../../common/widgets/custom_text.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/dropdown/player_dropdown_multiselect.dart';
import '../../../common/widgets/dropdown/season_dropdown_button.dart';
import '../../season/controller/season_controller.dart';
import '../../season/utils/season_calculator.dart';

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

  DateTime pickedDate = DateTime.now();
  bool isHomeChecked = false;
  SeasonModel? pickedSeason;
  List<String> fanList = [];
  List<String> playerList = [];
  List<SeasonModel> allSeasons = [];
  List<String> initPlayerIdList = [];
  String? initSeasonId;

  @override
  void dispose() {
    _nameController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  Future<void> editMatch() async {
    String name = _nameController.text.trim();
    setState(() {
      nameErrorText = validateEmptyField(name);
    });
    if(pickedSeason == null || pickedSeason == SeasonModel.automaticSeason()) {
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
        widget.onButtonConfirmPressed.call();
      }
    }
  }

  void showDeleteConfirmation() {
    var dialog = ConfirmationDialog("opravdu chcete smazat tohoto hráče?", () { deleteMatch();});
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
      initSeasonId = match?.seasonId ?? SeasonModel.automaticSeason().id;
      initPlayerIdList = match?.playerIdList ?? [];
      widget.init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _calendarController.text = dateTimeToString(pickedDate);
    const double padding = 8.0;
    final size = MediaQuery.of(context).size;
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                    width: (size.width / 3) - padding,
                    child: const CustomText(text: "Vyber sezonu:")),
                SizedBox(
                  width: (size.width / 1.5) - padding,
                  child: StreamBuilder<List<SeasonModel>>(
                      stream: ref.watch(seasonControllerProvider).seasons(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Loader();
                        }
                        List<SeasonModel> seasons = snapshot.data!;
                        allSeasons = snapshot.data!;
                        seasons.add(SeasonModel.otherSeason());

                        seasons.insert(0, SeasonModel.automaticSeason());

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
                      child: const CustomText(text: "Vyber hráče:")),
                  SizedBox(
                    width: (size.width / 1.5) - padding,
                    child: PlayerDropdownMultiSelect(
                      onPlayersSelected: (players) {playerList = players;},
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
                      child: const CustomText(text: "Vyber fanoušky:")),
                  SizedBox(
                      width: (size.width / 1.5) - padding,
                      child: PlayerDropdownMultiSelect(
                        onPlayersSelected: (players) {fanList = players;},
                        fan: true,
                        initPlayers: initPlayerIdList,
                      )
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomButton(text: "Potvrď změny", onPressed: editMatch),
              CustomButton(text: "Smaž zápas", onPressed: showDeleteConfirmation)
            ],
          ),
        ),
      ),
    );
  }
}
