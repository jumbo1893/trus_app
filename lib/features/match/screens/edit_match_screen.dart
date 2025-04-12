import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';
import '../widget/match_crud_widget.dart';

class EditMatchScreen extends CustomConsumerStatefulWidget {
  final bool isFocused;
  static const String id = "edit-match-screen";

  const EditMatchScreen({
    Key? key,
    required this.isFocused,
  }) : super(key: key, title: "Upravit zápas", name: id);

  @override
  ConsumerState<EditMatchScreen> createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends ConsumerState<EditMatchScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      const double padding = 8.0;
      final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      return ColumnFutureBuilder(
        loadModelFuture: ref.watch(matchControllerProvider).editMatch(),
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
            text: "Potvrď změny",
            context: context,
            crud: Crud.update,
            crudOperations: ref.read(matchControllerProvider),
            onOperationComplete: (id) {
              ref.read(screenControllerProvider).setChangedMatch(true);
              ref.read(screenControllerProvider).changeFragment(HomeScreen.id);
            },
            id: ref.read(matchControllerProvider).returnEditMatch().id!,
          ),
          CrudButton(
            key: const ValueKey('confirm_and_goal_button'),
            text: "Potvrď a uprav góly",
            context: context,
            crud: Crud.update,
            id: ref.read(matchControllerProvider).returnEditMatch().id!,
            crudOperations: ref.read(matchControllerProvider),
            onOperationComplete: (id) {
              hideSnackBar(context);
              ref.read(screenControllerProvider).setMatchId(id);
              ref.read(screenControllerProvider).changeFragment(GoalScreen.id);
            },
          ),
          CrudButton(
            key: const ValueKey('delete_button'),
            text: "Smaž zápas",
            context: context,
            crud: Crud.delete,
            crudOperations: ref.read(matchControllerProvider),
            onOperationComplete: (id) {
              ref.read(screenControllerProvider).setChangedMatch(true);
              ref.read(screenControllerProvider).changeFragment(HomeScreen.id);
            },
            id: ref.read(matchControllerProvider).returnEditMatch().id!,
            modelToString: ref.read(matchControllerProvider).matchSetup.match!,
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
