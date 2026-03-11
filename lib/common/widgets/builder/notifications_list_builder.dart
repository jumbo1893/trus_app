import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/api/notification/notification_api_model.dart';
import '../loader.dart';
import '../notification_list_tile.dart';

class NotificationListBuilder<T> extends ConsumerWidget {
  final AsyncValue<List<NotificationApiModel>> notificationsList;

  const NotificationListBuilder({
    Key? key,
    required this.notificationsList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return notificationsList.when(
      loading: () => const Loader(),
      error: (_, __) => const SizedBox(),
      data: (modelList) => ListView.builder(
        shrinkWrap: true,
        itemCount: modelList.length,
        itemBuilder: (context, index) {
          var notification =
             modelList[index];
          return Column(
            children: [
              InkWell(
                onTap: () => {},
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 8.0, left: 8, right: 8),
                  child: Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                              ))),
                      child: NotificationListTile(
                        notificationModel: notification,
                        padding: 16,
                      )),
                ),
              )
            ],
          );
        },
      )
    );
  }
}
