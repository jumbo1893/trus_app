import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../controller/season_controller.dart';

class SeasonScreen extends ConsumerWidget {
  final VoidCallback onPlusButtonPressed;
  final VoidCallback backToMainMenu;
  final Function(SeasonApiModel seasonModel) setSeason;
  final bool isFocused;
  const SeasonScreen({
    Key? key,
    required this.onPlusButtonPressed,
    required this.setSeason,
    required this.backToMainMenu,
    required this.isFocused,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isFocused) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ModelsErrorFutureBuilder(
            future: ref.watch(seasonControllerProvider).getModels(),
            onPressed: (season) => {setSeason(season as SeasonApiModel)},
            backToMainMenu: () => backToMainMenu,
            context: context,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onPlusButtonPressed,
          elevation: 4.0,
          child: const Icon(Icons.add),
        ));
    }
    else {
      return Container();
    }
  }
}
