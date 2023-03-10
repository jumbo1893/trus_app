import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/rows/row_text_field.dart';

import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/confirmation_dialog.dart';
import '../../../models/fine_model.dart';
import '../../notification/controller/notification_controller.dart';
import '../controller/fine_controller.dart';

class EditFineScreen extends ConsumerStatefulWidget {
  final VoidCallback onButtonConfirmPressed;
  final FineModel? fineModel;
  bool init;
  EditFineScreen(
    this.fineModel, {
    Key? key,
    this.init = true,
    required this.onButtonConfirmPressed,
  }) : super(key: key);

  @override
  ConsumerState<EditFineScreen> createState() => _EditFineScreenState();
}

class _EditFineScreenState extends ConsumerState<EditFineScreen> {
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

  Future<void> editFine() async {
    String name = _nameController.text.trim();
    String amount = _amountController.text.trim();
    setState(() {
      nameErrorText = validateEmptyField(name);
      amountErrorText = validateAmountField(amount);
    });
    if (nameErrorText.isEmpty && amountErrorText.isEmpty) {
      if (await ref
          .read(fineControllerProvider)
          .editFine(context, name, int.parse(amount), widget.fineModel!)) {
        await sendNotification("Upravena pokuta $name", "na výši $amount Kč");
        widget.onButtonConfirmPressed.call();
      }
    }
  }

  void showDeleteConfirmation() {
    var dialog = ConfirmationDialog("opravdu chcete smazat tuto pokutu?", () {
      deleteFine();
    });
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  Future<void> deleteFine() async {
    final String name = widget.fineModel!.name;
    final String amount = widget.fineModel!.amount.toString();
    await ref
        .read(fineControllerProvider)
        .deleteFine(context, widget.fineModel!);
    await sendNotification("Smazána pokuta $name", "v původní výši $amount Kč");
    widget.onButtonConfirmPressed.call();
  }

  Future<void> sendNotification(String title, String text) async {
    if(text.isNotEmpty) {
      await ref.read(notificationControllerProvider).addNotification(
          context, title, text);
    }
  }

  void setFine(FineModel? fineModel) {
    if (widget.init) {
      _nameController.text = fineModel?.name ?? "";
      _amountController.text = fineModel?.amount.toString() ?? "";
      widget.init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;
    final size = MediaQuery.of(context).size;
    setFine(widget.fineModel);
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
              RowTextField(
                  size: size,
                  padding: padding,
                  textController: _amountController,
                  errorText: amountErrorText,
                  number: true,
                  labelText: "v Kč",
                  textFieldText: "Výše pokuty:"),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              CustomButton(text: "Potvrď změny", onPressed: editFine),
              CustomButton(
                  text: "Smaž pokutu", onPressed: showDeleteConfirmation)
            ],
          ),
        ),
      ),
    );
  }
}
