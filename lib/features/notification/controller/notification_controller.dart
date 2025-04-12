import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/api/notification_api_model.dart';
import '../repository/notification_api_service.dart';

final notificationControllerProvider = Provider((ref) {
  final notificationApiService = ref.watch(notificationApiServiceProvider);
  return NotificationController(notificationApiService: notificationApiService, ref: ref);
});

class NotificationController {
  final NotificationApiService notificationApiService;
  final Ref ref;
  final notificationsController = StreamController<List<NotificationApiModel>>.broadcast();
  final showNextButtonController = StreamController<bool>.broadcast();
  final showPreviousButtonController = StreamController<bool>.broadcast();
  int pageNumber = 0;
  int? notificationsNumber;

  NotificationController({
    required this.notificationApiService,
    required this.ref,
  });

  Future<void> nextPage() async {
    pageNumber++;
    notificationsController.add(await getNotifications());
  }

  Future<void> previousPage() async {
    pageNumber--;
    notificationsController.add(await getNotifications());
  }

  void calculateShowingButtons() {
    if(pageNumber == 0) {
      showPreviousButtonController.add(false);
    }
    else {
      showPreviousButtonController.add(true);
    }
    if(notificationsNumber != null && notificationsNumber == 20) {
      showNextButtonController.add(true);
    }
    else {
      showNextButtonController.add(false);
    }
  }


  Future<void> setNewPageNumber(int pageNumber) async {
    this.pageNumber = pageNumber;
    notificationsController.add(await getNotifications());
  }

  Stream<List<NotificationApiModel>> notifications() {
    return notificationsController.stream;
  }

  Stream<bool> showNextButton() {
    return showNextButtonController.stream;
  }

  Stream<bool> showPreviousButton() {
    return showPreviousButtonController.stream;
  }


  Future<List<NotificationApiModel>> getNotifications() async {
    List<NotificationApiModel> notifications = await notificationApiService.getNotifications(pageNumber);
    notificationsNumber = notifications.length;
    calculateShowingButtons();
    return notifications;
  }
}
