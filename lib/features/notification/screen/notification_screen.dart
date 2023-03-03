import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/player/controller/player_controller.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../common/widgets/notification_list_tile.dart';
import '../../../models/notification_model.dart';
import '../controller/notification_controller.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StreamBuilder<List<NotificationModel>>(
              stream: ref.watch(notificationControllerProvider).notifications(50),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var notification = snapshot.data![index];
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
              }),
        ),
       );
  }
}
