import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';

import '../../../../colors.dart';
import '../../loader.dart';

class ModelToStringListview extends ConsumerWidget {
  final IListviewState state;
  final IListviewNotifier? notifier;

  const ModelToStringListview({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return state.getListViewItems().when(
      loading: () => const Loader(),
      error: (_, __) => const SizedBox(),
      data: (modelList) => ListView.builder(
        itemCount: modelList.length,
        itemBuilder: (context, index) {
          final item = modelList[index];
          return InkWell(
            onTap: notifier == null
                ? null
                : () => notifier!.selectListviewItem(item),
            child: Padding(
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
                      item.listViewTitle(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    item.toStringForListView(),
                    style: const TextStyle(
                      color: listviewSubtitleColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

