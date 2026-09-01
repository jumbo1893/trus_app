import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/steps/repository/health_step_service.dart';
import 'package:trus_app/features/steps/repository/step_sync_preferences.dart';
import 'package:trus_app/services/push/notifications_service.dart';

/// Spouští systémová oprávnění až po úspěšném přihlášení a načtení home
/// setupu. Tím pokrývá automatické i ruční přihlášení a dokončení registrace.
final authenticatedPermissionsProvider = FutureProvider<void>((ref) async {
  // Selhání jedné platformní služby nesmí zablokovat nabídnutí druhé.
  try {
    await NotificationsService.initialize(ref);
  } catch (_) {}

  final preferences = StepSyncPreferences();
  if (await preferences.wasHealthPermissionPrompted()) return;

  // Prompt zobrazíme v home setupu pouze jednou. Při zamítnutí může uživatel
  // oprávnění znovu vyvolat explicitním tlačítkem na obrazovce Kroky.
  await preferences.markHealthPermissionPrompted();
  try {
    await HealthStepService().requestPermission();
  } catch (_) {}
});
