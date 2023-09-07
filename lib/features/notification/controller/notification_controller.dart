import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/notification/repository/notification_repository.dart';

import '../../../models/notification_model.dart';
import '../../../models/user_model.dart';
import '../../auth/repository/auth_repository.dart';

final notificationControllerProvider = Provider((ref) {
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return NotificationController(notificationRepository: notificationRepository, authRepository: authRepository, ref: ref);
});

class NotificationController {
  final NotificationRepository notificationRepository;
  final ProviderRef ref;
  final AuthRepository authRepository;

  NotificationController({
    required this.authRepository,
    required this.notificationRepository,
    required this.ref,
  });

  Stream<List<NotificationModel>> notifications(int limit) {
    return notificationRepository.getNotifications(limit);
  }

  Future<UserModel?> getUserData() async {
    UserModel? user = null;
    return user;
  }

  Future<void> addNotification(
      BuildContext context,
      String title,
      String text,
      ) async {
    String username = await getUserData().then((value) => value?.name ?? "???");
    await notificationRepository.addNotification(context, username, DateTime.now(), title, text);
  }

  Future<void> addAdminNotification(
      BuildContext context,
      String title,
      String text,
      ) async {
    await notificationRepository.addNotification(context, "admin", DateTime.now(), title, text);
  }
}
