import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/player/screens/edit_player_screen.dart';
import 'package:trus_app/features/player/widget/player_view_widget.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/api/player/player_api_model.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';
import '../controller/player_controller.dart';

class ViewPlayerScreen extends CustomConsumerStatefulWidget {
  static const String id = "view-player-screen";

  const ViewPlayerScreen({
    Key? key,
  }) : super(key: key, title: "Zobrazení hráče", name: id);

  @override
  ConsumerState<ViewPlayerScreen> createState() => _ViewPlayerScreenState();
}

class _ViewPlayerScreenState extends ConsumerState<ViewPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    PlayerApiModel player = ref.watch(screenControllerProvider).playerModel;
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(ViewPlayerScreen.id)) {
      final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      return Scaffold(
        body: FutureBuilder<void>(
            future:
                ref.watch(playerControllerProvider).setupEditPlayer(player.id!),
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
              return ColumnFutureBuilder(
                loadModelFuture: ref.watch(playerControllerProvider).viewPlayer(),
                loadingScreen: null,
                columns: [
                  PlayerViewWidget(
                    size: size,
                    iPlayerHashKey: ref.read(playerControllerProvider),
                    viewMixin: ref.watch(playerControllerProvider),
                    achievementMixin: ref.watch(playerControllerProvider),
                    nameFieldText: ref.read(playerControllerProvider).getNameViewField(),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
          floatingActionButton: FloatingActionButton(
            onPressed: () => ref
                .read(screenControllerProvider)
                .changeFragment(EditPlayerScreen.id),
            elevation: 4.0,
            child: const Icon(Icons.edit),
      ));
    } else {
      return Container();
    }
  }
}
