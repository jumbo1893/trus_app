import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';

import '../../../features/main/screen_controller.dart';
import '../../../models/api/notification/notification_api_model.dart';
import '../../utils/utils.dart';
import '../loader.dart';
import '../notification_list_tile.dart';

class NotificationsErrorFutureBuilder<T> extends ConsumerWidget {
  final Future<List<NotificationApiModel>> future;
  final Stream<List<NotificationApiModel>> rebuildStream;
  final BuildContext context;

  const NotificationsErrorFutureBuilder({
    Key? key,
    required this.future,
    required this.context,
    required this.rebuildStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<NotificationApiModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.hasError) {
          Future.delayed(
              Duration.zero,
              () => showErrorDialog(
                  snapshot,
                  () => ref
                      .read(screenControllerProvider)
                      .changeFragment(HomeScreen.id),
                  context));
          return const Loader();
        }
        return StreamBuilder<List<NotificationApiModel>>(
            stream: rebuildStream,
            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasError) {
                Future.delayed(
                    Duration.zero,
                    () => showErrorDialog(
                        streamSnapshot,
                        () => ref
                            .read(screenControllerProvider)
                            .changeFragment(HomeScreen.id),
                        context));
                return const Loader();
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: streamSnapshot.data?.length ?? snapshot.data!.length,
                itemBuilder: (context, index) {
                  var notification =
                      streamSnapshot.data?[index] ?? snapshot.data![index];
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
              );
            });
      },
    );
  }
}
