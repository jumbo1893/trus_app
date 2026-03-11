import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/home/controller/home_notifier.dart'; // uprav import dle cesty

import '../../../models/api/home/chart.dart';
import '../dropdown/player_api_dropdown.dart';

class PickChartPlayer extends ConsumerStatefulWidget {
  const PickChartPlayer({
    super.key,
    required this.size,
    required this.padding,
    required this.chart,
  });

  final Size size;
  final double padding;
  final Chart? chart;

  @override
  ConsumerState<PickChartPlayer> createState() => _PickChartPlayerState();
}

class _PickChartPlayerState extends ConsumerState<PickChartPlayer> {
  @override
  void initState() {
    super.initState();
    // až po prvním frame, ať neporušujeme init pravidla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(homeNotifierProvider.notifier);
      final c = widget.chart;
      if (c == null || c.coordinates.isEmpty) {
        notifier.loadChartPlayersIfNeeded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);

    final c = widget.chart;
    if (c != null && c.coordinates.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(3.0),
      width: widget.size.width - widget.padding * 2,
      child: Center(
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.warning, color: orangeColor, size: 40),
                Flexible(
                  child: Text(
                    "Pro zobrazení svého grafu vyber hráče/fanouška pod kterým piješ. Do té doby zde budeš mít graf největších borců",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            PlayerApiDropdown(
              players: state.chartPlayers,
              onPlayerSelected: (player) => notifier.onPlayerPicked(player),
              onRetry: notifier.refreshChartPlayers,
            ),
          ],
        ),
      ),
    );
  }
}