import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/pkfl/pkfl_match_api_model.dart';
import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../controller/pkfl_controller.dart';

class PkflFixturesScreen extends ConsumerWidget {
  final VoidCallback backToMainMenu;
  final Function(PkflMatchApiModel pkflMatch) setPkflMach;
  final bool isFocused;
  const PkflFixturesScreen({
    Key? key,
    required this.setPkflMach,
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
            key: const ValueKey('player_list'),
            future: ref.watch(pkflControllerProvider).getModels(),
            onPressed: (pkflMatch) => {setPkflMach(pkflMatch as PkflMatchApiModel)},
            backToMainMenu: () => backToMainMenu(),
            context: context,
          ),
        ));
    }
    else {
      return Container();
    }
  }
}
