import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/statistics/stat_args.dart';

import '../../../common/widgets/loader.dart';
import '../controller/stats_notifier.dart';
import '../widget/statistics_filter_bar.dart';
import 'new_statistics_view.dart';

class StatsScreen extends ConsumerStatefulWidget {
  final StatsArgs statsArgs;

  const StatsScreen(this.statsArgs, {super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  late final ScrollController _scrollController;
  bool _showFilters = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;

    if (_showFilters && offset > 40) {
      setState(() {
        _showFilters = false;
      });
    } else if (!_showFilters && offset <= 12) {
      setState(() {
        _showFilters = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsNotifierProvider(widget.statsArgs));

    return Scaffold(
      backgroundColor: context.appColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            if (stats.isDetail)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => ref
                      .read(statsNotifierProvider(widget.statsArgs).notifier)
                      .applyFilters(stats.advancedFilter),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Zpět na souhrn'),
                ),
              ),
            if (!stats.isDetail)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: StatisticsFilterBar(
                  statsArgs: widget.statsArgs,
                  compact: !_showFilters,
                ),
              ),
            const SizedBox(height: 4),
            Expanded(
              child: stats.stats.when(
                loading: () => const Loader(),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Statistiky se nepodařilo načíst.'),
                      TextButton(
                        onPressed: () => ref
                            .read(
                              statsNotifierProvider(widget.statsArgs).notifier,
                            )
                            .applyFilters(stats.advancedFilter),
                        child: const Text('Zkusit znovu'),
                      ),
                    ],
                  ),
                ),
                data: (_) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NewStatisticsView(
                    statsArgs: widget.statsArgs,
                    scrollController: _scrollController,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
