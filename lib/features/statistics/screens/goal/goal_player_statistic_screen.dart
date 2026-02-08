import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';

import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../stat_args.dart';
import '../stats_screen.dart';

class GoalPlayerStatisticScreen extends CustomConsumerStatefulWidget {
  static const String id = "goal-player-statistics-screen";

  const GoalPlayerStatisticScreen({
    Key? key,
  }) : super(key: key, title: "Statistika gólů hráče", name: id);

  @override
  ConsumerState<GoalPlayerStatisticScreen> createState() =>
      _GoalPlayerStatisticScreenState();
}

class _GoalPlayerStatisticScreenState
    extends ConsumerState<GoalPlayerStatisticScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: StatsScreen(StatsArgs(goalApi, false))
    );
  }
}
