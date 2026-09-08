import '../../../common/widgets/entry_draft_scope.dart';
import '../../../common/widgets/match_context_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/builder/add_list_builder.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/goal/controller/goal_notifier.dart';
import 'package:trus_app/features/goal/goal_screens.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../../../common/widgets/back_handler_listener.dart';

class GoalScreen extends CustomConsumerStatefulWidget {
  static const String id = "goal-screen";

  const GoalScreen({Key? key})
    : super(key: key, title: "Přidání gólů/asistencí", name: id);

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  bool _initDone = false;

  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;

    final sc = ref.read(screenVariablesNotifierProvider);
    final matchId = sc.matchId;

    final state = ref.watch(goalNotifierProvider);
    final notifier = ref.read(goalNotifierProvider.notifier);

    // init jen jednou pro daný fokus
    if (!_initDone && matchId != null) {
      _initDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.setupMatch(matchId);
      });
    }

    return EntryDraftScope(
      key: ValueKey(notifier.draftId),
      screenId: GoalScreen.id,
      draftId: notifier.draftId,
      loaded: state.matchId > 0,
      values: notifier.draftValues,
      baseline: notifier.draftBaseline,
      labels: {
        for (final g in state.setups) ...{
          '${g.player.id}:g': '${g.player.name} · góly',
          '${g.player.id}:a': '${g.player.name} · asistence',
        },
        'rewrite': 'Přepočítat pokuty',
      },
      hasChanges: () => notifier.hasChanges,
      restore: notifier.restoreDraft,
      save: () => notifier.changeGoals(navigate: false),
      child: BackHandlerListener(
        provider: goalNotifierProvider,
        backActionBuilder: (ref) => ref.read(goalNotifierProvider.notifier),
        child: Column(
          children: [
            if (sc.matchModel.id == matchId)
              MatchContextHeader(match: sc.matchModel),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                state.screen == GoalScreens.addGoals
                    ? '1/2 · Góly — uložíš po asistencích'
                    : '2/2 · Asistence',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: AddListBuilder(
                /*appBarText: state.screen == GoalScreens.addGoals
                  ? "Přidej góly"
                  : "Přidej asistence",*/
                goal: state.screen == GoalScreens.addGoals,
                /*onBackButtonPressed: state.screen == GoalScreens.addAssists
                  ? notifier.navigateToGoalScreen
                  : null,*/
                items: state.setups,
                onAdd: (index) => notifier.addNumber(
                  index,
                  state.screen == GoalScreens.addGoals,
                ),
                onRemove: (index) => notifier.removeNumber(
                  index,
                  state.screen == GoalScreens.addGoals,
                ),
              ),
            ),
            if (state.screen == GoalScreens.addGoals) ...[
              Padding(
                padding: const EdgeInsets.all(padding),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Přepočítat pokuty za góly a hattricky',
                            ),
                          ),
                          IconButton(
                            tooltip: 'Jak se přepočítají pokuty',
                            icon: const Icon(Icons.info_outline),
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Přepočet pokut'),
                                content: const SingleChildScrollView(
                                  child: Text(
                                    'Při uložení se stávající pokuty za góly a hattricky v tomto zápase nahradí podle zadaných gólů. Za každý gól vznikne pokuta střelci. Za každé tři góly jednoho střelce vznikne pokuta za hattrick ostatním aktivním hráčům týmu. Asistence ani ostatní druhy pokut se tím nemění.',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Rozumím'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: state.rewriteToFines,
                      onChanged: notifier.setRewriteToFines,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CustomButton(
                  text: "Pokračuj k asistencím",
                  onPressed: notifier.navigateToAssistScreen,
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Celkem ${state.setups.fold<int>(0, (n, g) => n + g.goalNumber)} gólů · ${state.setups.fold<int>(0, (n, g) => n + g.assistNumber)} asistencí. ${state.rewriteToFines ? "Přepočítají se pokuty za góly a ${state.setups.fold<int>(0, (n, g) => n + g.goalNumber ~/ 3)} hattricků." : "Pokuty se nezmění."}',
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CustomButton(
                  text: "Uložit góly a asistence",
                  onPressed: notifier.changeGoals,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
