import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/models/api/fine_api_model.dart';

import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/rows/stream/row_switch_stream.dart';
import '../../../common/widgets/rows/stream/row_text_field_stream.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../../main/screen_controller.dart';
import '../controller/fine_controller.dart';

class EditFineScreen extends CustomConsumerStatefulWidget {
  static const String id = "edit-fine-screen";

  const EditFineScreen({
    Key? key,
  }) : super(key: key, title: "Upravit pokutu", name: id);

  @override
  ConsumerState<EditFineScreen> createState() => _EditFineScreenState();
}

class _EditFineScreenState extends ConsumerState<EditFineScreen> {
  @override
  Widget build(BuildContext context) {
    if (ref.read(screenControllerProvider).isScreenFocused(EditFineScreen.id)) {
      FineApiModel fine = ref.watch(screenControllerProvider).fineModel;
      const double padding = 8.0;
      final size =
          MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
      return ColumnFutureBuilder(
        loadModelFuture: ref.watch(fineControllerProvider).fine(fine),
        columns: [
          RowTextFieldStream(
            key: const ValueKey('fine_name_field'),
            size: size,
            labelText: "název",
            textFieldText: "Název pokuty:",
            padding: padding,
            textStream: ref.watch(fineControllerProvider).name(),
            errorTextStream: ref.watch(fineControllerProvider).nameErrorText(),
            onTextChanged: (name) =>
                {ref.watch(fineControllerProvider).setName(name)},
          ),
          const SizedBox(height: 10),
          RowTextFieldStream(
            key: const ValueKey('fine_amount_field'),
            size: size,
            labelText: "v Kč",
            textFieldText: "Výše pokuty:",
            padding: padding,
            textStream: ref.watch(fineControllerProvider).amount(),
            errorTextStream:
                ref.watch(fineControllerProvider).amountErrorText(),
            onTextChanged: (amount) =>
                {ref.watch(fineControllerProvider).setAmount(amount)},
            number: true,
          ),
          const SizedBox(height: 10),
          RowSwitchStream(
            key: const ValueKey('fine_switch_field'),
            size: size,
            padding: padding,
            textFieldText: "Pouze pro nově udělené pokuty?",
            stream: ref.watch(fineControllerProvider).inactive(),
            onChecked: (inactive) {
              ref.watch(fineControllerProvider).setInactive(inactive);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              SizedBox(
                  width: size.width / 6,
                  child: const Icon(
                    Icons.warning,
                    color: Colors.black,
                  )),
              SizedBox(
                  width: size.width / 1.3,
                  child: const Text(
                      "Dbejte na to, že pokud je tento přepínač vypnutý, tak se změní všechny pokuty i retrospektivně - tedy částka či jméno se změní i pro již udělené pokuty z předchozích zápasů.\n"
                      "Pokud si přejete udělat změny pouze pro nové pokuty, přepněte do přepínač do true"))
            ],
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          CrudButton(
            key: const ValueKey('confirm_button'),
            text: "Potvrď změny",
            context: context,
            crud: Crud.update,
            crudOperations: ref.read(fineControllerProvider),
            onOperationComplete: (id) {
              ref.read(screenControllerProvider).changeFragment(FineScreen.id);
            },
            id: fine.id!,
          ),
          CrudButton(
            key: const ValueKey('delete_button'),
            text: "Smaž pokutu",
            context: context,
            crud: Crud.delete,
            crudOperations: ref.read(fineControllerProvider),
            onOperationComplete: (id) {
              ref.read(screenControllerProvider).changeFragment(FineScreen.id);
            },
            id: fine.id!,
            modelToString: fine,
          ),
        ],
        loadingScreen: null,
      );
    } else {
      return Container();
    }
  }
}
