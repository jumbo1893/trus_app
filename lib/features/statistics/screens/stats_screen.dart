import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/season/controller/season_dropdown_notifier.dart';
import 'package:trus_app/features/statistics/stat_args.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/back_handler_listener.dart';
import '../../../common/widgets/button/statistics_buttons.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/notifier/dropdown/custom_dropdown.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';
import '../../season/season_args.dart';
import '../controller/stats_notifier.dart';
import '../state/stats_state.dart';
import 'new_statistics_view.dart';

class StatsScreen extends ConsumerWidget {
  final StatsArgs statsArgs;
  const StatsScreen(this.statsArgs, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    const double padding = 8.0;

    final stats = ref.watch(statsNotifierProvider(statsArgs));

    ref.listen<StatsState>(
      statsNotifierProvider(statsArgs),
          (_, next) {
        next.stats.whenOrNull(
          error: (e, st) => showErrorDialogFromError(
            e,
            st,
                () => ref
                .read(screenControllerProvider)
                .changeFragment(HomeScreen.id),
            context,
          ),
        );
      },
    );
    return BackHandlerListener(
      provider: statsNotifierProvider(statsArgs),
      backActionBuilder: (ref) =>
          ref.read(statsNotifierProvider(statsArgs).notifier),
      child: Scaffold(
        body: Column(
          children: [
            if (!stats.isDetail)
              Row(
                children: [
                  SizedBox(
                    width: size.width / 2.5 - padding,
                    child: CustomDropdown(
                      hint: "Vyber sezonu",
                      notifier: ref.read(seasonDropdownNotifierProvider(const SeasonArgs(false, false, true)).notifier),
                      state: ref.watch(seasonDropdownNotifierProvider(const SeasonArgs(false, false, true))),
                    ),
                  ),
                  StatisticsButtons(
                    onSearchButtonClicked: (text) => ref
                        .read(statsNotifierProvider(statsArgs).notifier)
                        .search(text),
                    onOrderButtonClicked: () => ref
                        .read(statsNotifierProvider(statsArgs).notifier)
                        .toggleOrder(),
                    padding: padding,
                    size: size,
                    statsArgs: statsArgs,
                  ),
                ],
              ),
            Expanded(
              child: stats.stats.when(
                loading: () => const Loader(),
                error: (_, __) => const SizedBox(),
                data: (_) => NewStatisticsView(
                  statsArgs: statsArgs,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


