import 'package:trus_app/features/general/cache/i_endpoint_id.dart';

import 'chart.dart';
import 'dashboard_match.dart';
import 'stats_board_data.dart';

class HomeSetup implements IEndpointId {
  String nextBirthday;
  List<String> randomFacts;
  Chart? chart;
  final List<Chart> charts;
  final DashboardMatch? nextMatch;
  final DashboardMatch? lastMatch;

  final List<StatsBoardData> statsBoards;

  static const endpointId = "home_setup";

  HomeSetup({
    required this.nextBirthday,
    required this.randomFacts,
    required this.chart,
    required this.charts,
    required this.nextMatch,
    required this.lastMatch,
    required this.statsBoards,
  });

  factory HomeSetup.fromJson(Map<String, dynamic> json) {
    return HomeSetup(
      nextBirthday: json["nextBirthday"] ?? "",

      randomFacts: List<String>.from(
        json['randomFacts'] ?? [],
      ),

      chart: json["chart"] != null
          ? Chart.fromJson(json["chart"])
          : null,

      charts: List<Chart>.from(
        (json['charts'] as List<dynamic>? ?? [])
            .map((e) => Chart.fromJson(e)),
      ),

      nextMatch: json["nextMatch"] != null
          ? DashboardMatch.fromJson(json["nextMatch"])
          : null,

      lastMatch: json["lastMatch"] != null
          ? DashboardMatch.fromJson(json["lastMatch"])
          : null,

      statsBoards: List<StatsBoardData>.from(
        (json['statsBoards'] as List<dynamic>? ?? [])
            .map((e) => StatsBoardData.fromJson(e)),
      ),
    );
  }

  @override
  String getEndpointId() {
    return endpointId;
  }
}