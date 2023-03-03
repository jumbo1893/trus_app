import 'package:flutter/material.dart';
import 'package:trus_app/models/notification_model.dart';

import 'custom_text.dart';

class NotificationListTile extends StatelessWidget {
  final NotificationModel notificationModel;
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
                    child: Text(notificationModel.userName.substring(0,1).toUpperCase(), style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                ),
                Text(notificationModel.userName),
              ],
            )),
        SizedBox(
          width: (size.width / 3) - padding,
          child: Text("${notificationModel.date.day}. ${notificationModel.date.month}. ${notificationModel.date.year} ${notificationModel.date.hour}:${notificationModel.date.minute}"),
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
