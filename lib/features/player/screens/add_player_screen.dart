
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/rows/row_calendar.dart';
import 'package:trus_app/common/widgets/rows/row_switch.dart';
import 'package:trus_app/common/widgets/rows/row_text_field.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/utils/field_validator.dart';
import '../controller/player_controller.dart';

class AddPlayerScreen extends ConsumerStatefulWidget {
  final VoidCallback onAddPlayerPressed;
  const AddPlayerScreen({
    Key? key,
    required this.onAddPlayerPressed,
  }) : super(key: key);

  @override
  ConsumerState<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends ConsumerState<AddPlayerScreen> {
  final _nameController = TextEditingController();
  final _calendarController = TextEditingController();
  String nameErrorText = "";

  DateTime pickedDate = DateTime.now();
  bool isFanChecked = false;
  bool isActiveChecked = true;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> addPlayer() async {
    String name = _nameController.text.trim();
    setState(() {
      nameErrorText = validateEmptyField(name);
    });
    if (nameErrorText.isEmpty) {
      if (await ref
          .read(playerControllerProvider)
          .addPlayer(context, name, pickedDate, isFanChecked, isActiveChecked)) {
        widget.onAddPlayerPressed.call();
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
              CustomButton(text: "Přidej hráče", onPressed: addPlayer)
            ],
          ),
        ),
      ),
    );
  }
}
