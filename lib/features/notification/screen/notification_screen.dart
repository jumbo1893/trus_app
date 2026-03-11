import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/notification/controller/notifications_notifier.dart';

import '../../../common/widgets/builder/notifications_list_builder.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';

class NotificationScreen extends CustomConsumerWidget {
  static const String id = "notification-screen";
  const NotificationScreen(
      {
    Key? key,
  }) : super(key: key, title: "Notifikace", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsNotifierProvider);
    final notifier = ref.read(notificationsNotifierProvider.notifier);
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: NotificationListBuilder(
            notificationsList: state.notifications,
              ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: state.showPreviousButton,
              child: FloatingActionButton(
                onPressed: () => notifier.previousPage(),
                child: const Icon(Icons.skip_previous),
              ),
            ),
            Visibility(
              visible: state.showNextButton,
              child: FloatingActionButton(
                onPressed: () => notifier.nextPage(),
                child: const Icon(Icons.skip_next),
              ),
            ),
          ],
        ));
  }
}
