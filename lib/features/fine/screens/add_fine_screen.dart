
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/rows/row_calendar.dart';
import 'package:trus_app/common/widgets/rows/row_text_field.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/utils/field_validator.dart';
import '../../notification/controller/notification_controller.dart';
import '../controller/fine_controller.dart';

class AddFineScreen extends ConsumerStatefulWidget {
  final VoidCallback onAddFinePressed;
  const AddFineScreen({
    Key? key,
    required this.onAddFinePressed,
  }) : super(key: key);

  @override
  ConsumerState<AddFineScreen> createState() => _AddFineScreenState();
}

class _AddFineScreenState extends ConsumerState<AddFineScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String nameErrorText = "";
  String amountErrorText = "";

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> addFine() async {
    String name = _nameController.text.trim();
    String amount = _amountController.text.trim();
    setState(() {
      nameErrorText = validateEmptyField(name);
      amountErrorText = validateAmountField(amount);
    });
    if (nameErrorText.isEmpty && amountErrorText.isEmpty) {
      if (await ref
          .read(fineControllerProvider)
          .addFine(context, name, int.parse(amount))) {
        await sendNotification(name, "ve výši $amount Kč");
        widget.onAddFinePressed.call();
      }
    }
  }

  Future<void> sendNotification(String fine, String text) async {
    if(text.isNotEmpty) {
      String title = "Přidána pokuta $fine";
      await ref.read(notificationControllerProvider).addNotification(
          context, title, text);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  textFieldText: "Název pokuty:"),
              const SizedBox(height: 10),
              RowTextField(
                  size: size,
                  padding: padding,
                  textController: _amountController,
                  errorText: amountErrorText,
                  number: true,
                  labelText: "v Kč",
                  textFieldText: "Výše pokuty:"),
              const SizedBox(height: 10),
              CustomButton(text: "Přidej pokutu", onPressed: addFine)
            ],
          ),
        ),
      ),
    );
  }
}
