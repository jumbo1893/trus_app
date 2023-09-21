import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/general/crud_operations.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../features/general/error/api_executor.dart';
import '../../../models/enum/crud.dart';
import '../../utils/utils.dart';
import '../confirmation_dialog.dart';

class CrudButton extends StatefulWidget {
  final String text;
  final Crud crud;
  final CrudOperations crudOperations;
  final BuildContext context;
  final Function(int) onOperationComplete;
  final VoidCallback backToMainMenu;
  final int? id;
  final ModelToString? modelToString;

  const CrudButton({
    Key? key,
    required this.text,
    required this.context,
    required this.crud,
    required this.crudOperations,
    required this.onOperationComplete,
    required this.backToMainMenu,
    this.id,
    this.modelToString,
  }) : super(key: key);



  @override
  State<CrudButton> createState() => _CrudButtonState();
}

class _CrudButtonState extends State<CrudButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
          minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: const BorderSide(color: Colors.orange),
            ),
          ),
        ),
        child: _isLoading
            ? const Loader() // Loader widget
            : Text(
          widget.text,
          style: const TextStyle(
            color: blackColor,
          ),
        ),
      ),
    );
  }

  Future<void> onPressed() async {
    setState(() {
      _isLoading = true;
    });
    switch (widget.crud) {
      case Crud.create:
        ModelToString? response = await executeApi<ModelToString?>(() async {
          return await widget.crudOperations.addModel();
        },() => widget.backToMainMenu.call(), context, false);
        if (response != null) {
          showSnackBar(
            context: widget.context,
            content: response.toStringForAdd(),
          );
          widget.onOperationComplete.call(response.getId());
        }
        break;
      case Crud.read:
      // TODO: Handle this case.
        break;
      case Crud.update:
        String? response = await executeApi<String?>(() async {
          return await widget.crudOperations.editModel(widget.id!);
        },() => widget.backToMainMenu.call(), context, false);
        if (response != null) {
          showSnackBar(context: widget.context, content: response);
          widget.onOperationComplete.call(widget.id!);
        }
        break;
      case Crud.delete:
        var dialog = ConfirmationDialog(
          widget.modelToString?.toStringForConfirmationDelete() ?? "Opravdu chcete smazat?",
              () {
            deleteModel();
          },
        );
        showDialog(
          context: widget.context,
          builder: (BuildContext context) => dialog,
        );
        break;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> deleteModel() async {
    String? response = await executeApi<String?>(() async {
      return await widget.crudOperations.deleteModel(widget.id!);
    },() => widget.backToMainMenu.call(), context, false);
    if(response != null) {
      showSnackBar(context: context, content: response);
      widget.onOperationComplete.call(widget.id!);
    }
  }
}
