import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/widgets/bar/action_button_item.dart';
import '../../../common/widgets/bottomsheet/confirm_action_bottom_sheet.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../../main/controller/screen_variables_notifier.dart';
import '../controller/edit/match_edit_notifier.dart';
import '../match_form_fields.dart';
import '../post_match_flow.dart';
import 'lineup_confirm_screen.dart';

class EditMatchScreen extends CustomConsumerStatefulWidget {
  static const String id = "edit-match-screen";

  const EditMatchScreen({Key? key})
    : super(key: key, title: "Upravit zápas", name: id);

  @override
  ConsumerState<EditMatchScreen> createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends ConsumerState<EditMatchScreen> {
  @override
  Widget build(BuildContext context) {
    final arg = ref.watch(matchNotifierArgsProvider);
    final notifier = ref.read(matchEditNotifierProvider(arg).notifier);
    final state = ref.watch(matchEditNotifierProvider(arg));
    final enteringResult = ref.watch(postMatchFlowProvider) == arg.matchId;
    // After the match only the lineup and score are confirmed; the rest comes
    // from the planned match and can be edited later.
    if (enteringResult && arg.matchId != null) {
      return LineupConfirmScreen(matchId: arg.matchId!);
    }
    return BaseFormScreen(
      headerTitle: enteringResult ? 'Potvrdit sestavu a výsledek' : state.name,
      headerText: matchDateToString(state.date),
      fields: matchFields(context, state, notifier),
      actions: [
        ActionButtonItem(
          label: enteringResult ? 'Potvrdit a zapsat góly' : 'Uložit zápas',
          onPressed: () => notifier.submitCrud(Crud.update, enteringResult),
          type: ActionButtonType.primary,
        ),
        if (!enteringResult)
          ActionButtonItem(
            label: "Uložit a přidat góly",
            onPressed: () => notifier.submitCrud(Crud.update, true),
            type: ActionButtonType.secondary,
          ),
        ActionButtonItem(
          label: "Smazat",
          onPressed: () {
            ConfirmActionBottomSheet.show(
              context,
              title: "Smazat zápas",
              message: "Opravdu chcete smazat tento zápas?",
              confirmText: "Smazat",
              cancelText: "Zrušit",
              icon: Icons.delete_outline_rounded,
              isDanger: true,
              onConfirm: () async => notifier.submitCrud(Crud.delete, false),
            );
          },
          type: ActionButtonType.danger,
        ),
      ],
    );
  }
}
