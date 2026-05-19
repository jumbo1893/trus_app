import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/rows/app_read_only_field.dart';
import 'package:trus_app/common/widgets/rows/form/form_field_wrapper.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../controller/edit/match_edit_notifier.dart';
import '../match_notifier_args.dart';

class FootballMatchDetailScreen extends ConsumerStatefulWidget {
  const FootballMatchDetailScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<FootballMatchDetailScreen> createState() =>
      _FootballMatchDetailScreenState();
}

class _FootballMatchDetailScreenState
    extends ConsumerState<FootballMatchDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final MatchNotifierArgs arg =
        ref.read(screenVariablesNotifierProvider).matchNotifierArgs;

    final state = ref.watch(matchEditNotifierProvider(arg));
    final footballState = state.footballMatchDetailState;

    return BaseFormScreen(
      headerTitle: footballState.nameAndResult,
      headerText: footballState.dateAndLeague,
      fields: [
        FormFieldWrapper(
          label: "Stadion",
          child: AppReadOnlyField(
            value: footballState.stadium,
            allowWrap: true,
          ),
        ),
        FormFieldWrapper(
          label: "Rozhodčí",
          child: AppReadOnlyField(
            value: footballState.referee,
            allowWrap: true,
          ),
        ),
        if (footballState.refereeComment.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Komentář rozhodčího",
            child: AppReadOnlyField(
              value: footballState.refereeComment,
              allowWrap: true,
            ),
          ),
      ],
      actions: const [],
      padding: const EdgeInsets.only(bottom: 24),
    );
  }
}