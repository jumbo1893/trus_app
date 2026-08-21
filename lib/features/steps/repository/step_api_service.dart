import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/request_executor.dart';
import 'package:trus_app/models/api/step/step_models.dart';

final stepApiServiceProvider = Provider((ref) => StepApiService(ref));

class StepApiService extends RequestExecutor {
  StepApiService(super.ref);

  Future<bool> getConsent() => executeGetRequest(
    Uri.parse('$serverUrl/$stepApi/consent'),
    (json) => json['enabled'] as bool? ?? false,
    null,
  );

  Future<bool> setConsent(bool enabled) => executePutRequest(
    Uri.parse('$serverUrl/$stepApi/consent'),
    (json) => json['enabled'] as bool? ?? false,
    jsonEncode({'enabled': enabled}),
  );

  Future<void> sync(List<StepSyncDay> days) async {
    await executePutRequest<void>(
      Uri.parse('$serverUrl/$stepApi/sync'),
      (_) {},
      jsonEncode({'days': days.map((day) => day.toJson()).toList()}),
    );
  }

  Future<StepLeaderboardData> getLeaderboard(StepPeriod period) {
    return executeGetRequest(
      Uri.parse('$serverUrl/$stepApi/leaderboard'),
      (json) => StepLeaderboardData.fromJson(json as Map<String, dynamic>),
      {'period': period.apiValue},
    );
  }
}
