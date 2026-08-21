import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/steps/repository/health_step_service.dart';
import 'package:trus_app/features/steps/repository/step_api_service.dart';
import 'package:trus_app/features/steps/repository/step_sync_preferences.dart';
import 'package:trus_app/features/steps/repository/background_step_sync.dart';
import 'package:workmanager/workmanager.dart';

final stepSyncSchedulerProvider = Provider((ref) => StepSyncScheduler(ref));

class StepSyncScheduler {
  final Ref ref;
  final StepSyncPreferences _preferences = StepSyncPreferences();
  final HealthStepService _health = HealthStepService();
  Timer? _timer;
  bool _running = false;

  StepSyncScheduler(this.ref);

  void startForegroundMonitoring() {
    _timer ??= Timer.periodic(
      const Duration(minutes: 2),
      (_) => syncIfNeeded(),
    );
    unawaited(syncIfNeeded(force: true));
  }

  Future<void> onAppResumed() => syncIfNeeded(force: true);

  Future<void> enable(int appTeamId) async {
    await _preferences.enable(appTeamId);
    await Workmanager().registerPeriodicTask(
      stepBackgroundTask,
      stepBackgroundTask,
      frequency: const Duration(hours: 6),
      initialDelay: const Duration(hours: 6),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  Future<void> recordSyncedCount(int count) => _preferences.setLastCount(count);

  Future<void> disable() async {
    await _preferences.disable();
    await Workmanager().cancelByUniqueName(stepBackgroundTask);
  }

  Future<void> syncIfNeeded({bool force = false}) async {
    if (_running || !await _preferences.isEnabled()) return;
    _running = true;
    try {
      final api = ref.read(stepApiServiceProvider);
      if (!await _health.hasReadPermission()) {
        await api.setConsent(false);
        await disable();
        return;
      }
      final today = (await _health.readLastDays(days: 1)).single;
      final lastCount = await _preferences.lastCount();
      if (!force && (today.stepCount - lastCount).abs() < 100) return;
      await api.sync([today]);
      await _preferences.setLastCount(today.stepCount);
    } catch (_) {
      // Další foreground tick nebo WorkManager synchronizaci zopakuje.
    } finally {
      _running = false;
    }
  }
}
