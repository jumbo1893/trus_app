import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/rows/row_switch.dart';
import 'package:trus_app/common/widgets/rows/row_warning_text.dart';
import 'package:trus_app/features/fine/controller/fine_edit_notifier.dart';
import 'package:trus_app/features/fine/controller/fine_notifier.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';

import '../../../common/widgets/button/simple_crud_button.dart';
import '../../../common/widgets/notifier/loader/loading_overlay.dart';
import '../../../common/widgets/rows/row_text_field.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';

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
    final fine = ref.watch(fineNotifierProvider).selectedFine;
    final state = ref.watch(fineEditProvider(fine));
    final notifier = ref.read(fineEditProvider(fine).notifier);
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
              RowSwitch(
                textFieldText: "Pouze pro nově udělené pokuty?",
                value: state.inactive,
                onChanged: notifier.setInactive,
              ),
              const SizedBox(
                height: 20,
              ),
              const RowWarningText(
                  text:
                      "Dbejte na to, že pokud je tento přepínač vypnutý, tak se změní všechny pokuty i retrospektivně - tedy částka či jméno se změní i pro již udělené pokuty z předchozích zápasů.\n"
                      "Pokud si přejete udělat změny pouze pro nové pokuty, přepněte do přepínač do true"),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              SimpleCrudButton(
                onPressed: () async => await notifier.submit(
                    "Ukládám pokutu...",
                    "Pokuta byla úspěšně uložena",
                    FineScreen.id,
                    Crud.update,
                    fineNotifierProvider),
                text: "Potvrď změny",
              ),
              const SizedBox(height: 10),
              SimpleCrudButton(
                onPressed: () async => await notifier.submit(
                    "Mažu pokutu...",
                    "Pokutu byla úspěšně smazána",
                    FineScreen.id,
                    Crud.delete,
                    fineNotifierProvider),
                text: "Smaž pokutu",
                deleteConfirmationText:
                    "Opravdu chcete smazat pokutu ${state.model?.name}?",
              ),
            ],
          ),
        ));
  }
}
