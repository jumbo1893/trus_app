import 'dart:io';

import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trus_app/models/api/step/step_models.dart';

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
    await _health.configure();
    final now = DateTime.now();
    final result = <StepSyncDay>[];
    for (var offset = days - 1; offset >= 0; offset--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: offset));
      final end = offset == 0
          ? now
          : DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
      final steps = await _health.getTotalStepsInInterval(date, end);
      result.add(
        StepSyncDay(
          date: date,
          stepCount: steps ?? 0,
          source: Platform.isIOS ? 'HEALTHKIT' : 'HEALTH_CONNECT',
          measuredUntil: end,
        ),
      );
    }
    return result;
  }
}
