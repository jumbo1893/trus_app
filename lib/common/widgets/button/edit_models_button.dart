import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';

import '../../../features/general/error/api_executor.dart';
import '../../../features/home/screens/home_screen.dart';
import '../../../features/main/screen_controller.dart';
import '../../utils/utils.dart';

class EditModelsButton extends ConsumerStatefulWidget {
  final String text;
  final BuildContext context;
  final Function() editModelsFunction;
  final Function() onOperationComplete;
  const EditModelsButton({
    Key? key,
    required this.text,
    required this.context,
    required this.editModelsFunction,
    required this.onOperationComplete
  }) : super(key: key);

  @override
  ConsumerState<EditModelsButton> createState() => _EditModelsButtonState();
}

class _EditModelsButtonState extends ConsumerState<EditModelsButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
          minimumSize:
              WidgetStateProperty.all(const Size(double.infinity, 50)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
    String? response = await executeApi<String?>(() async {
      return await widget.editModelsFunction();
    },
            () => ref
            .read(screenControllerProvider)
            .changeFragment(HomeScreen.id),
        context,
        false);
    if (response != null) {
      showSnackBar(
        context: widget.context,
        content: response,
      );
    }
    setState(() {
      _isLoading = false;
    });
    widget.onOperationComplete.call();
  }
}
