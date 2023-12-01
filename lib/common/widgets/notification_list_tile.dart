import 'package:flutter/material.dart';

import '../../models/api/notification_api_model.dart';
import '../utils/calendar.dart';

class NotificationListTile extends StatelessWidget {
  final NotificationApiModel notificationModel;
  final double padding;
  const NotificationListTile({
    Key? key,
    required this.notificationModel,
    required this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: (size.width / 6) - padding,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black12,
                    child: Text(notificationModel.userName.substring(0,1).toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                ),
                Text(notificationModel.userName),
              ],
            )),
        SizedBox(
          width: (size.width / 3) - padding,
          child: Text(formatDateForFrontend(notificationModel.date)),
          ),
        SizedBox(
          width: (size.width / 2) - padding,
          child: Column(
            children: [
              Text(notificationModel.title, style: const TextStyle(fontWeight: FontWeight.bold),),
              const SizedBox(height: 5,),
              Align(
                alignment: Alignment.centerLeft,
                  child: Text(notificationModel.text, textAlign: TextAlign.start,))
            ],
          ),
        ),
      ],
    );
  }
}
