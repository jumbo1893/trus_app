import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/cache/cache_processor.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';
import 'package:trus_app/features/notification/repository/notification_api_service.dart';
import 'package:trus_app/models/api/notification/push/enabled_push_notification.dart';
import 'package:trus_app/models/helper/title_and_text.dart';

import '../../../../models/api/notification/push/notification_type.dart';

final enabledNotificationController = Provider((ref) {
  final notificationService = ref.watch(notificationApiServiceProvider);
  return EnabledNotificationController(notificationService: notificationService, ref: ref);
});

class EnabledNotificationController extends CacheProcessor with BooleanControllerMixin {
  final NotificationApiService notificationService;
  final loadingController = StreamController<bool>.broadcast();
  String originalFineName = "";

  final String phoneKey = "PHONE";
  final String globalKey = "GLOBAL";
  final String beerKey = "BEER";
  final String fineKey = "FINE";
  final String threeDaysBeforeKey = "THREE_DAYS_BEFORE";
  final String oneDayBeforeKey = "ONE_DAY_BEFORE";
  final String afterResultKey = "AFTER_RESULT";
  final String refereeCommentKey = "REFEREE_COMMENT";
  List<EnabledPushNotification> enabledNotificationsList = [];

  EnabledNotificationController({
    required this.notificationService,
    required Ref ref,
  }) : super(ref);

  void loadEnabledNotifications() {
    initBooleanFields(false, phoneKey);
    for(EnabledPushNotification enabledPushNotification in enabledNotificationsList) {
      initBooleanFields(enabledPushNotification.enabled, notificationTypeToServer(enabledPushNotification.type));
    }
  }

  @override
  void setBoolean(bool boolean, String key) {
    if(key == notificationTypeToServer(NotificationType.global)) {
      for(EnabledPushNotification enabledPushNotification in enabledNotificationsList) {
        if(enabledPushNotification.type != NotificationType.global) {
          setBoolean(boolean, notificationTypeToServer(enabledPushNotification.type));
        }
      }
    }
    else {
      if(boolean) {
        setBooleanInternal(boolean, notificationTypeToServer(NotificationType.global));
      }
    }
    setBooleanInternal(boolean, key);
  }

  Future<void> enabledNotifications() async {
    Future.delayed(
        Duration.zero,
            () => loadEnabledNotifications());
  }

  Stream<bool> loading() {
    return loadingController.stream;
  }

  Future<String> editModels() async {
    TitleAndText titleAndText = await notificationService.editNotificationsPermit(getEditedEnabledNotifications());
    return titleAndText.text;
  }

  List<EnabledPushNotification> getEditedEnabledNotifications() {
    List<EnabledPushNotification> returnList = [];
    for(EnabledPushNotification enabledPushNotification in enabledNotificationsList) {
      enabledPushNotification.enabled = boolValues[notificationTypeToServer(enabledPushNotification.type)]!;
      returnList.add(enabledPushNotification);
    }
    return returnList;
  }


  Future<void> setupEnabledNotifications() async {
    enabledNotificationsList = await notificationService.getEnabledNotifications();
  }

}
