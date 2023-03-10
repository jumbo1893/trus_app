import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/firebase_exception.dart';
import '../../../common/utils/utils.dart';
import '../../../config.dart';
import '../../../models/notification_model.dart';

final notificationRepositoryProvider = Provider(
    (ref) => NotificationRepository(
        firestore: FirebaseFirestore.instance),
);

class NotificationRepository extends CustomFirebaseException {
  final FirebaseFirestore firestore;

  NotificationRepository({
    required this.firestore
  });

  Stream<List<NotificationModel>> getNotifications(int limit) {
    return firestore.collection(notificationTable).orderBy("date", descending: true).limit(limit).snapshots().map((event) {
      List<NotificationModel> notifications = [];
      for (var document in event.docs) {
        var notification = NotificationModel.fromJson(document.data());
        notifications.add(notification);
      }
      return notifications;
    });
  }

  Future<bool> addNotification(BuildContext context, String username, DateTime date, String title, String text) async {
    try {
      final document = firestore.collection(notificationTable).doc();
      NotificationModel notification = NotificationModel(id: document.id, userName: username, date: date, title: title, text: text);
      await document.set(notification.toJson());
      return true;
    } on FirebaseException catch (e) {
      if(!showSnackBarOnException(e.code, context)) {
        showSnackBar(
          context: context,
          content: e.message!,
        );
      }
    }
    return false;
  }
}