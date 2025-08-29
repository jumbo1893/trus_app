import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/controller/achievement_controller.dart';
import 'package:trus_app/features/achievement/screens/view_achievement_detail_screen.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';

import '../../../common/widgets/builder/models_cache_builder.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../main/screen_controller.dart';
class AchievementScreen extends CustomConsumerWidget {
  static const String id = "achievement-screen";

  const AchievementScreen({
    Key? key,
  }) : super(key: key, title: "Achievementy", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(screenControllerProvider).isScreenFocused(AchievementScreen.id)) {
      var provider = ref.watch(achievementControllerProvider);
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ModelsCacheBuilder(
              key: const ValueKey('achievement_list'),
              listSetup: provider.setupAchievementList(),
              modelToStringListControllerMixin: provider,
              hashKey: provider.achievementListId,
              onPressed: (achievement) => {
                ref
                    .read(screenControllerProvider)
                    .setAchievementDetail(achievement as AchievementDetail),
                ref
                    .read(screenControllerProvider)
                    .changeFragment(ViewAchievementDetailScreen.id)
              },
            ),
          ),
          );
    } else {
      return Container();
    }
  }
}
