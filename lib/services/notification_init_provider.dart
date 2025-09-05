import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/login/controller/auth_login_controller.dart';
import 'notifications_service.dart';

final notificationsInitProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<LoginRedirect>>(
    userDataAuthProvider,
        (previous, next) async {
      next.whenData((redirect) async {
        if (redirect == LoginRedirect.ok) {
          await NotificationsService.initialize(ref);
        }
      });
    },
  );
});
