import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/statistics/screens/stats_screen.dart';

import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../../config.dart';
import '../../stat_args.dart';

class BeerPlayerStatisticScreen extends CustomConsumerStatefulWidget {
  static const String id = "beer-player-statistics-screen";

  const BeerPlayerStatisticScreen({
    Key? key,
  }) : super(key: key, title: "Statistika piv hráče", name: id);

  @override
  ConsumerState<BeerPlayerStatisticScreen> createState() =>
      _BeerPlayerStatisticScreenState();
}

class _BeerPlayerStatisticScreenState
    extends ConsumerState<BeerPlayerStatisticScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: StatsScreen(StatsArgs(beerApi, false))
    );
  }
}
