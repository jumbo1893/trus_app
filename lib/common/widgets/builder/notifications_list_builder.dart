import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/api/notification/notification_api_model.dart';
import '../loader.dart';
import '../notification_list_tile.dart';

class NotificationListBuilder<T> extends ConsumerWidget {
  final AsyncValue<List<NotificationApiModel>> notificationsList;

  const NotificationListBuilder({
    super.key,
    required this.notificationsList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return notificationsList.when(
      loading: () => const Center(child: Loader()),
      error: (_, __) => const SizedBox.shrink(),
      data: (modelList) {
        if (modelList.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: modelList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
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