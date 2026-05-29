import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/notification/push/controller/enabled_notifications_notifier.dart';

import 'package:trus_app/theme/app_colors.dart';
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
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                  color: context.appColors.textMuted,
                                ))),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: context.appColors.legacyAccent))),
                          alignment: Alignment.centerRight,
                          width: size.width - padding,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(text: notification.listViewTitle()),
                              Switch(
                                  activeThumbColor: context.appColors.legacyAccent,
                                  value: notification.enabled,
                                  onChanged: (bool value) {
                                    notifier.changeEnabledNotification(notification, value);
                                  }
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
