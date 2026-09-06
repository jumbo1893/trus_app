import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/request_executor.dart';
import 'package:trus_app/models/api/ai/match_report.dart';

final matchReportApiServiceProvider = Provider(
  (ref) => MatchReportApiService(ref),
);

class MatchReportApiService extends RequestExecutor {
  MatchReportApiService(super.ref);
  Uri _uri(int matchId) =>
      Uri.parse('$serverUrl/$aiApi/matches/$matchId/reports');
  Future<MatchReportState> getReports(int matchId) => executeGetRequest(
    _uri(matchId),
    (json) => MatchReportState.fromJson((json as Map).cast<String, dynamic>()),
    null,
  );
  Future<MatchReport> generate(int matchId) => executePostRequest(
    _uri(matchId),
    (json) => MatchReport.fromJson((json as Map).cast<String, dynamic>()),
    '{}',
    queueOnFailure: false,
  );
}
