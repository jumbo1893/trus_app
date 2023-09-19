import 'package:flutter/material.dart';
import '../../../models/api/notification_api_model.dart';
import '../../utils/utils.dart';
import '../loader.dart';
import '../notification_list_tile.dart';

class NotificationsErrorFutureBuilder<T> extends StatelessWidget {
  final Future<List<NotificationApiModel>> future;
  final Stream<List<NotificationApiModel>> rebuildStream;
  final BuildContext context;
  final VoidCallback backToMainMenu;
  const NotificationsErrorFutureBuilder({
    Key? key,
    required this.future,
    required this.context,
    required this.backToMainMenu,
    required this.rebuildStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NotificationApiModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        else if (snapshot.hasError) {
          Future.delayed(Duration.zero, () => showErrorDialog(snapshot.error!.toString(), () => backToMainMenu(), context));
          return const Loader();
        }
        return StreamBuilder<List<NotificationApiModel>>(
          stream: rebuildStream,
          builder: (context, streamSnapshot) {
            if (streamSnapshot.hasError) {
              Future.delayed(Duration.zero, () => showErrorDialog(streamSnapshot.error!.toString(), () => backToMainMenu(), context));
              return const Loader();
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: streamSnapshot.data?.length ?? snapshot.data!.length,
              itemBuilder: (context, index) {
                var notification = streamSnapshot.data?[index] ?? snapshot.data![index];
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
                            child: NotificationListTile(notificationModel: notification, padding: 16,)
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          }
        );
      },
    );
  }
}