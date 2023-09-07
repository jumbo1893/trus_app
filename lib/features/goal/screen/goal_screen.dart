import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/builder/add_builder.dart';
import 'package:trus_app/common/widgets/builder/error_future_builder.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/features/goal/controller/goal_controller.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/confirm_button.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/rows/row_switch.dart';
import '../../../common/widgets/rows/stream/row_switch_stream.dart';
import '../goal_screens.dart';

class GoalScreen extends ConsumerStatefulWidget {
  final VoidCallback onAddGoalsPressed;
  final bool isFocused;
  final int matchId;
  const GoalScreen({
    Key? key,
    required this.onAddGoalsPressed,
    required this.isFocused,
    required this.matchId,
  }) : super(key: key);

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;
    final size = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
    if (widget.isFocused) {
      return ErrorFutureBuilder<void>(
        future: ref.read(goalControllerProvider).setupMatch(widget.matchId),
        onDialogCancel: () => widget.onAddGoalsPressed(),
        context: context,
        widget: StreamBuilder<GoalScreens>(
            stream: ref.watch(goalControllerProvider).screen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == GoalScreens.addGoals) {
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
              } else {
                return Column(
                  children: [
                    Expanded(
                        child: AddBuilder(
                      addController: ref.read(goalControllerProvider),
                      appBarText: "Přidej asistence",
                      goal: false,
                    )),
                    Padding(
                      padding: const EdgeInsets.all(padding),
                      child: RowSwitchStream(
                        size: size,
                        padding: padding,
                        textFieldText: "Propsat do pokut?",
                        stream:
                            ref.watch(goalControllerProvider).rewriteFines(),
                        initStream: () => ref
                            .watch(goalControllerProvider)
                            .initRewriteStream(),
                        onChecked: (rewrite) {
                          ref
                              .watch(goalControllerProvider)
                              .setRewriteFines(rewrite);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ConfirmButton(
                        text: "Potvrď změny",
                        context: context,
                        confirmOperations: ref
                            .read(goalControllerProvider),
                        id: widget.matchId,
                        onOperationComplete: () {
                          widget.onAddGoalsPressed();
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
