import '../load_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/api/notification/notification_api_model.dart';
import '../loader.dart';
import '../notification_list_tile.dart';

class NotificationListBuilder<T> extends ConsumerWidget {
  final AsyncValue<List<NotificationApiModel>> notificationsList;
  final VoidCallback? onRetry;
  final Widget? footer;

  const NotificationListBuilder({
    super.key,
    required this.notificationsList,
    this.onRetry,
    this.footer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return notificationsList.when(
      loading: () => const Center(child: Loader()),
      error: (_, __) => LoadFailure(onRetry: onRetry),
      data: (modelList) {
        if (modelList.isEmpty) {
          return const Center(
            child: Text('Zatím tu nejsou žádné zaznamenané úkony.'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: modelList.length + (footer == null ? 0 : 1),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == modelList.length) return footer!;
            final notification = modelList[index];

            return NotificationListTile(
              notificationModel: notification,
              onTap: () {},
            );
          },
        );
      },
    );
  }
}
