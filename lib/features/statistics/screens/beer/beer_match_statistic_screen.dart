import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/statistics/screens/stats_screen.dart';
import 'package:trus_app/features/statistics/stat_args.dart';

import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';

class BeerMatchStatisticScreen extends CustomConsumerStatefulWidget {
  static const String id = "beer-match-statistics-screen";

  const BeerMatchStatisticScreen({
    Key? key,
  }) : super(key: key, title: "Statistika piv zápasu", name: id);

  @override
  ConsumerState<BeerMatchStatisticScreen> createState() =>
      _BeerMatchStatisticScreenState();
}

class _BeerMatchStatisticScreenState
    extends ConsumerState<BeerMatchStatisticScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: StatsScreen(StatsArgs(beerApi, true))
    );
  }
}
