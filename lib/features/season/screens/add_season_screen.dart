
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/rows/row_calendar.dart';
import 'package:trus_app/common/widgets/rows/row_text_field.dart';
import 'package:trus_app/features/season/controller/season_controller.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/utils/field_validator.dart';
import '../../../models/season_model.dart';
import '../../notification/controller/notification_controller.dart';

class AddSeasonScreen extends ConsumerStatefulWidget {
  final VoidCallback onAddSeasonPressed;
  const AddSeasonScreen({
    Key? key,
    required this.onAddSeasonPressed,
  }) : super(key: key);

  @override
  ConsumerState<AddSeasonScreen> createState() => _AddSeasonScreenState();
}

class _AddSeasonScreenState extends ConsumerState<AddSeasonScreen> {
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

  Future<void> addSeason() async {
    String name = _nameController.text.trim();
    setState(() {
      nameErrorText = validateEmptyField(name);
      calendarFromErrorText = validateSeasons(allSeasons, pickedDateFrom, pickedDateTo, null);
    });
    if (nameErrorText.isEmpty && calendarFromErrorText.isEmpty) {
      if (await ref
          .read(seasonControllerProvider)
          .addSeason(context, name, pickedDateFrom, pickedDateTo)) {
        await sendNotification("Přidána sezona $name", 'Začátek sezony: ${dateTimeToString(pickedDateFrom)}, konec sezony: ${dateTimeToString(pickedDateTo)}');
        widget.onAddSeasonPressed.call();
      }
    }
  }

  Future<void> sendNotification(String season, String text) async {
    if(text.isNotEmpty) {
      String title = "Přidána sezona $season";
      await ref.read(notificationControllerProvider).addNotification(
          context, title, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    readSeasonsFromDB();
    _calendarFromController.text = dateTimeToString(pickedDateFrom);
    _calendarToController.text = dateTimeToString(pickedDateTo);
    const double padding = 8.0;
    final size = MediaQuery.of(context).size;
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
              CustomButton(text: "Přidej sezonu", onPressed: addSeason)
            ],
          ),
        ),
      ),
    );
  }
}
