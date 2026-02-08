import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';

import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../stat_args.dart';
import '../stats_screen.dart';

class GoalMatchStatisticScreen extends CustomConsumerStatefulWidget {
  static const String id = "goal-match-statistics-screen";

  const GoalMatchStatisticScreen({
    Key? key,
  }) : super(key: key, title: "Statistika gólů zápasu", name: id);

  @override
  ConsumerState<GoalMatchStatisticScreen> createState() =>
      _GoalMatchStatisticScreenState();
}

class _GoalMatchStatisticScreenState
    extends ConsumerState<GoalMatchStatisticScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: StatsScreen(StatsArgs(goalApi, true))
    );
  }
}
