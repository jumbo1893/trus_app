import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../../config.dart';
import '../../stat_args.dart';
import '../stats_screen.dart';

class FineMatchStatisticScreen extends CustomConsumerStatefulWidget {
  static const String id = "fine-match-statistics-screen";

  const FineMatchStatisticScreen({
    Key? key,
  }) : super(key: key, title: "Statistika pokut zápasu", name: id);

  @override
  ConsumerState<FineMatchStatisticScreen> createState() =>
      _FineMatchStatisticScreenState();
}

class _FineMatchStatisticScreenState
    extends ConsumerState<FineMatchStatisticScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: StatsScreen(StatsArgs(receivedFineApi, true))
    );
  }
}
