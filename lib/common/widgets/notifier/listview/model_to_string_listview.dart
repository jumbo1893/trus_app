import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_widget_values.dart';
import '../../loader.dart';

class ModelToStringListview extends ConsumerWidget {
  final IListviewState state;
  final IListviewNotifier? notifier;
  final String emptyListText;
  final String emptyListTitle;
  final ScrollController? scrollController;


  const ModelToStringListview({
    super.key,
    required this.state,
    required this.notifier,
    this.emptyListText = "Zatím tu nic není",
    this.emptyListTitle = "Po změně se sezony se záznamy objeví zde",
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return state.getListViewItems().when(
      loading: () => const Center(child: Loader()),
      error: (_, __) => const SizedBox.shrink(),
      data: (modelList) {
        if (modelList.isEmpty) {
          return  _EmptyListState(title: emptyListTitle, text: emptyListText,);
        }
        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: modelList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = modelList[index];

            return Material(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: notifier == null
                    ? null
                    : () => notifier!.selectListviewItem(item),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
                  decoration: BoxDecoration(
                    color: context.appColors.cardBackground,
                    borderRadius: AppWidgetValues.borderRadiusXl,
                    boxShadow: AppWidgetValues.cardShadow,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.listViewTitle(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                height: 1.3,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.toStringForListView(),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                       Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon( notifier == null
                            ? null
                            :
                          Icons.chevron_right_rounded,
                          color: Colors.black38,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyListState extends StatelessWidget {
  final String title;
  final String text;
  const _EmptyListState({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                blurRadius: 12,
                offset: Offset(0, 6),
                color: Colors.black12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 36,
                color: Colors.black38,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}