import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/controller/achievement_notifier.dart';

import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';

class AchievementScreen extends CustomConsumerWidget {
  static const String id = "achievement-screen";

  const AchievementScreen({
    Key? key,
  }) : super(key: key, title: "Achievementy", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ModelToStringListview(
            state: ref.watch(achievementNotifierProvider),
            notifier: ref.read(achievementNotifierProvider.notifier)),
      ),
    );
  }
}
