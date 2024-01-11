import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/pkfl/screens/match_detail_screen.dart';
import 'package:trus_app/models/api/pkfl/pkfl_match_api_model.dart';
import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../../models/enum/match_detail_options.dart';
import '../../main/screen_controller.dart';
import '../controller/pkfl_controller.dart';

class PkflFixturesScreen extends CustomConsumerWidget {
  static const String id = "pkfl-fixtures-screen";

  const PkflFixturesScreen({
    Key? key,
  }) : super(key: key, title: "Program zápasů", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(screenControllerProvider).isScreenFocused(id)) {
      return Scaffold(
          body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ModelsErrorFutureBuilder(
          key: const ValueKey('pkfl_fixtures'),
          future: ref.watch(pkflControllerProvider).getModels(),
          onPressed: (pkflMatch) => {
            ref
                .read(screenControllerProvider)
                .setPreferredScreen(MatchDetailOptions.pkflDetail),
            ref
                .read(screenControllerProvider)
                .setPkflMatch(pkflMatch as PkflMatchApiModel),
            ref
                .read(screenControllerProvider)
                .changeFragment(MatchDetailScreen.id)
          },
          context: context,
        ),
      ));
    } else {
      return Container();
    }
  }
}
