import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/services/push/notifications_service.dart';

/// Notification delivery is initialized after login. Health access is requested
/// explicitly by the user on the Steps screen.
final authenticatedPermissionsProvider = FutureProvider<void>((ref) async {
  try {
    await NotificationsService.initialize(ref, requestPermissions: false);
  } catch (_) {}
});
