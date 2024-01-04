import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';

import '../../../common/widgets/builder/notifications_error_future_builder.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../main/screen_controller.dart';
import '../controller/notification_controller.dart';

class NotificationScreen extends CustomConsumerWidget {
  static const String id = "notification-screen";
  const NotificationScreen(
      {
    Key? key,
  }) : super(key: key, title: "Notifikace", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(screenControllerProvider).isScreenFocused(id)) {
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: NotificationsErrorFutureBuilder(
              future: ref.watch(notificationControllerProvider).getNotifications(),
              context: context,
              rebuildStream: ref.watch(notificationControllerProvider).notifications(),
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StreamBuilder<bool>(
                stream: ref.watch(notificationControllerProvider).showPreviousButton(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }
                  return Visibility(
                    visible: snapshot.data!,
                    child: FloatingActionButton(
                      onPressed: () => ref.read(notificationControllerProvider).previousPage(),
                      child: const Icon(Icons.skip_previous),
                    ),
                  );
                }
              ),
              const SizedBox(height: 8,),
              StreamBuilder<bool>(
                stream: ref.watch(notificationControllerProvider).showNextButton(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }
                  return Visibility(
                    visible: snapshot.data!,
                    child: FloatingActionButton(
                      onPressed: () => ref.read(notificationControllerProvider).nextPage(),
                      child: const Icon(Icons.skip_next),
                    ),
                  );
                }
              ),
            ],
          ));
    }
    else {
      return Container();
    }
  }
}
