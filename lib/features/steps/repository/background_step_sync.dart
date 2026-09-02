import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/steps/repository/health_step_service.dart';
import 'package:trus_app/features/steps/repository/step_sync_preferences.dart';
import 'package:trus_app/firebase_options.dart';
import 'package:trus_app/models/api/step/step_models.dart';
import 'package:trus_app/services/crash_reporting_service.dart';
import 'package:workmanager/workmanager.dart';

const stepBackgroundTask = 'com.jumbo.trus_app.steps.sync';

@pragma('vm:entry-point')
void stepBackgroundCallbackDispatcher() {
  Workmanager().executeTask((_, __) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    CrashReportingService.initialize();
    try {
      return await BackgroundStepSync().run();
    } catch (error, stack) {
      await CrashReportingService.recordError(
        error,
        stack,
        reason: 'Background synchronizace kroků selhala',
      );
      return false;
    }
  });
}

class BackgroundStepSync {
  final StepSyncPreferences _preferences = StepSyncPreferences();
  final HealthStepService _health = HealthStepService();

  Future<bool> run() async {
    if (!await _preferences.isEnabled()) return true;
    final teamId = await _preferences.teamId();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (teamId == null || firebaseUser?.email == null) return true;

    final user = firebaseUser!;
    if (!await _health.hasReadPermission()) {
      await _send(user, teamId, false, const []);
      await _preferences.disable();
      return true;
    }
    if (Platform.isAndroid && !await _health.hasBackgroundPermission()) {
      return true;
    }

    final days = await _health.readLastDays(days: 2);
    if (days.isEmpty) return false;
    final response = await _send(user, teamId, true, days);
    if (response.statusCode < 200 || response.statusCode >= 300) return false;
    final todayCount = _todayStepCount(days);
    if (todayCount != null) await _preferences.setLastCount(todayCount);
    return true;
  }

  Future<http.Response> _send(
    User user,
    int teamId,
    bool permissionGranted,
    List<StepSyncDay> days,
  ) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final idToken = await user.getIdToken();
    return http.post(
      Uri.parse('$serverUrl/$stepApi/background-sync'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-app-version': packageInfo.version,
        if (idToken != null && idToken.isNotEmpty)
          'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'appTeamId': teamId,
        'permissionGranted': permissionGranted,
        'days': days.map((day) => day.toJson()).toList(),
      }),
    );
  }
}

int? _todayStepCount(List<StepSyncDay> days) {
  final now = DateTime.now();
  for (final day in days.reversed) {
    if (day.date.year == now.year &&
        day.date.month == now.month &&
        day.date.day == now.day) {
      return day.stepCount;
    }
  }
  return null;
}
