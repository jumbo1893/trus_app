import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/api/notification/notification_api_model.dart';

class NotificationListState {
  final AsyncValue<List<NotificationApiModel>> notifications;
  final int pageNumber;
  final bool showNextButton;
  final bool showPreviousButton;
  final bool loadingOlder;
  final bool olderFailed;

  NotificationListState({
    required this.notifications,
    required this.pageNumber,
    required this.showNextButton,
    required this.showPreviousButton,
    this.loadingOlder = false,
    this.olderFailed = false,
  });

  factory NotificationListState.initial() => NotificationListState(
    notifications: const AsyncValue.loading(),
    pageNumber: 0,
    showNextButton: true,
    showPreviousButton: false,
  );

  NotificationListState copyWith({
    AsyncValue<List<NotificationApiModel>>? notifications,
    int? pageNumber,
    bool? showNextButton,
    bool? showPreviousButton,
    bool? loadingOlder,
    bool? olderFailed,
  }) {
    return NotificationListState(
      notifications: notifications ?? this.notifications,
      pageNumber: pageNumber ?? this.pageNumber,
      showNextButton: showNextButton ?? this.showNextButton,
      showPreviousButton: showPreviousButton ?? this.showPreviousButton,
      loadingOlder: loadingOlder ?? this.loadingOlder,
      olderFailed: olderFailed ?? this.olderFailed,
    );
  }
}
