import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/controller/fine_edit_notifier.dart';
import 'package:trus_app/features/fine/controller/fine_notifier.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';

import '../../../common/widgets/button/simple_crud_button.dart';
import '../../../common/widgets/notifier/loader/loading_overlay.dart';
import '../../../common/widgets/rows/row_text_field.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';

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
    final state = ref.watch(fineAddProvider);
    final notifier = ref.read(fineAddProvider.notifier);
    return LoadingOverlay(
        state: state,
        onClearError: notifier.clearErrorMessage,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              RowTextField(
                label: "Název",
                textFieldText: "Název pokuty:",
                value: state.name,
                onChanged: notifier.setName,
                error: state.errors["name"],
              ),
              const SizedBox(height: 10),
              RowTextField(
                label: "v Kč",
                textFieldText: "Výše pokuty:",
                value: state.amount,
                number: true,
                onChanged: notifier.setAmount,
                error: state.errors["amount"],
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              SimpleCrudButton(
                onPressed: () async => await notifier.submit(
                    "Ukládám pokutu...",
                    "Pokuta byla úspěšně uložena",
                    FineScreen.id,
                    Crud.create,
                    fineNotifierProvider),
                text: "Ulož pokutu",
              ),
            ],
          ),
        ));
  }
}
