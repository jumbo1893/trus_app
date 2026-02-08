import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';

import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../stat_args.dart';
import '../stats_screen.dart';

class FinePlayerStatisticScreen extends CustomConsumerStatefulWidget {
  static const String id = "fine-player-statistics-screen";

  const FinePlayerStatisticScreen({
    Key? key,
  }) : super(key: key, title: "Statistika pokut hráče", name: id);

  @override
  ConsumerState<FinePlayerStatisticScreen> createState() =>
      _FinePlayerStatisticScreenState();
}

class _FinePlayerStatisticScreenState
    extends ConsumerState<FinePlayerStatisticScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: StatsScreen(StatsArgs(receivedFineApi, false))
    );
  }
}
