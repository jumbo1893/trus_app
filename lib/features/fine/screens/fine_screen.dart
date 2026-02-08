import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/controller/fine_notifier.dart';
import 'package:trus_app/features/fine/screens/add_fine_screen.dart';

import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../main/screen_controller.dart';

class FineScreen extends CustomConsumerWidget {
  static const String id = "fine-screen";

  const FineScreen({
    Key? key,
  }) : super(key: key, title: "Pokuty", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ModelToStringListview(
              state: ref.watch(fineNotifierProvider),
              notifier: ref.read(fineNotifierProvider.notifier)),
        ),
        floatingActionButton: FloatingActionButton(
          key: const ValueKey('add_fine_floating_button'),
          onPressed: () => ref
              .read(screenControllerProvider)
              .changeFragment(AddFineScreen.id),
          elevation: 4.0,
          child: const Icon(Icons.add),
        ));
  }
}
