import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/builder/add_list_builder.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/notifier/loader/loading_overlay.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/goal/controller/goal_notifier.dart';
import 'package:trus_app/features/goal/goal_screens.dart';

import '../../../common/widgets/back_handler_listener.dart';
import '../../main/screen_controller.dart';

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

    final sc = ref.read(screenControllerProvider);
    final matchId = sc.matchId;

    if (!sc.isScreenFocused(GoalScreen.id)) {
      _initDone = false;
      return const SizedBox.shrink();
    }

    final state = ref.watch(goalNotifierProvider);
    final notifier = ref.read(goalNotifierProvider.notifier);

    // init jen jednou pro daný fokus
    if (!_initDone && matchId != null) {
      _initDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.setupMatch(matchId);
      });
    }

    // můžeš si tu zobrazit errorMessage (nebo dělat dialog)
    if (state.loading.isLoading && state.setups.isEmpty) {
      return const Loader();
    }

    return LoadingOverlay(
      state: state,
      // pokud LoadingOverlay vyžaduje BaseCrudState, dej pryč a použij jen Loader
      onClearError: () {},
      child: BackHandlerListener(
        provider: goalNotifierProvider,
        backActionBuilder: (ref) => ref.read(goalNotifierProvider.notifier),
        child: Column(
          children: [
            Expanded(
              child: AddListBuilder(
                appBarText: state.screen == GoalScreens.addGoals
                    ? "Přidej góly"
                    : "Přidej asistence",
                goal: state.screen == GoalScreens.addGoals,
                onBackButtonPressed: state.screen == GoalScreens.addAssists
                    ? notifier.navigateToGoalScreen
                    : null,
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
                    const Expanded(child: Text("Propsat do pokut?")),
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
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CustomButton(
                  text: "Potvrď změny",
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
