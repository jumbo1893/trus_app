import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/api/notification/notification_api_model.dart';

class NotificationListState {
  final AsyncValue<List<NotificationApiModel>> notifications;
  final int pageNumber;
  final bool showNextButton;
  final bool showPreviousButton;

  NotificationListState({
    required this.notifications,
    required this.pageNumber,
    required this.showNextButton,
    required this.showPreviousButton,
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
  }) {
    return NotificationListState(
      notifications: notifications ?? this.notifications,
      pageNumber: pageNumber ?? this.pageNumber,
      showNextButton: showNextButton ?? this.showNextButton,
      showPreviousButton: showPreviousButton ?? this.showPreviousButton,
        );
  }
}
