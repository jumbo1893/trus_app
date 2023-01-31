
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/rows/row_calendar.dart';
import 'package:trus_app/common/widgets/rows/row_switch.dart';
import 'package:trus_app/common/widgets/rows/row_text_field.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/custom_text.dart';
import '../../../common/widgets/dropdown/player_dropdown_multiselect.dart';
import '../../../common/widgets/dropdown/season_dropdown_button.dart';
import '../../../common/widgets/loader.dart';
import '../../season/controller/season_controller.dart';
import '../../season/utils/season_calculator.dart';

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
  final _nameController = TextEditingController();
  final _calendarController = TextEditingController();
  String nameErrorText = "";
  String seasonErrorText = "";

  DateTime pickedDate = DateTime.now();
  bool isHomeChecked = false;
  SeasonModel? pickedSeason;
  List<String> playerList = [];
  List<String> fansList = [];
  List<SeasonModel> allSeasons = [];

  @override
  void dispose() {
    _nameController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  Future<void> addMatch() async {
    String name = _nameController.text.trim();
    setState(() {
      nameErrorText = validateEmptyField(name);
    });
    if(pickedSeason == null || pickedSeason == SeasonModel.automaticSeason()) {
      pickedSeason = calculateAutomaticSeason(allSeasons, pickedDate);
    }
    if (nameErrorText.isEmpty) {
      if (await ref.read(matchControllerProvider).addMatch(
          context,
          name,
          pickedDate,
          isHomeChecked,
          (playerList+fansList),
          pickedSeason!.id)) {
        widget.onAddMatchPressed.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _calendarController.text = dateTimeToString(pickedDate);
    const double padding = 8.0;
    final size = MediaQuery.of(context).size;
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
                      initPlayers: const [],

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
                        onPlayersSelected: (players) {fansList = players;},
                        fan: true,
                        initPlayers: const [],
                      )
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomButton(text: "Přidej zápas", onPressed: addMatch)
            ],
          ),
        ),
      ),
    );
  }
}
