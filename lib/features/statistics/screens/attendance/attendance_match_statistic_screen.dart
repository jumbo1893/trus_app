import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';

import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../stat_args.dart';
import '../stats_screen.dart';

class AttendanceMatchStatisticScreen extends CustomConsumerStatefulWidget {
  static const String id = "attendance-match-statistics-screen";

  const AttendanceMatchStatisticScreen({
    super.key,
  }) : super(
    title: "Počet hráčů v zápasech",
    name: id,
  );

  @override
  ConsumerState<AttendanceMatchStatisticScreen> createState() =>
      _AttendanceMatchStatisticScreenState();
}

class _AttendanceMatchStatisticScreenState
    extends ConsumerState<AttendanceMatchStatisticScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: StatsScreen(StatsArgs(attendanceApi, true)),
    );
  }
}