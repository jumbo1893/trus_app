import '../../../common/widgets/scroll_drag_forwarder.dart';
import '../../../theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/model_to_string_listview.dart';
import 'package:trus_app/config.dart';

import '../../../common/widgets/loader.dart';
import '../controller/stats_notifier.dart';
import '../stat_args.dart';
import '../stats_level.dart';

class NewStatisticsView extends ConsumerWidget {
  final StatsArgs statsArgs;
  final ScrollController? scrollController;

  const NewStatisticsView({
    super.key,
    required this.statsArgs,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statsNotifierProvider(statsArgs));
    final notifier = ref.read(statsNotifierProvider(statsArgs).notifier);

    final listViewNotifier = (statsArgs.api == receivedFineApi)
        ? ((state.level == StatsLevel.detail2) ? null : notifier)
        : state.isDetail
        ? null
        : notifier;

    return Column(
      children: [
        state.overall.when(
          loading: () => const Loader(),
          error: (_, __) => const SizedBox(),
          data: (value) {
            if (value == null || value.text.isEmpty) {
              return const SizedBox.shrink();
            }

            return ScrollDragForwarder(
              key: const ValueKey('statistics-overall'),
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: context.appColors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    title: Text(
                      value.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: state.lastUpdated == null
                        ? null
                        : Text(
                            'Aktualizováno ${TimeOfDay.fromDateTime(state.lastUpdated!).format(context)}',
                          ),
                    trailing: IconButton(
                      tooltip: 'Obnovit statistiky',
                      icon: const Icon(Icons.refresh),
                      onPressed: notifier.refresh,
                    ),
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(value.title),
                        content: SingleChildScrollView(child: Text(value.text)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Zavřít'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Expanded(
          child: ModelToStringListview(
            onRefresh: notifier.refresh,
            bottomPadding: 16,
            state: state,
            notifier: listViewNotifier,
            onRetry: () => notifier.applyFilters(state.advancedFilter),
            scrollController: scrollController,
            emptyListTitle:
                state.advancedFilter.activeCount > 0 ||
                    (state.filter?.trim().isNotEmpty ?? false)
                ? 'Filtrům neodpovídají žádné výsledky'
                : 'Zatím žádná data',
            emptyListText:
                state.advancedFilter.activeCount > 0 ||
                    (state.filter?.trim().isNotEmpty ?? false)
                ? 'Změň filtry nebo vymaž hledání.'
                : 'Výsledky se objeví po prvním zápisu.',
          ),
        ),
      ],
    );
  }
}
