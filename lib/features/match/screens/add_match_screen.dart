import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';
import 'package:trus_app/features/match/widget/match_crud_widget.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../../main/screen_controller.dart';

class AddMatchScreen extends CustomConsumerStatefulWidget {
  static const String id = "add-match-screen";

  const AddMatchScreen({
    Key? key,
  }) : super(key: key, title: "Přidat zápas", name: id);

  @override
  ConsumerState<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends ConsumerState<AddMatchScreen> {
  @override
  Widget build(BuildContext context) {
    if (ref.read(screenControllerProvider).isScreenFocused(AddMatchScreen.id)) {
      final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      return FutureBuilder<void>(
          future: ref.watch(matchControllerProvider).setupNewMatch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            } else if (snapshot.hasError) {
              Future.delayed(
                  Duration.zero,
                  () => showErrorDialog(snapshot, () {
                        ref
                            .read(screenControllerProvider)
                            .changeFragment(HomeScreen.id);
                      }, context));
              return const Loader();
            }
            FootballMatchApiModel? footballMatch =
                ref.read(screenControllerProvider).footballMatch;
            return ColumnFutureBuilder(
              loadModelFuture: footballMatch == null
                  ? ref.watch(matchControllerProvider).newMatch()
                  : ref
                      .watch(matchControllerProvider)
                      .newMatchByFootballMatch(footballMatch),
              loadingScreen: null,
              columns: [
                MatchCrudWidget(
                    size: size,
                    iMatchHashKey: ref.read(matchControllerProvider),
                    stringMixin: ref.watch(matchControllerProvider),
                    dateMixin: ref.watch(matchControllerProvider),
                    booleanMixin: ref.watch(matchControllerProvider),
                    dropdownMixin: ref.watch(matchControllerProvider),
                    checkedListControllerMixin:
                        ref.watch(matchControllerProvider)),
                const SizedBox(height: 10),
                CrudButton(
                  key: const ValueKey('confirm_button'),
                  text: "Potvrď",
                  context: context,
                  crud: Crud.create,
                  crudOperations: ref.read(matchControllerProvider),
                  onOperationComplete: (id) {
                    ref.read(screenControllerProvider).setMatchId(id);
                    ref.read(screenControllerProvider).setChangedMatch(true);
                    ref
                        .read(screenControllerProvider)
                        .changeFragment(HomeScreen.id);
                  },
                ),
                CrudButton(
                  key: const ValueKey('confirm_and_goal_button'),
                  text: "Potvrď a přejdi ke gólům",
                  context: context,
                  crud: Crud.create,
                  crudOperations: ref.read(matchControllerProvider),
                  onOperationComplete: (id) {
                    ref.read(screenControllerProvider).setMatchId(id);
                    ref
                        .read(screenControllerProvider)
                        .changeFragment(GoalScreen.id);
                  },
                ),
              ],
            );
          });
    } else {
      return Container();
    }
  }
}
