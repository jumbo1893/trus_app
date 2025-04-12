import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/builder/add_builder.dart';
import 'package:trus_app/common/widgets/builder/error_future_builder.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/features/goal/controller/goal_controller.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/button/confirm_button.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/rows/crud/row_switch_stream.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';
import '../goal_screens.dart';

class GoalScreen extends CustomConsumerStatefulWidget {
  static const String id = "goal-screen";

  const GoalScreen({
    Key? key,
  }) : super(key: key, title: "Přidání gólů/asistencí", name: id);

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;
    final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
    if (ref.read(screenControllerProvider).isScreenFocused(GoalScreen.id)) {
      return ErrorFutureBuilder<void>(
        future: ref
            .read(goalControllerProvider)
            .setupMatch(ref.read(screenControllerProvider).matchId!),
        context: context,
        widget: StreamBuilder<GoalScreens>(
            stream: ref.watch(goalControllerProvider).screen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == GoalScreens.addGoals) {
                return FutureBuilder<void>(
                    future: ref.watch(goalControllerProvider).newGoal(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        Future.delayed(
                            Duration.zero,
                                () => showErrorDialog(
                                snapshot,
                                    () => ref
                                    .read(screenControllerProvider)
                                    .changeFragment(HomeScreen.id),
                                context));
                        return const Loader();
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: AddBuilder(
                              addController: ref.read(goalControllerProvider),
                              appBarText: "Přidej góly",
                              goal: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(padding),
                            child: RowSwitchStream(
                              key: const ValueKey('goal_fine_field'),
                              size: size,
                              padding: padding,
                              textFieldText: "Propsat do pokut?",
                              booleanControllerMixin:
                              ref.watch(goalControllerProvider),
                              hashKey: ref.read(goalControllerProvider).rewriteKey,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: CustomButton(
                                text: "Pokračuj k asistencím",
                                onPressed: () => {
                                  ref
                                      .read(goalControllerProvider)
                                      .navigateToAssistScreen()
                                }),
                          )
                        ],
                      );
                    });
              } else {
                return Column(
                  children: [
                    Expanded(
                        child: AddBuilder(
                      addController: ref.read(goalControllerProvider),
                      appBarText: "Přidej asistence",
                      goal: false,
                      onBackButtonPressed: () => {
                        ref.read(goalControllerProvider).navigateToGoalScreen()
                      },
                    )),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ConfirmButton(
                        text: "Potvrď změny",
                        context: context,
                        confirmOperations: ref.read(goalControllerProvider),
                        id: ref.read(screenControllerProvider).matchId!,
                        onOperationComplete: () {
                          ref
                              .read(screenControllerProvider)
                              .changeFragment(HomeScreen.id);
                        },
                      ),
                    )
                  ],
                );
              }
            }),
      );
    } else {
      return Container();
    }
  }
}
