import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/rows/row_calendar.dart';
import 'package:trus_app/common/widgets/rows/row_switch.dart';
import 'package:trus_app/common/widgets/rows/row_text_field.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/confirmation_dialog.dart';
import '../../notification/controller/notification_controller.dart';
import '../controller/player_controller.dart';

class EditPlayerScreen extends ConsumerStatefulWidget {
  final VoidCallback onButtonConfirmPressed;
  final PlayerModel? playerModel;
  //podle todle booleanu se určují init hodnoty u textcontrolleru. Jinak se to volá několkrát a furt se to mění
  bool init;
  EditPlayerScreen(
    this.playerModel, {
    Key? key,
    this.init = true,
    required this.onButtonConfirmPressed,
  }) : super(key: key);

  @override
  ConsumerState<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends ConsumerState<EditPlayerScreen> {
  final _nameController = TextEditingController();
  final _calendarController = TextEditingController();
  String nameErrorText = "";
  late DateTime pickedDate;
  late bool isFanChecked;
  late bool isActiveChecked;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> editPlayer() async {
    String name = _nameController.text.trim();
    setState(() {
      nameErrorText = validateEmptyField(name);
    });
    if (nameErrorText.isEmpty) {
      if (await ref.read(playerControllerProvider).editPlayer(
          context, name, pickedDate, isFanChecked, isActiveChecked, widget.playerModel!)) {
        await sendNotification("Upraven $name", "${isFanChecked ? "Fanoušek" : "Hráč"} s datem narození: ${dateTimeToString(pickedDate)} Kč");
        widget.onButtonConfirmPressed.call();
      }
    }
  }

  void showDeleteConfirmation() {
    var dialog = ConfirmationDialog("opravdu chcete smazat tohoto hráče?", () { deletePlayer();});
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  Future<void> deletePlayer() async {
    final String name = widget.playerModel!.name;
    final String text = widget.playerModel!.toStringForPlayerList();
    await ref
        .read(playerControllerProvider)
        .deletePlayer(context, widget.playerModel!);
    await sendNotification("Smazán hráč $name", text);
    widget.onButtonConfirmPressed.call();
  }

  Future<void> sendNotification(String title, String text) async {
    if(text.isNotEmpty) {
      await ref.read(notificationControllerProvider).addNotification(
          context, title, text);
    }
  }

  void setPlayer(PlayerModel? player) {
    if (widget.init) {
      _nameController.text = player?.name ?? "";
      pickedDate = player?.birthday ?? DateTime.now();
      isFanChecked = player?.fan ?? false;
      isActiveChecked = player?.isActive ?? false;
      _calendarController.text = dateTimeToString(pickedDate);
      widget.init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;
    final size = MediaQuery.of(context).size;
    setPlayer(widget.playerModel);
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
                  labelText: "jméno",
                  textFieldText: "Jméno hráče:"),
              const SizedBox(height: 10),
              RowCalendar(
                pickedDate: pickedDate,
                size: size,
                padding: padding,
                calendarController: _calendarController,
                textFieldText: "Datum narození:",
                onDateChanged: (date) {
                  setState(() => pickedDate = date);
                },
              ),
              const SizedBox(height: 10),
              RowSwitch(
                size: size,
                padding: padding,
                textFieldText: "fanoušek?",
                initChecked: isFanChecked,
                onChecked: (fan) {
                  setState(() => isFanChecked = fan);
                },
              ),
              const SizedBox(height: 10),
              RowSwitch(
                size: size,
                padding: padding,
                textFieldText: "aktivní?",
                initChecked: isActiveChecked,
                onChecked: (active) {
                  setState(() => isActiveChecked = active);
                },
              ),
              const SizedBox(height: 10),
              CustomButton(text: "Potvrď změny", onPressed: editPlayer),
              CustomButton(text: "Smaž hráče", onPressed: showDeleteConfirmation)
            ],
          ),
        ),
      ),
    );
  }
}
