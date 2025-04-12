import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';

import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../main/screen_controller.dart';
import '../controller/achievement_controller.dart';
import '../widget/achievement_view_widget.dart';

class ViewAchievementDetailScreen extends CustomConsumerStatefulWidget {
  static const String id = "view-achievement-detail-screen";

  const ViewAchievementDetailScreen({
    Key? key,
  }) : super(key: key, title: "Detail achievementu", name: id);

  @override
  ConsumerState<ViewAchievementDetailScreen> createState() => _ViewAchievementDetailScreenState();
}

class _ViewAchievementDetailScreenState extends ConsumerState<ViewAchievementDetailScreen> {
  @override
  Widget build(BuildContext context) {
    if (ref.read(screenControllerProvider).isScreenFocused(ViewAchievementDetailScreen.id)) {
      AchievementDetail achievementDetail = ref.watch(screenControllerProvider).achievementDetail;
      final size =
          MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      return ColumnFutureBuilder(
        loadModelFuture: ref.watch(achievementControllerProvider).achievement(achievementDetail),
        columns: [
          AchievementViewWidget(
              size: size,
              iAchievementHashKey: ref.read(achievementControllerProvider),
              viewMixin: ref.watch(achievementControllerProvider),
              iAchievementNeededFields: ref.read(achievementControllerProvider)
          ),
          const SizedBox(height: 10),
        ],
        loadingScreen: null,
      );
    } else {
      return Container();
    }
  }
}
