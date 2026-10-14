import 'dart:async';
import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/steps/repository/health_step_service.dart';
import 'package:trus_app/features/steps/repository/step_api_service.dart';
import 'package:trus_app/features/steps/repository/step_sync_preferences.dart';
import 'package:trus_app/features/steps/repository/background_step_sync.dart';
import 'package:trus_app/services/crash_reporting_service.dart';
import 'package:workmanager/workmanager.dart';

final stepSyncSchedulerProvider = Provider((ref) {
  final scheduler = StepSyncScheduler(ref);
  ref.onDispose(scheduler.pauseForegroundMonitoring);
  return scheduler;
});

class StepSyncScheduler {
  final Ref ref;
  final StepSyncPreferences _preferences = StepSyncPreferences();
  final HealthStepService _health = HealthStepService();
  Timer? _timer;
  bool _running = false;

  StepSyncScheduler(this.ref);

  void startForegroundMonitoring() {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    _timer ??= Timer.periodic(
      const Duration(minutes: 2),
      (_) => syncIfNeeded(),
    );
    unawaited(syncIfNeeded(force: true));
  }

  Future<void> onAppResumed() {
    _timer ??= Timer.periodic(
      const Duration(minutes: 2),
      (_) => syncIfNeeded(),
    );
    return syncIfNeeded(force: true);
  }

  void pauseForegroundMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> enable(int appTeamId) async {
    await _preferences.enable(appTeamId);
    await _updateBackgroundSchedule();
  }

  Future<bool> isBackgroundEnabled() async {
    if (!await _preferences.isBackgroundEnabled()) return false;
    if (await _health.hasBackgroundPermission()) return true;
    await _preferences.setBackgroundEnabled(false);
    await Workmanager().cancelByUniqueName(stepBackgroundTask);
    return false;
  }

  Future<bool> setBackgroundEnabled(bool enabled) async {
    if (enabled) {
      if (!await _health.requestBackgroundPermission()) return false;
    }
    await _preferences.setBackgroundEnabled(enabled);
    await _updateBackgroundSchedule();
    return true;
  }

  Future<void> _updateBackgroundSchedule() async {
    if (!await _preferences.isBackgroundEnabled() ||
        !await _health.hasBackgroundPermission()) {
      await Workmanager().cancelByUniqueName(stepBackgroundTask);
      return;
    }
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
    if (_running ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    _running = true;
    try {
      if (!await _preferences.isEnabled() ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        return;
      }
      final api = ref.read(stepApiServiceProvider);
      if (!await _health.hasReadPermission()) {
        await api.setConsent(false);
        await disable();
        return;
      }
      if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        return;
      }
      final days = await _health.readLastDays(days: 1);
      if (days.isEmpty) return;
      final today = days.single;
      final lastCount = await _preferences.lastCount();
      if (!force && (today.stepCount - lastCount).abs() < 100) return;
      await api.sync([today]);
      await _preferences.setLastCount(today.stepCount);
    } catch (error, stack) {
      await CrashReportingService.recordError(
        error,
        stack,
        reason: 'Foreground synchronizace kroků selhala',
      );
      // Další foreground tick nebo WorkManager synchronizaci zopakuje.
    } finally {
      _running = false;
    }
  }
}
