import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';

import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../stat_args.dart';
import '../stats_screen.dart';

class AttendancePlayerStatisticScreen extends CustomConsumerStatefulWidget {
  static const String id = "attendance-player-statistics-screen";

  const AttendancePlayerStatisticScreen({
    super.key,
  }) : super(
    title: "Účast hráčů na zápasech",
    name: id,
  );

  @override
  ConsumerState<AttendancePlayerStatisticScreen> createState() =>
      _AttendancePlayerStatisticScreenState();
}

class _AttendancePlayerStatisticScreenState
    extends ConsumerState<AttendancePlayerStatisticScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: StatsScreen(StatsArgs(attendanceApi, false)),
    );
  }
}
