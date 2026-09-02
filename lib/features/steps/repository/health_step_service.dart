import 'dart:io';

import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trus_app/models/api/step/step_models.dart';
import 'package:trus_app/services/crash_reporting_service.dart';

class HealthStepService {
  final Health _health = Health();

  Future<bool> requestPermission() async {
    await _health.configure();
    if (Platform.isAndroid) {
      final activity = await Permission.activityRecognition.request();
      if (!activity.isGranted) return false;
    }
    final granted = await _health.requestAuthorization(
      const [HealthDataType.STEPS],
      permissions: const [HealthDataAccess.READ],
    );
    if (granted && Platform.isAndroid) {
      final backgroundAvailable = await _health
          .isHealthDataInBackgroundAvailable();
      if (backgroundAvailable) {
        await _health.requestHealthDataInBackgroundAuthorization();
      }
    }
    return granted;
  }

  Future<bool> hasReadPermission() async {
    try {
      await _health.configure();
      if (Platform.isIOS) return true;
      return await _health.hasPermissions(
            const [HealthDataType.STEPS],
            permissions: const [HealthDataAccess.READ],
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasBackgroundPermission() async {
    if (!Platform.isAndroid) return true;
    await _health.configure();
    final available = await _health.isHealthDataInBackgroundAvailable();
    if (!available) return false;
    return _health.isHealthDataInBackgroundAuthorized();
  }

  Future<List<StepSyncDay>> readLastDays({int days = 30}) async {
    if (days <= 0) return const [];
    await _health.configure();
    final now = DateTime.now();
    final result = <StepSyncDay>[];
    final failedDates = <String>[];
    Object? firstError;
    StackTrace? firstStack;

    await CrashReportingService.setKey('steps_sync_requested_days', days);
    await CrashReportingService.setKey(
      'steps_sync_source',
      Platform.isIOS ? 'HEALTHKIT' : 'HEALTH_CONNECT',
    );
    await CrashReportingService.setKey('steps_sync_phase', 'reading_health');
    await CrashReportingService.log('steps.health.read.begin days=$days');

    for (var offset = days - 1; offset >= 0; offset--) {
      // Konstruktor s posunutým dnem zachová lokální půlnoc i přes změnu času.
      final date = DateTime(now.year, now.month, now.day - offset);
      final end = offset == 0
          ? now
          : DateTime(
              date.year,
              date.month,
              date.day + 1,
            ).subtract(const Duration(milliseconds: 1));
      final dateKey = _dateKey(date);
      await CrashReportingService.setKey('steps_sync_current_date', dateKey);
      await CrashReportingService.log(
        'steps.health.read.day.begin date=$dateKey',
      );

      try {
        final steps = await _health.getTotalStepsInInterval(date, end);
        result.add(
          StepSyncDay(
            date: date,
            stepCount: steps ?? 0,
            source: Platform.isIOS ? 'HEALTHKIT' : 'HEALTH_CONNECT',
            measuredUntil: end,
          ),
        );
        await CrashReportingService.log(
          'steps.health.read.day.success date=$dateKey',
        );
      } catch (error, stack) {
        firstError ??= error;
        firstStack ??= stack;
        failedDates.add(dateKey);
        await CrashReportingService.log(
          'steps.health.read.day.failed date=$dateKey type=${error.runtimeType}',
        );
      }
    }

    await CrashReportingService.setKey(
      'steps_sync_failed_days',
      failedDates.length,
    );
    if (firstError != null && firstStack != null) {
      await CrashReportingService.recordError(
        firstError,
        firstStack,
        reason: 'Částečné selhání čtení historie kroků',
        information: [
          'Požadováno dní: $days',
          'Neúspěšné dny: ${failedDates.join(',')}',
        ],
      );
      if (result.isEmpty) {
        Error.throwWithStackTrace(firstError, firstStack);
      }
    }

    await CrashReportingService.setKey('steps_sync_phase', 'health_read_done');
    await CrashReportingService.log(
      'steps.health.read.done successful=${result.length} failed=${failedDates.length}',
    );
    return result;
  }
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
