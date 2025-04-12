import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/screens/add_fine_screen.dart';
import 'package:trus_app/features/fine/screens/edit_fine_screen.dart';

import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../../models/api/fine_api_model.dart';
import '../../main/screen_controller.dart';
import '../controller/fine_controller.dart';

class FineScreen extends CustomConsumerWidget {
  static const String id = "fine-screen";

  const FineScreen({
    Key? key,
  }) : super(key: key, title: "Pokuty", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(screenControllerProvider).isScreenFocused(FineScreen.id)) {
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ModelsErrorFutureBuilder(
              key: const ValueKey('fine_list'),
              future: ref.watch(fineControllerProvider).getModels(),
              onPressed: (fine) => {
                ref
                    .read(screenControllerProvider)
                    .setFine(fine as FineApiModel),
                ref
                    .read(screenControllerProvider)
                    .changeFragment(EditFineScreen.id)
              },
              context: context,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => ref
                .read(screenControllerProvider)
                .changeFragment(AddFineScreen.id),
            elevation: 4.0,
            child: const Icon(Icons.add),
          ));
    } else {
      return Container();
    }
  }
}
