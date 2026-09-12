import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/login/controller/auth_login_controller.dart';
import '../permissions/authenticated_permissions_provider.dart';

final notificationsInitProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<LoginRedirect>>(userDataAuthProvider, (previous, next) {
    if (next.valueOrNull == LoginRedirect.ok) {
      // Share Home's guarded, nonprompting initialization. Login may not ask
      // before onboarding's category selection.
      unawaited(ref.read(authenticatedPermissionsProvider.future));
    }
  });
});
