import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/general/confirm_operations.dart';
import 'package:trus_app/models/api/interfaces/confirm_to_string.dart';

import '../../../features/general/error/api_executor.dart';
import '../../utils/utils.dart';

class ConfirmButton extends StatefulWidget {
  final String text;
  final BuildContext context;
  final VoidCallback onOperationComplete;
  final ConfirmOperations confirmOperations;
  final VoidCallback backToMainMenu;
  final int id;

  const ConfirmButton({
    Key? key,
    required this.text,
    required this.context,
    required this.confirmOperations,
    required this.onOperationComplete,
    required this.backToMainMenu,
    required this.id,
  }) : super(key: key);



  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
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
    ConfirmToString? response = await executeApi<ConfirmToString>(() async {
      return await widget.confirmOperations.addModel(widget.id);
    },() => widget.backToMainMenu.call(), context, false);
    if (response != null) {
      showSnackBar(context: widget.context, content: response.toStringForSnackBar());
      widget.onOperationComplete();
    }
    setState(() {
      _isLoading = false;
    });
  }
}
