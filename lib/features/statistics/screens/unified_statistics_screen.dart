import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../football/screens/football_stats_screen.dart';
import '../../football/screens/football_player_stats_screen.dart';
import '../controller/stats_notifier.dart';
import '../statistics_navigation.dart';
import 'beer/beer_detail_stats_screen.dart';
import 'stats_screen.dart';

class UnifiedStatisticsScreen extends ConsumerStatefulWidget {
  const UnifiedStatisticsScreen({super.key});
  @override
  ConsumerState<UnifiedStatisticsScreen> createState() =>
      _UnifiedStatisticsScreenState();
}

class _UnifiedStatisticsScreenState
    extends ConsumerState<UnifiedStatisticsScreen> {
  final _subscriptions = <String, ProviderSubscription<dynamic>>{};
  final _views = <StatisticsCategory, int>{};
  final _categoryKeys = {
    for (final category in StatisticsCategory.values) category: GlobalKey(),
  };
  void _retain(StatisticsSelection selection) {
    final args = selection.args;
    if (args != null) {
      _subscriptions.putIfAbsent(
        selection.key,
        () => ref.listenManual(statsNotifierProvider(args), (_, __) {}),
      );
    }
    _views[selection.category] = selection.view;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _categoryKeys[selection.category]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: const Duration(milliseconds: 180),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _retain(ref.read(statisticsSelectionProvider));
    ref.listenManual(statisticsSelectionProvider, (_, next) => _retain(next));
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(statisticsSelectionProvider);
    final category = selection.category;
    final labels = category == StatisticsCategory.league
        ? ['Hráči', 'Zajímavosti']
        : [
            'Hráči',
            'Zápasy',
            if (category == StatisticsCategory.beer) 'Podrobnosti',
          ];
    final args = selection.args;
    final Widget content = args != null
        ? StatsScreen(args, key: ValueKey(selection.key))
        : category == StatisticsCategory.beer
        ? const BeerDetailStatsScreen()
        : selection.view == 0
        ? const FootballStatsScreen()
        : const FootballPlayerStatsScreen();
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              for (final entry in StatisticsCategory.values)
                Padding(
                  key: _categoryKeys[entry],
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      ['Piva', 'Pokuty', 'Góly', 'Účast', 'Liga'][entry.index],
                    ),
                    selected: category == entry,
                    onSelected: (_) =>
                        ref.read(statisticsSelectionProvider.notifier).state =
                            StatisticsSelection(entry, _views[entry] ?? 0),
                  ),
                ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SegmentedButton<int>(
            segments: [
              for (var i = 0; i < labels.length; i++)
                ButtonSegment(value: i, label: Text(labels[i])),
            ],
            selected: {selection.view},
            onSelectionChanged: (values) =>
                ref.read(statisticsSelectionProvider.notifier).state =
                    StatisticsSelection(category, values.single),
          ),
        ),
        Expanded(child: content),
      ],
    );
  }
}
