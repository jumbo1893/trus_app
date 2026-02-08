import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/model_to_string_listview.dart';

import '../../../colors.dart';
import '../../../common/widgets/loader.dart';
import '../controller/stats_notifier.dart';
import '../stat_args.dart';

class NewStatisticsView extends ConsumerWidget {
  final StatsArgs statsArgs;

  const NewStatisticsView({
    super.key,
    required this.statsArgs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final state = ref.watch(statsNotifierProvider(statsArgs));
    final notifier = ref.read(statsNotifierProvider(statsArgs).notifier);
    return Column(
      children: [
          state.overall.when(
            loading: () => const Loader(),
            error: (_, __) => const SizedBox(),
            data: (value) {
              if (value == null || value.text.isEmpty) {
                return const SizedBox();
              }

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                  left: 8,
                  right: 8,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        value.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      value.text,
                      style: const TextStyle(
                        color: listviewSubtitleColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        Expanded(
          child: ModelToStringListview(
              state: state,
              notifier: notifier),
        ),
      ],
    );
  }
}
