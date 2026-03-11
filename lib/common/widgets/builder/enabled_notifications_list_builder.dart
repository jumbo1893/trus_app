import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/notification/push/controller/enabled_notifications_notifier.dart';

import '../../../colors.dart';
import '../../../models/api/notification/push/enabled_push_notification.dart';
import '../custom_text.dart';
import '../loader.dart';

class EnabledNotificationsListBuilder<T> extends ConsumerWidget {
  final AsyncValue<List<EnabledPushNotification>> notificationsList;
  final EnabledNotificationsNotifier notifier;

  const EnabledNotificationsListBuilder({
    Key? key,
    required this.notificationsList,
    required this.notifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double padding = 20;
    final size = MediaQuery.of(context).size;
    return notificationsList.when(
        loading: () => const Loader(),
        error: (_, __) => const SizedBox(),
        data: (modelList) => ListView.builder(
              shrinkWrap: true,
              itemCount: modelList.length,
              itemBuilder: (context, index) {
                var notification = modelList[index];
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
                            child: Container(
                              decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: orangeColor))),
                              alignment: Alignment.centerRight,
                              width: size.width - padding,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(text: notification.listViewTitle()),
                                  Switch(
                                    activeColor: orangeColor,
                                    value: notification.enabled,
                                    onChanged: (bool value) {
                                      notifier.setNotification(value, notification.type);
                                    },
                                  ),
                                ],
                              ),
                            )),
                      ),
                    )
                  ],
                );
              },
            ));
  }
}
