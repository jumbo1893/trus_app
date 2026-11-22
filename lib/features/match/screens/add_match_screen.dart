import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/match/controller/edit/match_edit_notifier.dart';
import '../../../common/utils/calendar.dart';
import '../../../common/widgets/bar/action_button_item.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../../main/controller/screen_variables_notifier.dart';
import '../match_form_fields.dart';
import '../post_match_flow.dart';

class AddMatchScreen extends CustomConsumerStatefulWidget {
  static const String id = "add-match-screen";

  const AddMatchScreen({Key? key})
    : super(key: key, title: "Přidat zápas", name: id);

  @override
  ConsumerState<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends ConsumerState<AddMatchScreen> {
  @override
  Widget build(BuildContext context) {
    final arg = ref.watch(matchNotifierArgsProvider);
    final notifier = ref.read(matchEditNotifierProvider(arg).notifier);
    final state = ref.watch(matchEditNotifierProvider(arg));
    final enteringResult =
        ref.watch(postMatchFlowProvider) == -1 &&
        arg.footballMatchApiModel?.alreadyPlayed == true;

    return BaseFormScreen(
      headerTitle: enteringResult
          ? 'Potvrdit sestavu a výsledek'
          : "Nový zápas: ${state.name}",
      headerText: "datum: ${matchDateToString(state.date)}",
      fields: matchFields(context, state, notifier),
      actions: [
        ActionButtonItem(
          label: enteringResult ? 'Potvrdit a zapsat góly' : 'Uložit zápas',
          onPressed: () => notifier.submitCrud(Crud.create, enteringResult),
          type: ActionButtonType.primary,
        ),
        if (!enteringResult)
          ActionButtonItem(
            label: "Uložit a přidat góly",
            onPressed: () => notifier.submitCrud(Crud.create, true),
            type: ActionButtonType.secondary,
          ),
      ],
    );
  }
}
