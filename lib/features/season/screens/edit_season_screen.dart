
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/rows/row_calendar.dart';
import 'package:trus_app/common/widgets/rows/row_switch.dart';
import 'package:trus_app/common/widgets/rows/row_text_field.dart';
import 'package:trus_app/features/season/controller/season_controller.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/confirmation_dialog.dart';
import '../../../models/season_model.dart';

class EditSeasonScreen extends ConsumerStatefulWidget {
  final VoidCallback onButtonConfirmPressed;
  final SeasonModel? seasonModel;
  bool init;
  EditSeasonScreen(
      this.seasonModel, {
    Key? key,
    this.init = true,
    required this.onButtonConfirmPressed,
  }) : super(key: key);

  @override
  ConsumerState<EditSeasonScreen> createState() => _EditSeasonScreenState();
}

class _EditSeasonScreenState extends ConsumerState<EditSeasonScreen> {
  final _nameController = TextEditingController();
  final _calendarFromController = TextEditingController();
  final _calendarToController = TextEditingController();
  String nameErrorText = "";
  String calendarFromErrorText = "";
  String calendarToErrorText = "";

  DateTime pickedDateFrom = DateTime.now();
  DateTime pickedDateTo = DateTime.now();

  List<SeasonModel> allSeasons = [];
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> readSeasonsFromDB() async {
    allSeasons = await ref.read(seasonControllerProvider).seasons().first;
  }

  Future<void> editSeason() async {
    String name = _nameController.text.trim();
    setState(() {
      nameErrorText = validateEmptyField(name);
      calendarFromErrorText = validateSeasons(allSeasons, pickedDateFrom, pickedDateTo, widget.seasonModel);
    });
    if (nameErrorText.isEmpty && calendarFromErrorText.isEmpty) {
      if (await ref.read(seasonControllerProvider).editSeason(
          context, name, pickedDateFrom, pickedDateTo, widget.seasonModel!)) {
        widget.onButtonConfirmPressed.call();
      }
    }
  }

  void showDeleteConfirmation() {
    var dialog = ConfirmationDialog("opravdu chcete smazat tohoto hráče?", () { deleteSeason();});
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  Future<void> deleteSeason() async {
    await ref
        .read(seasonControllerProvider)
        .deleteSeason(context, widget.seasonModel!);
    widget.onButtonConfirmPressed.call();
  }

  void setSeason(SeasonModel? season) {
    if (widget.init) {
      _nameController.text = season?.name ?? "";
      pickedDateTo = season?.toDate ?? DateTime.now();
      pickedDateFrom = season?.fromDate ?? DateTime.now();
      _calendarFromController.text = dateTimeToString(pickedDateFrom);
      _calendarToController.text = dateTimeToString(pickedDateTo);
      widget.init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    readSeasonsFromDB();
    const double padding = 8.0;
    final size = MediaQuery.of(context).size;
    setSeason(widget.seasonModel);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(padding),
        child: SafeArea(
          child: Column(
            children: [
              RowTextField(
                  size: size,
                  padding: padding,
                  textController: _nameController,
                  errorText: nameErrorText,
                  labelText: "název",
                  textFieldText: "Název sezony:"),
              const SizedBox(height: 10),
              RowCalendar(
                pickedDate: pickedDateFrom,
                size: size,
                padding: padding,
                errorText: calendarFromErrorText,
                calendarController: _calendarFromController,
                textFieldText: "Začátek sezony",
                onDateChanged: (date) {
                  setState(() => pickedDateFrom = date);
                },
              ),
              const SizedBox(height: 10),
              RowCalendar(
                pickedDate: pickedDateTo,
                size: size,
                padding: padding,
                errorText: calendarToErrorText,
                calendarController: _calendarToController,
                textFieldText: "Konec sezony",
                onDateChanged: (date) {
                  setState(() => pickedDateTo = date);
                },
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              CustomButton(text: "Potvrď změny", onPressed: editSeason),
              CustomButton(text: "Smaž sezonu", onPressed: showDeleteConfirmation)
            ],
          ),
        ),
      ),
    );
  }
}
