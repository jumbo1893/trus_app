import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/match_detail_options.dart';
import '../../main/screen_controller.dart';
import '../controller/pkfl_table_controller.dart';
import 'match_detail_screen.dart';

class PkflTableScreen extends CustomConsumerStatefulWidget {
  static const String id = "pkfl-table-screen";

  const PkflTableScreen({
    Key? key,
  }) : super(key: key, title: "Tabulka PKFL", name: id);

  @override
  ConsumerState<PkflTableScreen> createState() => _PkflTableScreenState();
}

class _PkflTableScreenState extends ConsumerState<PkflTableScreen> {


  void setScreenToCommonMatches(int pkflMatchId) {
    if(pkflMatchId != -1) {
      ref
          .read(screenControllerProvider)
          .setPreferredScreen(MatchDetailOptions.commonMatches);
      ref.read(screenControllerProvider).setPkflMatchIdOnlyForCommonMatches(pkflMatchId);
      ref.read(screenControllerProvider).changeFragment(MatchDetailScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.read(screenControllerProvider).isScreenFocused(PkflTableScreen.id)) {
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ModelsErrorFutureBuilder(
              key: const ValueKey('pkfl_table'),
              future: ref.watch(pkflTableControllerProvider).getModels(),
              onPressed: (pkflTableTeam) => {
                setScreenToCommonMatches(pkflTableTeam.getId())
              },
              context: context,
            ),
          ));
    } else {
      return Container();
    }
  }
}
