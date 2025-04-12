import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/button/change_achievement_button.dart';
import 'package:trus_app/features/achievement/controller/achievement_controller.dart';
import 'package:trus_app/features/achievement/widget/achievement_view_widget.dart';
import 'package:trus_app/features/player/screens/view_player_screen.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';

class ViewPlayerAchievementDetailScreen extends CustomConsumerStatefulWidget {
  static const String id = "view-player-achievement-detail-screen";

  const ViewPlayerAchievementDetailScreen({
    Key? key,
  }) : super(key: key, title: "Zobrazení achievementu", name: id);

  @override
  ConsumerState<ViewPlayerAchievementDetailScreen> createState() =>
      _ViewPlayerAchievementDetailScreenState();
}

class _ViewPlayerAchievementDetailScreenState
    extends ConsumerState<ViewPlayerAchievementDetailScreen> {
  @override
  Widget build(BuildContext context) {
    PlayerAchievementApiModel playerAchievementApiModel =
        ref.watch(screenControllerProvider).playerAchievementApiModel;
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(ViewPlayerAchievementDetailScreen.id)) {
      final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      return Scaffold(
        body: FutureBuilder<void>(
            future: ref
                .watch(achievementControllerProvider)
                .setupAchievementDetail(playerAchievementApiModel.id),
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
                loadModelFuture:
                    ref.watch(achievementControllerProvider).viewAchievement(),
                loadingScreen: null,
                columns: [
                  AchievementViewWidget(
                      size: size,
                      iAchievementHashKey:
                          ref.read(achievementControllerProvider),
                      viewMixin: ref.watch(achievementControllerProvider),
                      iAchievementNeededFields:
                          ref.read(achievementControllerProvider)),
                  const SizedBox(height: 10),
                ],
              );
            }),
        floatingActionButton:
        ChangeAchievementButton(
            context: context,
            crudOperations: ref.read(achievementControllerProvider),
            onOperationComplete: (id) {
              ref
                  .read(screenControllerProvider)
                  .changeFragment(ViewPlayerScreen.id);
            },
            playerAchievementApiModel: playerAchievementApiModel),
      );
    } else {
      return Container();
    }
  }
}
