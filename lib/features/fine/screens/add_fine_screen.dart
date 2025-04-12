import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';

import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/rows/crud/row_text_field_stream.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../../main/screen_controller.dart';
import '../controller/fine_controller.dart';

class AddFineScreen extends CustomConsumerStatefulWidget {
  static const String id = "add-fine-screen";

  const AddFineScreen({
    Key? key,
  }) : super(key: key, title: "Přidat pokutu", name: id);

  @override
  ConsumerState<AddFineScreen> createState() => _AddFineScreenState();
}

class _AddFineScreenState extends ConsumerState<AddFineScreen> {
  @override
  Widget build(BuildContext context) {
    if (ref.read(screenControllerProvider).isScreenFocused(AddFineScreen.id)) {
      const double padding = 8.0;
      final size =
          MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      return ColumnFutureBuilder(
        loadModelFuture: ref.watch(fineControllerProvider).newFine(),
        columns: [
          RowTextFieldStream(
            key: const ValueKey('fine_name_field'),
            size: size,
            labelText: "název",
            textFieldText: "Název pokuty:",
            padding: padding,
            stringControllerMixin: ref.watch(fineControllerProvider),
            hashKey: ref.read(fineControllerProvider).nameKey,
          ),
          const SizedBox(height: 10),
          RowTextFieldStream(
            key: const ValueKey('fine_amount_field'),
            size: size,
            labelText: "v Kč",
            textFieldText: "Výše pokuty:",
            padding: padding,
            stringControllerMixin: ref.watch(fineControllerProvider),
            hashKey: ref.read(fineControllerProvider).amountKey,
            number: true,
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          CrudButton(
            key: const ValueKey('confirm_button'),
            text: "Potvrď",
            context: context,
            crud: Crud.create,
            crudOperations: ref.read(fineControllerProvider),
            onOperationComplete: (id) {
              ref.read(screenControllerProvider).changeFragment(FineScreen.id);
            },
          )
        ],
        loadingScreen: null,
      );
    } else {
      return Container();
    }
  }
}
