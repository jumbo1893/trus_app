import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';

import '../../../common/widgets/builder/notifications_error_future_builder.dart';
import '../../../common/widgets/notification_list_tile.dart';
import '../../../models/notification_model.dart';
import '../controller/notification_controller.dart';

class NotificationScreen extends ConsumerWidget {
  final VoidCallback backToMainMenu;
  final bool isFocused;
  const NotificationScreen(
      {
    Key? key,
        required this.backToMainMenu,
        required this.isFocused,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isFocused) {
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: NotificationsErrorFutureBuilder(
              future: ref.watch(notificationControllerProvider).getNotifications(),
              onDialogCancel: () => backToMainMenu.call(),
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
