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

    final listViewNotifier = (statsArgs.api == receivedFineApi) ? ((state
        .level == StatsLevel.detail2) ? null : notifier) : state.isDetail
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

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 12,
                      offset: Offset(0, 6),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      value.text,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Expanded(
          child: ModelToStringListview(
            state: state,
            notifier: listViewNotifier,
            scrollController: scrollController,
          ),
        ),
      ],
    );
  }
}