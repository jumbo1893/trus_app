import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/steps/repository/health_step_service.dart';
import 'package:trus_app/features/steps/repository/step_api_service.dart';
import 'package:trus_app/features/steps/service/step_sync_scheduler.dart';
import 'package:trus_app/services/push/notifications_service.dart';

final onboardingPermissionsProvider = Provider(
  (ref) => OnboardingPermissions(ref),
);

/// Deliberately not called during load/build/login. Only explicit button actions
/// may ask the OS, persist health consent or start uploading health data.
class OnboardingPermissions {
  final Ref ref;
  OnboardingPermissions(this.ref);

  Future<bool> notifications() async {
    final permission = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (permission.authorizationStatus != AuthorizationStatus.authorized &&
        permission.authorizationStatus != AuthorizationStatus.provisional) {
      return false;
    }
    await NotificationsService.initialize(ref, requestPermissions: false);
    // Also covers an initializer already in flight before the permission prompt.
    await NotificationsService.syncCurrentTokenWithBackend(ref);
    return true;
  }

  Future<bool> steps() async {
    final health = HealthStepService();
    if (!await health.requestPermission()) return false;
    final api = ref.read(stepApiServiceProvider);
    if (!await api.setConsent(true)) throw StateError('Consent not saved');
    final team = ref.read(globalVariablesControllerProvider).appTeam;
    if (team != null) await ref.read(stepSyncSchedulerProvider).enable(team.id);
    await api.sync(await health.readLastDays());
    return true;
  }
}
