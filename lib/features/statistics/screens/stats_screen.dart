import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/season/controller/season_dropdown_notifier.dart';
import 'package:trus_app/features/statistics/stat_args.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/animated_filter_panel.dart';
import '../../../common/widgets/back_handler_listener.dart';
import '../../../common/widgets/dropdown/custom_dropdown_sheet.dart';
import '../../../common/widgets/loader.dart';
import '../../home/screens/home_screen.dart';
import '../../season/season_args.dart';
import '../controller/stats_notifier.dart';
import '../state/stats_state.dart';
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
    final seasonProvider =
    seasonDropdownNotifierProvider(const SeasonArgs(false, false, true));

    ref.listen<StatsState>(
      statsNotifierProvider(widget.statsArgs),
          (_, next) {
        next.stats.whenOrNull(
          error: (e, st) => showErrorDialogFromError(
            e,
            st,
                () => ref.read(screenNotifierProvider.notifier).changeFragment(HomeScreen.id),
            context,
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: Column(
          children: [
            if (!stats.isDetail)
              AnimatedFilterPanel(
                visible: _showFilters,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: StatisticsFilterBar(
                    seasonDropdown: CustomDropdownSheet(
                      hint: "Vyber sezonu",
                      notifier: ref.read(seasonProvider.notifier),
                      state: ref.watch(seasonProvider),
                    ),
                    statsArgs: widget.statsArgs,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: stats.stats.when(
                loading: () => const Loader(),
                error: (_, __) => const SizedBox(),
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