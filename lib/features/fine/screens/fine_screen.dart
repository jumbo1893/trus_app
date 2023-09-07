import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/models/fine_model.dart';

import '../../../common/widgets/builder/error_future_builder.dart';
import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../models/api/fine_api_model.dart';
import '../controller/fine_controller.dart';

class FineScreen extends ConsumerWidget {
  final VoidCallback onPlusButtonPressed;
  final VoidCallback backToMainMenu;
  final Function(FineApiModel fineModel) setFine;
  final bool isFocused;
  const FineScreen({
    Key? key,
    required this.onPlusButtonPressed,
    required this.backToMainMenu,
    required this.setFine,
    required this.isFocused,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isFocused) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ModelsErrorFutureBuilder(
            future: ref.watch(fineControllerProvider).getModels(),
            onPressed: (fine) => {setFine(fine as FineApiModel)},
            onDialogCancel: () => backToMainMenu.call(),
            context: context,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onPlusButtonPressed,
          elevation: 4.0,
          child: const Icon(Icons.add),
        ));
    }
    else {
      return Container();
    }
  }
}
