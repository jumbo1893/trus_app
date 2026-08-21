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
        if (footballState.weather.trim().isNotEmpty)
        FormFieldWrapper(
          label: "Počasí",
          child: AppReadOnlyField(
            value: footballState.weather,
            allowWrap: true,
          ),
        ),
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
        if (footballState.homeBestPlayer.trim().isNotEmpty)
        FormFieldWrapper(
          label: "Hvězda zápasu domácích",
          child: AppReadOnlyField(
            value: footballState.homeBestPlayer,
            allowWrap: true,
          ),
        ),
        if (footballState.awayBestPlayer.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Hvězda zápasu hostů",
            child: AppReadOnlyField(
              value: footballState.awayBestPlayer,
              allowWrap: true,
            ),
          ),
        if (footballState.homeGoalScorers.trim().isNotEmpty)
          FormFieldWrapper(
          label: "Střelci domácích",
          child: AppReadOnlyField(
            value: footballState.homeGoalScorers,
            allowWrap: true,
          ),
        ),
        if (footballState.awayGoalScorers.trim().isNotEmpty)
          FormFieldWrapper(
          label: "Střelci hostů",
          child: AppReadOnlyField(
            value: footballState.awayGoalScorers,
            allowWrap: true,
          ),
        ),
        if (footballState.homeOwnGoals.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Vlastňáky domácích",
            child: AppReadOnlyField(
              value: footballState.homeOwnGoals,
              allowWrap: true,
            ),
          ),
        if (footballState.awayOwnGoals.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Vlastňáky hostů",
            child: AppReadOnlyField(
              value: footballState.awayOwnGoals,
              allowWrap: true,
            ),
          ),
        if (footballState.homeYellowCards.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Žluté domácích",
            child: AppReadOnlyField(
              value: footballState.homeYellowCards,
              allowWrap: true,
            ),
          ),
        if (footballState.awayYellowCards.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Žluté hostů",
            child: AppReadOnlyField(
              value: footballState.awayYellowCards,
              allowWrap: true,
            ),
          ),
        if (footballState.homeRedCards.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Červené domácích",
            child: AppReadOnlyField(
              value: footballState.homeRedCards,
              allowWrap: true,
            ),
          ),
        if (footballState.awayRedCards.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Červené hostů",
            child: AppReadOnlyField(
              value: footballState.awayRedCards,
              allowWrap: true,
            ),
          ),
      ],
      actions: const [],
      padding: const EdgeInsets.only(bottom: 24),
    );
  }
}